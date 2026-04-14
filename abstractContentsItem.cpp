#include "abstractContentsItem.h"

AbstractContentsItem::AbstractContentsItem(QObject *parent)
    : QObject(parent)
    , m_title("默认标题")
    , m_author("默认作者")
    , m_content("默认内容")
    , m_time(QDateTime::currentDateTime())
    , m_outline("默认大纲")
    , m_createdAt("")
    , m_startDate("")
    , m_dueDate("")
    , m_priority(1)
    , m_categoryId(0)
    , m_categoryName("")
    , m_categoryColor("#94a3b8")
    , m_completed(false)
{
}

int AbstractContentsItem::index_num() const { return m_index_num; }
void AbstractContentsItem::setIndex_num(int index) { if (m_index_num != index) { m_index_num = index; emit index_numChanged(); } }
QString AbstractContentsItem::title() const { return m_title; }
void AbstractContentsItem::setTitle(const QString &title) { if (m_title != title) { m_title = title; emit titleChanged(); } }
QString AbstractContentsItem::author() const { return m_author; }
void AbstractContentsItem::setAuthor(const QString &author) { if (m_author != author) { m_author = author; emit authorChanged(); } }
QString AbstractContentsItem::content() const { return m_content; }
void AbstractContentsItem::setContent(const QString &content) { if (m_content != content) { m_content = content; emit contentChanged(); } }
QDateTime AbstractContentsItem::time() const { return m_time; }
void AbstractContentsItem::setTime(const QDateTime &time) { if (m_time != time) { m_time = time; emit timeChanged(); } }
QString AbstractContentsItem::outline() const { return m_outline; }
void AbstractContentsItem::setOutline(const QString &outline) { if (m_outline != outline) { m_outline = outline; emit outlineChanged(); } }
QString AbstractContentsItem::createdAt() const { return m_createdAt; }
void AbstractContentsItem::setCreatedAt(const QString &createdAt) { if (m_createdAt != createdAt) { m_createdAt = createdAt; emit createdAtChanged(); } }
QString AbstractContentsItem::startDate() const { return m_startDate; }
void AbstractContentsItem::setStartDate(const QString &startDate) { if (m_startDate != startDate) { m_startDate = startDate; emit startDateChanged(); } }
QString AbstractContentsItem::dueDate() const { return m_dueDate; }
void AbstractContentsItem::setDueDate(const QString &dueDate) { if (m_dueDate != dueDate) { m_dueDate = dueDate; emit dueDateChanged(); } }
int AbstractContentsItem::priority() const { return m_priority; }
void AbstractContentsItem::setPriority(int priority) { if (m_priority != priority) { m_priority = priority; emit priorityChanged(); } }
int AbstractContentsItem::categoryId() const { return m_categoryId; }
void AbstractContentsItem::setCategoryId(int categoryId) { if (m_categoryId != categoryId) { m_categoryId = categoryId; emit categoryIdChanged(); } }
QString AbstractContentsItem::categoryName() const { return m_categoryName; }
void AbstractContentsItem::setCategoryName(const QString &categoryName) { if (m_categoryName != categoryName) { m_categoryName = categoryName; emit categoryNameChanged(); } }
QString AbstractContentsItem::categoryColor() const { return m_categoryColor; }
void AbstractContentsItem::setCategoryColor(const QString &categoryColor) { if (m_categoryColor != categoryColor) { m_categoryColor = categoryColor; emit categoryColorChanged(); } }
bool AbstractContentsItem::completed() const { return m_completed; }
void AbstractContentsItem::setCompleted(bool completed) { if (m_completed != completed) { m_completed = completed; emit completedChanged(); } }
