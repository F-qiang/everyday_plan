#include "databasemanager.h"
#include <QSqlError>
#include <QDateTime>
#include <QDebug>
#include <QVariantMap>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QUrl>
#include <QStandardPaths>
#include <QRegularExpression>

DatabaseManager* DatabaseManager::m_instance = nullptr;

DatabaseManager::DatabaseManager(QObject *parent) : QObject(parent) {}
DatabaseManager::~DatabaseManager() { if (m_db.isOpen()) m_db.close(); m_instance = nullptr; }
DatabaseManager* DatabaseManager::instance() { if (!m_instance) m_instance = new DatabaseManager(); return m_instance; }

bool DatabaseManager::initialize(const QString &dbPath)
{
    m_dbPath = dbPath;
    if (QSqlDatabase::contains("main_connection")) m_db = QSqlDatabase::database("main_connection");
    else {
        m_db = QSqlDatabase::addDatabase("QSQLITE", "main_connection");
        m_db.setDatabaseName(dbPath);
    }
    if (!m_db.open()) { emit errorOccurred(m_db.lastError().text()); return false; }
    if (!createTables()) return false;
    migrateFromOldVersion();
    emit isOpenChanged();
    return true;
}

bool DatabaseManager::isOpen() const { return m_db.isOpen(); }
QSqlDatabase DatabaseManager::database() const { return m_db; }

bool DatabaseManager::createTables()
{
    QSqlQuery query(m_db);
    query.exec("CREATE TABLE IF NOT EXISTS Users (user_id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT UNIQUE NOT NULL, nickname TEXT, avatar BLOB, created_at TEXT DEFAULT CURRENT_TIMESTAMP)");
    query.exec("CREATE TABLE IF NOT EXISTS UserSettings (user_id INTEGER PRIMARY KEY, settings_json TEXT NOT NULL DEFAULT '{}', updated_at TEXT DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE)");
    query.exec("CREATE TABLE IF NOT EXISTS Categories (category_id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, name TEXT NOT NULL, color TEXT DEFAULT '#3498db', icon TEXT, created_at TEXT DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE)");
    query.exec("CREATE TABLE IF NOT EXISTS Tasks (task_id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, title TEXT NOT NULL, description TEXT, content TEXT, start_date TEXT NOT NULL, end_date TEXT, today_until TEXT, today_hidden_until TEXT, progress INTEGER DEFAULT 0, priority INTEGER DEFAULT 1, status INTEGER DEFAULT 0, category_id INTEGER, created_at TEXT DEFAULT CURRENT_TIMESTAMP, updated_at TEXT DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE, FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE SET NULL)");
    query.exec("CREATE TABLE IF NOT EXISTS VerificationCodes (id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT NOT NULL, code TEXT NOT NULL, created_at TEXT DEFAULT CURRENT_TIMESTAMP, expires_at TEXT NOT NULL)");
    query.exec("CREATE INDEX IF NOT EXISTS idx_tasks_user_id ON Tasks(user_id)");
    query.exec("CREATE INDEX IF NOT EXISTS idx_tasks_dates ON Tasks(start_date, end_date)");
    query.exec("CREATE INDEX IF NOT EXISTS idx_verification_email ON VerificationCodes(email)");
    return true;
}

