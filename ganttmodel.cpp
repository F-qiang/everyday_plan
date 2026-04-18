#include "ganttmodel.h"
#include "databasemanager.h"
#include <QDebug>
#include <QStringView>

namespace {
QDate parseTaskDate(const QString &value)
{
    const QString source = value.trimmed();
    if (source.isEmpty()) {
        return QDate();
    }

    const QStringView datePart = QStringView{source}.left(10);
    QDate date = QDate::fromString(datePart.toString(), "yyyy-MM-dd");
    if (date.isValid()) {
        return date;
    }

    date = QDate::fromString(source, Qt::ISODate);
    if (date.isValid()) {
        return date;
    }

    return QDate::fromString(source, "yyyy-MM-dd HH:mm");
}
}

GanttTaskItem::GanttTaskItem(QObject *parent)
    : QObject(parent)
    , m_taskId(0)
    , m_progress(0)
    , m_priority(1)
    , m_status(0)
    , m_categoryId(0)
    , m_categoryName("未分类")
    , m_categoryColor("#94a3b8")
    , m_color("#3498db")
{
}

GanttModel::GanttModel(QObject *parent)
    : QAbstractListModel(parent)
    , m_userId(-1)
    , m_dayWidth(50)
{
    m_viewStartDate = QDate::currentDate().addDays(-QDate::currentDate().dayOfWeek() + 1);
    m_viewEndDate = m_viewStartDate.addDays(13);
}

GanttModel::~GanttModel()
{
    qDeleteAll(m_tasks);
    m_tasks.clear();
}

int GanttModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_tasks.size();
}

QVariant GanttModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_tasks.size()) {
        return QVariant();
    }

    GanttTaskItem *item = m_tasks.at(index.row());

    switch (role) {
    case TaskIdRole:
        return item->taskId();
    case TitleRole:
        return item->title();
    case DescriptionRole:
        return item->description();
    case StartDateRole:
        return item->startDate().toString("yyyy-MM-dd");
    case EndDateRole:
        return item->endDate().isValid() ? item->endDate().toString("yyyy-MM-dd") : QString();
    case ProgressRole:
        return calculateTimeProgress(item->startDate(), item->endDate());
    case PriorityRole:
        return item->priority();
    case StatusRole:
        return item->status();
    case CategoryIdRole:
        return item->categoryId();
    case CategoryNameRole:
        return item->categoryName();
    case CategoryColorRole:
        return item->categoryColor();
    case AuthorRole:
        return item->author();
    case CreatedAtRole:
        return item->createdAt();
    case ColorRole:
        return item->color();
    case StartOffsetRole:
        return calculateStartOffset(item->startDate());
    case DurationRole:
        return calculateDuration(item->startDate(), item->endDate());
    case BarWidthRole:
        return calculateDuration(item->startDate(), item->endDate()) * m_dayWidth;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> GanttModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[TaskIdRole] = "taskId";
    roles[TitleRole] = "title";
    roles[DescriptionRole] = "description";
    roles[StartDateRole] = "startDate";
    roles[EndDateRole] = "endDate";
    roles[ProgressRole] = "progress";
    roles[PriorityRole] = "priority";
    roles[StatusRole] = "status";
    roles[CategoryIdRole] = "categoryId";
    roles[CategoryNameRole] = "categoryName";
    roles[CategoryColorRole] = "categoryColor";
    roles[AuthorRole] = "author";
    roles[CreatedAtRole] = "createdAt";
    roles[ColorRole] = "color";
    roles[StartOffsetRole] = "startOffset";
    roles[DurationRole] = "duration";
    roles[BarWidthRole] = "barWidth";
    return roles;
}

QDate GanttModel::viewStartDate() const
{
    return m_viewStartDate;
}

void GanttModel::setViewStartDate(const QDate &date)
{
    if (m_viewStartDate != date) {
        m_viewStartDate = date;
        emit viewDateChanged();
        loadTasks();
    }
}

QDate GanttModel::viewEndDate() const
{
    return m_viewEndDate;
}

void GanttModel::setViewEndDate(const QDate &date)
{
    if (m_viewEndDate != date) {
        m_viewEndDate = date;
        emit viewDateChanged();
        loadTasks();
    }
}

int GanttModel::userId() const
{
    return m_userId;
}

void GanttModel::setUserId(int userId)
{
    if (m_userId != userId) {
        m_userId = userId;
        emit userIdChanged();
        loadTasks();
    }
}

int GanttModel::totalDays() const
{
    return m_viewStartDate.daysTo(m_viewEndDate) + 1;
}

