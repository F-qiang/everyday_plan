#ifndef NOTIFICATIONMANAGER_H
#define NOTIFICATIONMANAGER_H

#include <QObject>
#include <QSystemTrayIcon>

class QMenu;
class QAction;

class NotificationManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool available READ available NOTIFY availableChanged)

public:
    explicit NotificationManager(QObject *parent = nullptr);
    ~NotificationManager() override;

    bool available() const;

    Q_INVOKABLE void showNotification(const QString &title, const QString &message);
    Q_INVOKABLE void showReminderNotification(const QString &taskTitle, const QString &taskOutline, const QString &reminderTime);
    Q_INVOKABLE void showTrayHint();
    Q_INVOKABLE void playSystemAlertSound();

signals:
    void availableChanged();
    void restoreRequested();
    void exitRequested();

private:
    QSystemTrayIcon m_trayIcon;
    QMenu *m_trayMenu = nullptr;
    QAction *m_restoreAction = nullptr;
    QAction *m_exitAction = nullptr;
    bool m_available = false;
    bool m_trayHintShown = false;
};

#endif
