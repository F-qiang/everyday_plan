//单条数据纲要
#ifndef ABSTRACTCONTENTSITEM_H
#define ABSTRACTCONTENTSITEM_H

#include <QObject>
#include <QDateTime>
#include <QString>
#include <QDebug>

class AbstractContentsItem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int index_num READ index_num WRITE setIndex_num NOTIFY index_numChanged)
    Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)
    Q_PROPERTY(QString author READ author WRITE setAuthor NOTIFY authorChanged)
    Q_PROPERTY(QString content READ content WRITE setContent NOTIFY contentChanged)
    Q_PROPERTY(QDateTime time READ time WRITE setTime NOTIFY timeChanged)
    Q_PROPERTY(QString outline READ outline WRITE setOutline NOTIFY outlineChanged)
    Q_PROPERTY(QString createdAt READ createdAt WRITE setCreatedAt NOTIFY createdAtChanged)
    Q_PROPERTY(QString startDate READ startDate WRITE setStartDate NOTIFY startDateChanged)
    Q_PROPERTY(QString dueDate READ dueDate WRITE setDueDate NOTIFY dueDateChanged)
    Q_PROPERTY(int priority READ priority WRITE setPriority NOTIFY priorityChanged)
    Q_PROPERTY(int categoryId READ categoryId WRITE setCategoryId NOTIFY categoryIdChanged)
    Q_PROPERTY(QString categoryName READ categoryName WRITE setCategoryName NOTIFY categoryNameChanged)
    Q_PROPERTY(QString categoryColor READ categoryColor WRITE setCategoryColor NOTIFY categoryColorChanged)
    Q_PROPERTY(bool completed READ completed WRITE setCompleted NOTIFY completedChanged)
    Q_PROPERTY(bool todaySelected READ todaySelected WRITE setTodaySelected NOTIFY todaySelectedChanged)
    Q_PROPERTY(bool todaySelected READ todaySelected WRITE setTodaySelected NOTIFY todaySelectedChanged)

public:
    explicit AbstractContentsItem(QObject *parent = nullptr);

    int index_num() const;
    void setIndex_num(int index);
    QString title() const;
    void setTitle(const QString &title);
    QString author() const;
    void setAuthor(const QString &author);
    QString content() const;
    void setContent(const QString &content);
    QDateTime time() const;
    void setTime(const QDateTime &time);
    QString outline() const;
    void setOutline(const QString &outline);
    QString createdAt() const;
    void setCreatedAt(const QString &createdAt);
    QString startDate() const;
    void setStartDate(const QString &startDate);
    QString dueDate() const;
    void setDueDate(const QString &dueDate);
    int priority() const;
    void setPriority(int priority);
    int categoryId() const;
    void setCategoryId(int categoryId);
    QString categoryName() const;
    void setCategoryName(const QString &categoryName);
    QString categoryColor() const;
    void setCategoryColor(const QString &categoryColor);
    bool completed() const;
    bool todaySelected() const;
    void setTodaySelected(bool todaySelected);
    void setCompleted(bool completed);

signals:
    void index_numChanged();
    void titleChanged();
    void authorChanged();
    void contentChanged();
    void timeChanged();
    void outlineChanged();
    void createdAtChanged();
    void startDateChanged();
    void dueDateChanged();
    void priorityChanged();
    void categoryIdChanged();
    void categoryNameChanged();
    void categoryColorChanged();
    void todaySelectedChanged();
    void completedChanged();

private:
    int m_index_num = 0;
    QString m_title;
    QString m_author;
    QString m_content;
    QDateTime m_time;
    QString m_outline;
    QString m_createdAt;
    QString m_startDate;
    QString m_dueDate;
    int m_priority = 1;
    int m_categoryId = 0;
    QString m_categoryName;
    QString m_categoryColor = "#94a3b8";
    bool m_todaySelected = false;
    bool m_completed = false;
};

#endif