void GanttModel::loadTasks()
{
    if (m_userId < 0) {
        return;
    }

    beginResetModel();
    qDeleteAll(m_tasks);
    m_tasks.clear();

    QVariantList tasks = DatabaseManager::instance()->getTasksByDateRange(
        m_userId,
        m_viewStartDate.toString("yyyy-MM-dd"),
        m_viewEndDate.toString("yyyy-MM-dd")
    );

    const QVariantList categories = DatabaseManager::instance()->getCategoriesByUser(m_userId);

    for (const QVariant &taskVar : tasks) {
        const QVariantMap taskMap = taskVar.toMap();
        GanttTaskItem *item = new GanttTaskItem(this);

        item->setTaskId(taskMap["taskId"].toInt());
        item->setTitle(taskMap["title"].toString());
        item->setDescription(taskMap["description"].toString());
        item->setStartDate(parseTaskDate(taskMap["startDate"].toString()));

        const QString endDateStr = taskMap["endDate"].toString();
        if (!endDateStr.isEmpty()) {
            item->setEndDate(parseTaskDate(endDateStr));
        } else {
            item->setEndDate(item->startDate());
        }

        item->setProgress(taskMap["progress"].toInt());
        item->setPriority(taskMap["priority"].toInt());
        item->setStatus(taskMap["status"].toInt());
        item->setCategoryId(taskMap["categoryId"].toInt());
        item->setCreatedAt(taskMap["createdAt"].toString());

        QString categoryName = "未分类";
        QString categoryColor = "#94a3b8";
        for (const QVariant &categoryVar : categories) {
            const QVariantMap categoryMap = categoryVar.toMap();
            if (categoryMap["categoryId"].toInt() == item->categoryId()) {
                categoryName = categoryMap["name"].toString();
                categoryColor = categoryMap["color"].toString();
                break;
            }
        }
        item->setCategoryName(categoryName);
        item->setCategoryColor(categoryColor);
        item->setColor(categoryColor.isEmpty() ? getPriorityColor(item->priority()) : categoryColor);

        m_tasks.append(item);
    }

    endResetModel();
    emit tasksLoaded(m_tasks.size());

    qDebug() << "甘特图加载了" << m_tasks.size() << "个任务";
}

void GanttModel::setDateRange(const QDate &start, const QDate &end)
{
    m_viewStartDate = start;
    m_viewEndDate = end;
    emit viewDateChanged();
    loadTasks();
}

void GanttModel::moveToPreviousWeek()
{
    m_viewStartDate = m_viewStartDate.addDays(-7);
    m_viewEndDate = m_viewEndDate.addDays(-7);
    emit viewDateChanged();
    loadTasks();
}

void GanttModel::moveToNextWeek()
{
    m_viewStartDate = m_viewStartDate.addDays(7);
    m_viewEndDate = m_viewEndDate.addDays(7);
    emit viewDateChanged();
    loadTasks();
}

void GanttModel::moveToToday()
{
    m_viewStartDate = QDate::currentDate().addDays(-QDate::currentDate().dayOfWeek() + 1);
    m_viewEndDate = m_viewStartDate.addDays(13);
    emit viewDateChanged();
    loadTasks();
}

bool GanttModel::updateTaskDates(int taskId, const QDate &startDate, const QDate &endDate)
{
    QVariantMap data;
    data["startDate"] = startDate.toString("yyyy-MM-dd");
    data["endDate"] = endDate.toString("yyyy-MM-dd");

    if (DatabaseManager::instance()->updateTask(taskId, data)) {
        for (GanttTaskItem *item : m_tasks) {
            if (item->taskId() == taskId) {
                item->setStartDate(startDate);
                item->setEndDate(endDate);

                QModelIndex idx = index(m_tasks.indexOf(item));
                emit dataChanged(idx, idx, {StartDateRole, EndDateRole, ProgressRole, StartOffsetRole, DurationRole, BarWidthRole});
                break;
            }
        }
        return true;
    }
    return false;
}

bool GanttModel::updateTaskProgress(int taskId, int progress)
{
    if (DatabaseManager::instance()->updateTaskProgress(taskId, progress)) {
        for (GanttTaskItem *item : m_tasks) {
            if (item->taskId() == taskId) {
                item->setProgress(progress);

                QModelIndex idx = index(m_tasks.indexOf(item));
                emit dataChanged(idx, idx, {ProgressRole});
                break;
            }
        }
        return true;
    }
    return false;
}

QString GanttModel::getPriorityColor(int priority) const
{
    switch (priority) {
    case 4: return "#e74c3c";
    case 3: return "#e67e22";
    case 2: return "#f1c40f";
    case 1:
    default:
        return "#3498db";
    }
}

int GanttModel::calculateStartOffset(const QDate &taskStart) const
{
    if (taskStart < m_viewStartDate) {
        return 0;
    }
    return m_viewStartDate.daysTo(taskStart);
}

int GanttModel::calculateDuration(const QDate &start, const QDate &end) const
{
    QDate effectiveEnd = end.isValid() ? end : start;
    QDate effectiveStart = start;

    if (effectiveStart < m_viewStartDate) {
        effectiveStart = m_viewStartDate;
    }
    if (effectiveEnd > m_viewEndDate) {
        effectiveEnd = m_viewEndDate;
    }

    int duration = effectiveStart.daysTo(effectiveEnd) + 1;
    return qMax(1, duration);
}

int GanttModel::calculateTimeProgress(const QDate &start, const QDate &end) const
{
    if (!start.isValid()) {
        return 0;
    }

    const QDate effectiveEnd = end.isValid() ? end : start;
    const QDate today = QDate::currentDate();

    if (today < start) {
        return 0;
    }
    if (today >= effectiveEnd) {
        return 100;
    }

    const int totalSpanDays = qMax(1, start.daysTo(effectiveEnd));
    const int elapsedDays = qMax(0, start.daysTo(today));
    return qBound(0, qRound((elapsedDays * 100.0) / totalSpanDays), 100);
}
