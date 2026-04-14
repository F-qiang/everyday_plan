// 数据库管理器 - 负责数据库初始化和基础操作
#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QString>
#include <QVariantMap>

class DatabaseManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isOpen READ isOpen NOTIFY isOpenChanged)

public:
    explicit DatabaseManager(QObject *parent = nullptr);
    ~DatabaseManager();

    static DatabaseManager* instance();

    Q_INVOKABLE bool initialize(const QString &dbPath);
    bool isOpen() const;
    QSqlDatabase database() const;

    Q_INVOKABLE int createUser(const QString &email, const QString &nickname = QString());
    Q_INVOKABLE int findUserByEmail(const QString &email);
    Q_INVOKABLE QVariantMap getUserInfo(int userId);
    Q_INVOKABLE bool updateUserInfo(int userId, const QString &nickname, const QByteArray &avatar = QByteArray());
    Q_INVOKABLE QVariantMap defaultUserSettings() const;
    Q_INVOKABLE QVariantMap getUserSettings(int userId);
    Q_INVOKABLE bool ensureUserSettingsRow(int userId);
    Q_INVOKABLE bool saveUserSettings(int userId, const QVariantMap &settings);

    Q_INVOKABLE int createTask(int userId, const QString &title, const QString &description,
                               const QString &content, const QString &startDate, const QString &endDate,
                               int priority = 1, int categoryId = 0, bool completed = false);
    Q_INVOKABLE bool updateTask(int taskId, const QVariantMap &data);
    Q_INVOKABLE bool markTaskForToday(int taskId);
    Q_INVOKABLE bool updateTaskProgress(int taskId, int progress);
    Q_INVOKABLE bool deleteTask(int taskId);
    Q_INVOKABLE QVariantList getTasksByUser(int userId, const QString &startDate = QString(), const QString &endDate = QString());
    Q_INVOKABLE QVariantList getTasksByDateRange(int userId, const QString &startDate, const QString &endDate);

    Q_INVOKABLE int createCategory(int userId, const QString &name, const QString &color, const QString &icon = QString());
    Q_INVOKABLE QVariantList getCategoriesByUser(int userId);
    Q_INVOKABLE bool deleteCategory(int categoryId);

    Q_INVOKABLE bool saveVerificationCode(const QString &email, const QString &code);
    Q_INVOKABLE bool canRequestVerificationCode(const QString &email, int cooldownSeconds = 60, int *remainingSeconds = nullptr);
    Q_INVOKABLE bool verifyCode(const QString &email, const QString &code);
    Q_INVOKABLE void cleanExpiredCodes();

signals:
    void isOpenChanged();
    void errorOccurred(const QString &error);

private:
    bool createTables();
    bool migrateFromOldVersion();
    bool taskColumnExists(const QString &columnName) const;
    bool userSettingsTableExists() const;

    QSqlDatabase m_db;
    QString m_dbPath;
    static DatabaseManager* m_instance;
};

#endif