bool DatabaseManager::migrateFromOldVersion()
{
    if (!userSettingsTableExists()) {
        QSqlQuery createSettingsQuery(m_db);
        if (!createSettingsQuery.exec("CREATE TABLE IF NOT EXISTS UserSettings (user_id INTEGER PRIMARY KEY, settings_json TEXT NOT NULL DEFAULT '{}', updated_at TEXT DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE)")) {
            qDebug() << "[DatabaseManager] 创建 UserSettings 失败:" << createSettingsQuery.lastError().text();
            return false;
        }
    }

    if (!taskColumnExists("content")) {
        QSqlQuery alterQuery(m_db);
        if (!alterQuery.exec("ALTER TABLE Tasks ADD COLUMN content TEXT")) {
            qDebug() << "[DatabaseManager] 添加 Tasks.content 失败:" << alterQuery.lastError().text();
            return false;
        }
    }

    if (!taskColumnExists("status")) {
        QSqlQuery alterQuery(m_db);
        if (!alterQuery.exec("ALTER TABLE Tasks ADD COLUMN status INTEGER DEFAULT 0")) {
            qDebug() << "[DatabaseManager] 添加 Tasks.status 失败:" << alterQuery.lastError().text();
            return false;
        }
    }

    if (!taskColumnExists("today_until")) {
        QSqlQuery alterQuery(m_db);
        if (!alterQuery.exec("ALTER TABLE Tasks ADD COLUMN today_until TEXT")) {
            qDebug() << "[DatabaseManager] 添加 Tasks.today_until 失败:" << alterQuery.lastError().text();
            return false;
        }
    }

    if (!taskColumnExists("today_hidden_until")) {
        QSqlQuery alterQuery(m_db);
        if (!alterQuery.exec("ALTER TABLE Tasks ADD COLUMN today_hidden_until TEXT")) {
            qDebug() << "[DatabaseManager] 添加 Tasks.today_hidden_until 失败:" << alterQuery.lastError().text();
            return false;
        }
    }

    QSqlQuery syncQuery(m_db);
    if (!syncQuery.exec("UPDATE Tasks SET content = COALESCE(content, description, '') WHERE content IS NULL OR content = ''")) {
        qDebug() << "[DatabaseManager] 同步 Tasks.content 失败:" << syncQuery.lastError().text();
        return false;
    }

    QSqlQuery statusSyncQuery(m_db);
    if (!statusSyncQuery.exec("UPDATE Tasks SET status = COALESCE(status, 0) WHERE status IS NULL")) {
        qDebug() << "[DatabaseManager] 同步 Tasks.status 失败:" << statusSyncQuery.lastError().text();
        return false;
    }

    QSqlQuery cleanupQuery(m_db);
    if (!cleanupQuery.exec("UPDATE Tasks SET today_until = NULL WHERE today_until IS NOT NULL AND today_until != '' AND datetime(today_until) <= datetime('now', '+8 hours')")) {
        qDebug() << "[DatabaseManager] 清理 Tasks.today_until 失败:" << cleanupQuery.lastError().text();
        return false;
    }

    QSqlQuery hiddenCleanupQuery(m_db);
    if (!hiddenCleanupQuery.exec("UPDATE Tasks SET today_hidden_until = NULL WHERE today_hidden_until IS NOT NULL AND today_hidden_until != '' AND datetime(today_hidden_until) <= datetime('now', '+8 hours')")) {
        qDebug() << "[DatabaseManager] 清理 Tasks.today_hidden_until 失败:" << hiddenCleanupQuery.lastError().text();
        return false;
    }

    return true;
}

bool DatabaseManager::taskColumnExists(const QString &columnName) const
{
    QSqlQuery query(m_db);
    if (!query.exec("PRAGMA table_info(Tasks)")) {
        return false;
    }

    while (query.next()) {
        if (query.value(1).toString().compare(columnName, Qt::CaseInsensitive) == 0) {
            return true;
        }
    }
    return false;
}

bool DatabaseManager::userSettingsTableExists() const
{
    QSqlQuery query(m_db);
    if (!query.exec("SELECT name FROM sqlite_master WHERE type='table' AND name='UserSettings'")) {
        return false;
    }
    return query.next();
}

