// 甘特图数据模型 - 为甘特图视图提供任务数据
#ifndef GANTTMODEL_H
#define GANTTMODEL_H

#include <QAbstractListModel>
#include <QList>
#include <QDate>
#include <QObject>

class GanttTaskItem;

class GanttModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QDate viewStartDate READ viewStartDate WRITE setViewStartDate NOTIFY viewDateChanged)
    Q_PROPERTY(QDate viewEndDate READ viewEndDate WRITE setViewEndDate NOTIFY viewDateChanged)
    Q_PROPERTY(int userId READ userId WRITE setUserId NOTIFY userIdChanged)
    Q_PROPERTY(int totalDays READ totalDays NOTIFY viewDateChanged)

public:
    enum GanttRoles {
        TaskIdRole = Qt::UserRole + 1,
        TitleRole,
        DescriptionRole,
        StartDateRole,
        EndDateRole,
        ProgressRole,
        PriorityRole,
        StatusRole,
        CategoryIdRole,
        CategoryNameRole,
        CategoryColorRole,
        AuthorRole,
        CreatedAtRole,
        ColorRole,
        StartOffsetRole,
        DurationRole,
        BarWidthRole
    };

    explicit GanttModel(QObject *parent = nullptr);
    ~GanttModel();

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    QDate viewStartDate() const;
    void setViewStartDate(const QDate &date);
    QDate viewEndDate() const;
    void setViewEndDate(const QDate &date);
    int userId() const;
    void setUserId(int userId);
    int totalDays() const;

    Q_INVOKABLE void loadTasks();
    Q_INVOKABLE void setDateRange(const QDate &start, const QDate &end);
    Q_INVOKABLE void moveToPreviousWeek();
    Q_INVOKABLE void moveToNextWeek();
    Q_INVOKABLE void moveToToday();
    Q_INVOKABLE bool updateTaskDates(int taskId, const QDate &startDate, const QDate &endDate);
    Q_INVOKABLE bool updateTaskProgress(int taskId, int progress);

signals:
    void viewDateChanged();
    void userIdChanged();
    void tasksLoaded(int count);

private:
    QString getPriorityColor(int priority) const;
    int calculateStartOffset(const QDate &taskStart) const;
    int calculateDuration(const QDate &start, const QDate &end) const;

    QList<GanttTaskItem*> m_tasks;
    QDate m_viewStartDate;
    QDate m_viewEndDate;
    int m_userId;
    int m_dayWidth;
};

class GanttTaskItem : public QObject
{
    Q_OBJECT

public:
    explicit GanttTaskItem(QObject *parent = nullptr);

    int taskId() const { return m_taskId; }
    void setTaskId(int id) { m_taskId = id; }

    QString title() const { return m_title; }
    void setTitle(const QString &title) { m_title = title; }

    QString description() const { return m_description; }
    void setDescription(const QString &desc) { m_description = desc; }

    QDate startDate() const { return m_startDate; }
    void setStartDate(const QDate &date) { m_startDate = date; }

    QDate endDate() const { return m_endDate; }
    void setEndDate(const QDate &date) { m_endDate = date; }

    int progress() const { return m_progress; }
    void setProgress(int progress) { m_progress = progress; }

    int priority() const { return m_priority; }
    void setPriority(int priority) { m_priority = priority; }

    int status() const { return m_status; }
    void setStatus(int status) { m_status = status; }

    int categoryId() const { return m_categoryId; }
    void setCategoryId(int id) { m_categoryId = id; }

    QString categoryName() const { return m_categoryName; }
    void setCategoryName(const QString &name) { m_categoryName = name; }

    QString categoryColor() const { return m_categoryColor; }
    void setCategoryColor(const QString &color) { m_categoryColor = color; }

    QString author() const { return m_author; }
    void setAuthor(const QString &author) { m_author = author; }

    QString createdAt() const { return m_createdAt; }
    void setCreatedAt(const QString &createdAt) { m_createdAt = createdAt; }

    QString color() const { return m_color; }
    void setColor(const QString &color) { m_color = color; }

private:
    int m_taskId;
    QString m_title;
    QString m_description;
    QDate m_startDate;
    QDate m_endDate;
    int m_progress;
    int m_priority;
    int m_status;
    int m_categoryId;
    QString m_categoryName;
    QString m_categoryColor;
    QString m_author;
    QString m_createdAt;
    QString m_color;
};

#endif // GANTTMODEL_H
