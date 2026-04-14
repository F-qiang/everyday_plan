#include "abstractcontentsmodel.h"
#include "abstractContentsItem.h"
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QDateTime>
#include <QDate>
#include <QDebug>
#include <QSqlError>

AbstractContentsModel::AbstractContentsModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int AbstractContentsModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_contentList.size();
}

QVariant AbstractContentsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_contentList.size()) {
        return QVariant();
    }

    AbstractContentsItem *item = m_contentList.at(index.row());
    switch (role) {
    case IndexNumRole: return item->index_num();
    case TitleRole: return item->title();
    case AuthorRole: return item->author();
    case ContentRole: return item->content();
    case TimeRole: return item->time().toString("MM-dd");
    case OutlineRole: return item->outline();
    case CreatedAtRole: return item->createdAt();
    case StartDateRole: return item->startDate();
    case DueDateRole: return item->dueDate();
    case PriorityRole: return item->priority();
    case CategoryIdRole: return item->categoryId();
    case CategoryNameRole: return item->categoryName();
    case CategoryColorRole: return item->categoryColor();
    case CompletedRole: return item->completed();
    default: return QVariant();
    }
}

QHash<int, QByteArray> AbstractContentsModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IndexNumRole] = "index_num";
    roles[TitleRole] = "title";
    roles[AuthorRole] = "author";
    roles[ContentRole] = "content";
    roles[TimeRole] = "time";
    roles[OutlineRole] = "outline";
    roles[CreatedAtRole] = "created_at";
    roles[StartDateRole] = "startDate";
    roles[DueDateRole] = "dueDate";
    roles[PriorityRole] = "priority";
    roles[CategoryIdRole] = "categoryId";
    roles[CategoryNameRole] = "categoryName";
    roles[CategoryColorRole] = "categoryColor";
    roles[CompletedRole] = "completed";
    return roles;
}

QVariantMap AbstractContentsModel::get(int row) const
{
    QVariantMap task;
    if (row < 0 || row >= m_contentList.size()) {
        return task;
    }

    AbstractContentsItem *item = m_contentList.at(row);
    task.insert("index_num", item->index_num());
    task.insert("title", item->title());
    task.insert("author", item->author());
    task.insert("content", item->content());
    task.insert("time", item->time().toString("MM-dd"));
    task.insert("outline", item->outline());
    task.insert("created_at", item->createdAt());
    task.insert("startDate", item->startDate());
    task.insert("dueDate", item->dueDate());
    task.insert("priority", item->priority());
    task.insert("categoryId", item->categoryId());
    task.insert("categoryName", item->categoryName());
    task.insert("categoryColor", item->categoryColor());
    task.insert("completed", item->completed());
    return task;
}