QVariantMap DatabaseManager::defaultUserSettings() const
{
    return {
        {"homeDarkMode", true},
        {"backgroundImageSource", ""},
        {"navFontSize", 18},
        {"middleCardFontSize", 15},
        {"detailFontSize", 20},
        {"timeDisplayFormat", "ymd24"},
        {"showDetailAuthor", true},
        {"showDetailCreatedDate", true},
        {"showDetailStartDate", true},
        {"showDetailDueDate", true},
        {"showDetailPriority", true},
        {"ganttBlueTaskBars", true},
        {"ganttBlueTodayColumn", true},
        {"ganttBlueGridLines", true},
        {"backupDirectory", suggestedBackupDirectory()},
        {"uiLanguage", "zh"}
    };
}

int DatabaseManager::createUser(const QString &email, const QString &nickname)
{
    QSqlQuery query(m_db);
    query.prepare("INSERT INTO Users (email, nickname) VALUES (?, ?)");
    query.addBindValue(email);
    query.addBindValue(nickname.isEmpty() ? email.split('@').first() : nickname);
    if (!query.exec()) {
        return -1;
    }

    const int userId = query.lastInsertId().toInt();
    if (userId > 0) {
        ensureUserSettingsRow(userId);
    }
    return userId;
}

int DatabaseManager::findUserByEmail(const QString &email)
{
    QSqlQuery query(m_db);
    query.prepare("SELECT user_id FROM Users WHERE email = ?");
    query.addBindValue(email);
    return (query.exec() && query.next()) ? query.value(0).toInt() : -1;
}

QVariantMap DatabaseManager::getUserInfo(int userId)
{
    QVariantMap result;
    QSqlQuery query(m_db);
    query.prepare("SELECT user_id, email, nickname, created_at FROM Users WHERE user_id = ?");
    query.addBindValue(userId);
    if (query.exec() && query.next()) {
        result["userId"] = query.value(0).toInt();
        result["email"] = query.value(1).toString();
        result["nickname"] = query.value(2).toString();
        result["createdAt"] = query.value(3).toString();
    }
    return result;
}

bool DatabaseManager::updateUserInfo(int userId, const QString &nickname, const QByteArray &avatar)
{
    QSqlQuery query(m_db);
    if (avatar.isEmpty()) {
        query.prepare("UPDATE Users SET nickname = ? WHERE user_id = ?");
        query.addBindValue(nickname);
        query.addBindValue(userId);
    } else {
        query.prepare("UPDATE Users SET nickname = ?, avatar = ? WHERE user_id = ?");
        query.addBindValue(nickname);
        query.addBindValue(avatar);
        query.addBindValue(userId);
    }
    return query.exec();
}

QVariantMap DatabaseManager::getUserSettings(int userId)
{
    QVariantMap result;
    if (userId <= 0) {
        return result;
    }

    if (!ensureUserSettingsRow(userId)) {
        return defaultUserSettings();
    }

    QSqlQuery query(m_db);
    query.prepare("SELECT settings_json FROM UserSettings WHERE user_id = ?");
    query.addBindValue(userId);
    if (!query.exec() || !query.next()) {
        return defaultUserSettings();
    }

    const QByteArray json = query.value(0).toByteArray();
    const QJsonDocument doc = QJsonDocument::fromJson(json);
    if (!doc.isObject()) {
        return defaultUserSettings();
    }

    result = defaultUserSettings();
    const QVariantMap storedSettings = doc.object().toVariantMap();
    for (auto it = storedSettings.constBegin(); it != storedSettings.constEnd(); ++it) {
        result[it.key()] = it.value();
    }
    return result;
}

bool DatabaseManager::ensureUserSettingsRow(int userId)
{
    if (userId <= 0) {
        return false;
    }

    QSqlQuery query(m_db);
    query.prepare("INSERT OR IGNORE INTO UserSettings (user_id, settings_json, updated_at) VALUES (?, ?, CURRENT_TIMESTAMP)");
    query.addBindValue(userId);
    query.addBindValue(QStringLiteral("{}"));
    return query.exec();
}

