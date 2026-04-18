//数据纲要模组
#ifndef ABSTRACTCONTENTSMODEL_H
#define ABSTRACTCONTENTSMODEL_H

#include <QAbstractListModel>
#include <QString>
#include <QList>
#include <QVariantMap>

class AbstractContentsItem;

class AbstractContentsModel : public QAbstractListModel
{
    Q_OBJECT
    enum ContentRoles {
        IndexNumRole = Qt::UserRole + 1,
        TitleRole,
        AuthorRole,
        ContentRole,
        TimeRole,
        OutlineRole,
        CreatedAtRole,
        StartDateRole,
        DueDateRole,
        PriorityRole,
        CategoryIdRole,
        CategoryNameRole,
        CategoryColorRole,
        CompletedRole,
        TodaySelectedRole
    };
public:
    explicit AbstractContentsModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE bool loadAllFromDatabase(const QString &dbPath, bool todayOnly = false, bool completedOnly = false, const QString &sortField = "priority", bool sortDescending = true);
    Q_INVOKABLE QVariantMap get(int row) const;
    Q_INVOKABLE void updateOutline(int row, const QString &newOutline, const QString &dbPath);

private:
    QList<AbstractContentsItem*> m_contentList;
};

#endif