bool AbstractContentsModel::loadAllFromDatabase(const QString &dbPath, bool todayOnly, bool completedOnly)
{
    beginResetModel();
    qDeleteAll(m_contentList);
    m_contentList.clear();

    QSqlDatabase db;
    const QString connName = "content_model_conn_" + QString::number(qHash(dbPath + (todayOnly ? "_today" : "_all") + (completedOnly ? "_completed" : "_not_completed")));
    if (QSqlDatabase::contains(connName)) db = QSqlDatabase::database(connName);
    else {
        db = QSqlDatabase::addDatabase("QSQLITE", connName);
        db.setDatabaseName(dbPath);
    }

    if (!db.open()) {
        qDebug() << "[AbstractContentsModel] 数据库打开失败：" << db.lastError().text();
        endResetModel();
        return false;
    }

    QSqlQuery query(db);
    QString sql = R"(
        SELECT Tasks.task_id,
               Tasks.title,
               Tasks.description,
               COALESCE(NULLIF(Tasks.content, ''), Tasks.description, '') AS content,
               Tasks.created_at,
               Tasks.start_date,
               Tasks.end_date,
               Tasks.priority,
               Tasks.category_id,
               COALESCE(NULLIF(Users.nickname, ''), Users.email, '当前用户') AS author_name,
               COALESCE(Categories.name, '未分类') AS category_name,
               COALESCE(Categories.color, '#94a3b8') AS category_color,
               CASE WHEN Tasks.status = 1 THEN 1 ELSE 0 END AS completed_flag
        FROM Tasks
        LEFT JOIN Users ON Users.user_id = Tasks.user_id
        LEFT JOIN Categories ON Categories.category_id = Tasks.category_id
    )";

    if (todayOnly) {
        sql += " WHERE ((Tasks.start_date IS NOT NULL AND Tasks.start_date != '' AND date(Tasks.start_date, '+8 hours') <= date('now', '+8 hours') AND (Tasks.end_date IS NULL OR Tasks.end_date = '' OR date(Tasks.end_date, '+8 hours') >= date('now', '+8 hours'))) OR (Tasks.today_until IS NOT NULL AND Tasks.today_until != '' AND datetime(Tasks.today_until) > datetime('now', '+8 hours')))";
        if (!completedOnly) {
            sql += " AND Tasks.status != 1";
        }
    }

    if (completedOnly) {
        sql += todayOnly ? " AND Tasks.status = 1" : " WHERE Tasks.status = 1";
    }

    sql += " ORDER BY Tasks.created_at DESC, Tasks.task_id DESC";

    if (!query.exec(sql)) {
        qDebug() << "[AbstractContentsModel] 遍历 Tasks 数据失败：" << query.lastError().text();
        db.close();
        endResetModel();
        return false;
    }

    while (query.next()) {
        AbstractContentsItem *item = new AbstractContentsItem(this);
        item->setIndex_num(query.value("task_id").toInt());
        item->setTitle(query.value("title").toString());
        item->setAuthor(query.value("author_name").toString());
        item->setContent(query.value("content").toString());
        item->setOutline(query.value("description").toString());
        item->setPriority(query.value("priority").toInt());
        item->setCategoryId(query.value("category_id").toInt());
        item->setCategoryName(query.value("category_name").toString());
        item->setCategoryColor(query.value("category_color").toString());
        item->setCompleted(query.value("completed_flag").toInt() == 1);
        item->setStartDate(query.value("start_date").toString());
        item->setDueDate(query.value("end_date").toString());

        const QString createdAtText = query.value("created_at").toString();
        QDateTime time = QDateTime::fromString(createdAtText, Qt::ISODate);
        if (!time.isValid()) time = QDateTime::fromString(createdAtText, "yyyy-MM-dd HH:mm:ss");
        if (time.isValid()) {
            item->setTime(time);
            item->setCreatedAt(time.toString("yyyy-MM-dd HH:mm"));
        } else {
            item->setCreatedAt(createdAtText);
        }

        m_contentList.append(item);
    }

    endResetModel();
    db.close();
    return true;
}

void AbstractContentsModel::updateOutline(int row, const QString &newOutline, const QString &dbPath)
{
    if (row < 0 || row >= m_contentList.size()) return;

    AbstractContentsItem *item = m_contentList.at(row);
    item->setOutline(newOutline);
    item->setContent(newOutline);

    QModelIndex idx = index(row);
    emit dataChanged(idx, idx, {OutlineRole, ContentRole});

    QSqlDatabase db;
    const QString connName = "content_model_outline_change_" + QString::number(qHash(dbPath));
    if (QSqlDatabase::contains(connName)) db = QSqlDatabase::database(connName);
    else {
        db = QSqlDatabase::addDatabase("QSQLITE", connName);
        db.setDatabaseName(dbPath);
    }

    if (!db.open()) return;

    QSqlQuery query(db);
    query.prepare("UPDATE Tasks SET description = :description, updated_at = CURRENT_TIMESTAMP WHERE task_id = :id");
    query.bindValue(":description", newOutline);
    query.bindValue(":id", item->index_num());
    query.exec();
}