bool DatabaseManager::saveUserSettings(int userId, const QVariantMap &settings)
{
    if (userId <= 0) {
        return false;
    }

    const QJsonObject jsonObject = QJsonObject::fromVariantMap(settings);
    const QByteArray json = QJsonDocument(jsonObject).toJson(QJsonDocument::Compact);

    QSqlQuery query(m_db);
    query.prepare("INSERT INTO UserSettings (user_id, settings_json, updated_at) VALUES (?, ?, CURRENT_TIMESTAMP) "
                  "ON CONFLICT(user_id) DO UPDATE SET settings_json = excluded.settings_json, updated_at = CURRENT_TIMESTAMP");
    query.addBindValue(userId);
    query.addBindValue(QString::fromUtf8(json));
    return query.exec();
}

QString DatabaseManager::suggestedBackupDirectory() const
{
    const QString homePath = QDir::homePath();
    const QStringList candidatePaths = {
        homePath + QStringLiteral("/OneDrive/EverydayPlanBackup"),
        homePath + QStringLiteral("/OneDrive - Personal/EverydayPlanBackup"),
        homePath + QStringLiteral("/OneDrive - 家庭版/EverydayPlanBackup"),
        homePath + QStringLiteral("/OneDrive - 公司/EverydayPlanBackup")
    };

    for (const QString &candidate : candidatePaths) {
        QDir parentDir(QFileInfo(candidate).absolutePath());
        if (parentDir.exists()) {
            return QDir::toNativeSeparators(candidate);
        }
    }

    return QStringLiteral("./backups");
}

QString DatabaseManager::exportBackup(const QString &targetDirectoryUrlOrPath, const QString &accountLabel)
{
    QString targetDirectory = targetDirectoryUrlOrPath.trimmed();
    if (targetDirectory.isEmpty()) {
        return QString();
    }

    const QUrl maybeUrl(targetDirectory);
    if (maybeUrl.isValid() && maybeUrl.isLocalFile()) {
        targetDirectory = maybeUrl.toLocalFile();
    }

    QDir dir(targetDirectory);
    if (!dir.exists() && !dir.mkpath(QStringLiteral("."))) {
        emit errorOccurred(QStringLiteral("无法创建备份目录: ") + targetDirectory);
        return QString();
    }

    QString prefix = accountLabel.trimmed();
    if (prefix.isEmpty()) {
        prefix = QStringLiteral("default");
    }
    prefix = prefix.toLower();
    prefix.replace(QRegularExpression(QStringLiteral("[^a-z0-9._-]+")), QStringLiteral("_"));
    prefix.replace(QRegularExpression(QStringLiteral("_+")), QStringLiteral("_"));
    prefix.remove(QRegularExpression(QStringLiteral("^_+|_+$")));
    if (prefix.isEmpty()) {
        prefix = QStringLiteral("default");
    }

    const QString backupPath = dir.filePath(prefix + QStringLiteral("_everyday_backup_") + QDateTime::currentDateTime().toString(QStringLiteral("yyyyMMdd_HHmmss")) + QStringLiteral(".db"));
    QFile::remove(backupPath);

    const QString escapedPath = QDir::toNativeSeparators(backupPath).replace("'", "''");
    QSqlQuery query(m_db);
    if (!query.exec(QStringLiteral("VACUUM INTO '") + escapedPath + QStringLiteral("'"))) {
        emit errorOccurred(query.lastError().text());
        return QString();
    }

    return QDir::toNativeSeparators(backupPath);
}

bool DatabaseManager::importBackup(const QString &backupFileUrlOrPath)
{
    QString backupPath = backupFileUrlOrPath.trimmed();
    if (backupPath.isEmpty()) {
        emit errorOccurred(QStringLiteral("未选择备份文件"));
        return false;
    }

    const QUrl maybeUrl(backupPath);
    if (maybeUrl.isValid() && maybeUrl.isLocalFile()) {
        backupPath = maybeUrl.toLocalFile();
    }

    const QFileInfo backupInfo(backupPath);
    if (!backupInfo.exists() || !backupInfo.isFile()) {
        emit errorOccurred(QStringLiteral("备份文件不存在: ") + backupPath);
        return false;
    }

    const QString connectionName = QStringLiteral("main_connection");
    if (m_db.isOpen()) {
        m_db.close();
    }
    m_db = QSqlDatabase();
    if (QSqlDatabase::contains(connectionName)) {
        QSqlDatabase::removeDatabase(connectionName);
    }

    QFile::remove(m_dbPath);
    if (!QFile::copy(backupPath, m_dbPath)) {
        emit errorOccurred(QStringLiteral("恢复备份失败，无法写入数据库文件"));
        m_db = QSqlDatabase::addDatabase(QStringLiteral("QSQLITE"), connectionName);
        m_db.setDatabaseName(m_dbPath);
        m_db.open();
        return false;
    }

    m_db = QSqlDatabase::addDatabase(QStringLiteral("QSQLITE"), connectionName);
    m_db.setDatabaseName(m_dbPath);
    if (!m_db.open()) {
        emit errorOccurred(m_db.lastError().text());
        return false;
    }

    if (!createTables()) {
        return false;
    }
    if (!migrateFromOldVersion()) {
        return false;
    }

    emit isOpenChanged();
    return true;
}

int DatabaseManager::createTask(int userId, const QString &title, const QString &description, const QString &content, const QString &startDate, const QString &endDate, int priority, int categoryId, bool completed)
{
    QSqlQuery query(m_db);
    query.prepare("INSERT INTO Tasks (user_id, title, description, content, start_date, end_date, priority, status, category_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
    query.addBindValue(userId);
    query.addBindValue(title);
    query.addBindValue(description);
    query.addBindValue(content.isEmpty() ? description : content);
    query.addBindValue(startDate);
    query.addBindValue(endDate);
    query.addBindValue(priority);
    query.addBindValue(completed ? 1 : 0);
    query.addBindValue(categoryId > 0 ? categoryId : QVariant());
    return query.exec() ? query.lastInsertId().toInt() : -1;
}

bool DatabaseManager::updateTask(int taskId, const QVariantMap &data)
{
    QStringList updates; QVariantList values;
    if (data.contains("title")) { updates << "title = ?"; values << data["title"]; }
    if (data.contains("description")) { updates << "description = ?"; values << data["description"]; }
    if (data.contains("content")) { updates << "content = ?"; values << data["content"]; }
    if (data.contains("startDate")) { updates << "start_date = ?"; values << data["startDate"]; }
    if (data.contains("endDate")) { updates << "end_date = ?"; values << data["endDate"]; }
    if (data.contains("progress")) { updates << "progress = ?"; values << data["progress"]; }
    if (data.contains("priority")) { updates << "priority = ?"; values << data["priority"]; }
    if (data.contains("status")) { updates << "status = ?"; values << data["status"]; }
    if (data.contains("completed")) { updates << "status = ?"; values << (data["completed"].toBool() ? 1 : 0); }
    if (data.contains("todayUntil")) { updates << "today_until = ?"; values << (data["todayUntil"].toString().trimmed().isEmpty() ? QVariant() : data["todayUntil"]); }
    if (data.contains("todayHiddenUntil")) { updates << "today_hidden_until = ?"; values << (data["todayHiddenUntil"].toString().trimmed().isEmpty() ? QVariant() : data["todayHiddenUntil"]); }
    if (data.contains("categoryId")) { updates << "category_id = ?"; values << (data["categoryId"].toInt() > 0 ? data["categoryId"] : QVariant()); }
    if (updates.isEmpty()) return true;
    updates << "updated_at = CURRENT_TIMESTAMP";
    QSqlQuery query(m_db);
    query.prepare(QString("UPDATE Tasks SET %1 WHERE task_id = ?").arg(updates.join(", ")));
    for (const auto &value : values) query.addBindValue(value);
    query.addBindValue(taskId);
    return query.exec();
}

bool DatabaseManager::markTaskForToday(int taskId)
{
    QSqlQuery query(m_db);
    query.prepare("UPDATE Tasks SET today_until = datetime(date('now', '+8 hours', '+1 day') || ' 00:00:00', '-8 hours'), today_hidden_until = NULL, updated_at = CURRENT_TIMESTAMP WHERE task_id = ?");
    query.addBindValue(taskId);
    return query.exec();
}

bool DatabaseManager::clearTaskFromToday(int taskId)
{
    QSqlQuery query(m_db);
    query.prepare("UPDATE Tasks SET today_until = NULL, today_hidden_until = datetime(date('now', '+8 hours', '+1 day') || ' 00:00:00', '-8 hours'), updated_at = CURRENT_TIMESTAMP WHERE task_id = ?");
    query.addBindValue(taskId);
    return query.exec();
}

bool DatabaseManager::updateTaskProgress(int taskId, int progress)
{
    QSqlQuery query(m_db);
    query.prepare("UPDATE Tasks SET progress = ?, updated_at = CURRENT_TIMESTAMP WHERE task_id = ?");
    query.addBindValue(qBound(0, progress, 100));
    query.addBindValue(taskId);
    return query.exec();
}

bool DatabaseManager::deleteTask(int taskId)
{
    QSqlQuery query(m_db);
    query.prepare("DELETE FROM Tasks WHERE task_id = ?");
    query.addBindValue(taskId);
    return query.exec();
}

QVariantList DatabaseManager::getTasksByUser(int userId, const QString &startDate, const QString &endDate)
{
    QVariantList tasks; QSqlQuery query(m_db);
    QString sql = "SELECT task_id, title, description, content, start_date, end_date, progress, priority, status, category_id, created_at FROM Tasks WHERE user_id = ?";
    if (!startDate.isEmpty()) sql += " AND start_date >= ?";
    if (!endDate.isEmpty()) sql += " AND end_date <= ?";
    sql += " ORDER BY start_date ASC";
    query.prepare(sql); query.addBindValue(userId);
    if (!startDate.isEmpty()) query.addBindValue(startDate);
    if (!endDate.isEmpty()) query.addBindValue(endDate);
    if (query.exec()) while (query.next()) {
        QVariantMap task; task["taskId"] = query.value(0).toInt(); task["title"] = query.value(1).toString(); task["description"] = query.value(2).toString(); task["content"] = query.value(3).toString(); task["startDate"] = query.value(4).toString(); task["endDate"] = query.value(5).toString(); task["progress"] = query.value(6).toInt(); task["priority"] = query.value(7).toInt(); task["status"] = query.value(8).toInt(); task["categoryId"] = query.value(9).toInt(); task["createdAt"] = query.value(10).toString(); tasks.append(task);
    }
    return tasks;
}

QVariantList DatabaseManager::getTasksByDateRange(int userId, const QString &startDate, const QString &endDate)
{
    QVariantList tasks; QSqlQuery query(m_db);
    query.prepare("SELECT task_id, title, description, content, start_date, end_date, progress, priority, status, category_id FROM Tasks WHERE user_id = ? AND start_date <= ? AND (end_date >= ? OR end_date IS NULL) ORDER BY start_date ASC");
    query.addBindValue(userId); query.addBindValue(endDate); query.addBindValue(startDate);
    if (query.exec()) while (query.next()) {
        QVariantMap task; task["taskId"] = query.value(0).toInt(); task["title"] = query.value(1).toString(); task["description"] = query.value(2).toString(); task["content"] = query.value(3).toString(); task["startDate"] = query.value(4).toString(); task["endDate"] = query.value(5).toString(); task["progress"] = query.value(6).toInt(); task["priority"] = query.value(7).toInt(); task["status"] = query.value(8).toInt(); task["categoryId"] = query.value(9).toInt(); tasks.append(task);
    }
    return tasks;
}

int DatabaseManager::createCategory(int userId, const QString &name, const QString &color, const QString &icon)
{
    QSqlQuery query(m_db);
    query.prepare("INSERT INTO Categories (user_id, name, color, icon) VALUES (?, ?, ?, ?)");
    query.addBindValue(userId); query.addBindValue(name); query.addBindValue(color); query.addBindValue(icon);
    return query.exec() ? query.lastInsertId().toInt() : -1;
}

QVariantList DatabaseManager::getCategoriesByUser(int userId)
{
    QVariantList categories; QSqlQuery query(m_db);
    query.prepare("SELECT category_id, name, color, icon FROM Categories WHERE user_id = ? ORDER BY created_at DESC, category_id DESC");
    query.addBindValue(userId);
    if (query.exec()) while (query.next()) {
        QVariantMap category; category["categoryId"] = query.value(0).toInt(); category["name"] = query.value(1).toString(); category["color"] = query.value(2).toString(); category["icon"] = query.value(3).toString(); categories.append(category);
    }
    return categories;
}

bool DatabaseManager::updateCategory(int categoryId, const QString &name, const QString &color)
{
    QSqlQuery query(m_db);
    query.prepare("UPDATE Categories SET name = ?, color = ? WHERE category_id = ?");
    query.addBindValue(name);
    query.addBindValue(color);
    query.addBindValue(categoryId);
    return query.exec();
}

bool DatabaseManager::deleteCategory(int categoryId)
{
    QSqlQuery query(m_db);
    query.prepare("DELETE FROM Categories WHERE category_id = ?");
    query.addBindValue(categoryId);
    return query.exec();
}

bool DatabaseManager::saveVerificationCode(const QString &email, const QString &code)
{
    QSqlQuery del(m_db);
    del.prepare("DELETE FROM VerificationCodes WHERE email = ?");
    del.addBindValue(email);
    del.exec();

    QSqlQuery query(m_db);
    query.prepare("INSERT INTO VerificationCodes (email, code, expires_at) VALUES (?, ?, datetime('now', '+5 minutes'))");
    query.addBindValue(email);
    query.addBindValue(code);
    return query.exec();
}

bool DatabaseManager::canRequestVerificationCode(const QString &email, int cooldownSeconds, int *remainingSeconds)
{
    if (remainingSeconds) {
        *remainingSeconds = 0;
    }

    QSqlQuery query(m_db);
    query.prepare("SELECT CAST((julianday(created_at, '+' || ? || ' seconds') - julianday('now')) * 86400 AS INTEGER) FROM VerificationCodes WHERE email = ? ORDER BY id DESC LIMIT 1");
    query.addBindValue(cooldownSeconds);
    query.addBindValue(email);

    if (!query.exec() || !query.next()) {
        return true;
    }

    const int seconds = qMax(0, query.value(0).toInt());
    if (remainingSeconds) {
        *remainingSeconds = seconds;
    }
    return seconds <= 0;
}

bool DatabaseManager::verifyCode(const QString &email, const QString &code)
{
    QSqlQuery query(m_db);
    query.prepare("SELECT id FROM VerificationCodes WHERE email = ? AND code = ? AND expires_at > datetime('now') ORDER BY id DESC LIMIT 1");
    query.addBindValue(email);
    query.addBindValue(code);
    if (!query.exec() || !query.next()) {
        return false;
    }

    const int id = query.value(0).toInt();
    QSqlQuery del(m_db);
    del.prepare("DELETE FROM VerificationCodes WHERE id = ?");
    del.addBindValue(id);
    return del.exec();
}

void DatabaseManager::cleanExpiredCodes()
{
    QSqlQuery query(m_db); query.exec("DELETE FROM VerificationCodes WHERE expires_at <= datetime('now')");
}
