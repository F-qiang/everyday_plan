#include "notificationmanager.h"

#include <QAction>
#include <QApplication>
#include <QMenu>
#include <QStyle>
#include <QIcon>

NotificationManager::NotificationManager(QObject *parent)
    : QObject(parent)
{
    m_available = QSystemTrayIcon::isSystemTrayAvailable();
    if (!m_available) {
        return;
    }

    m_trayIcon.setIcon(QIcon(QStringLiteral(":/qt/qml/everyday_plan/assets/ep_app_icon.ico")));
    m_trayIcon.setToolTip(QStringLiteral("Everyday Plan"));

    m_trayMenu = new QMenu();
    m_restoreAction = m_trayMenu->addAction(QStringLiteral("显示主窗口"));
    m_exitAction = m_trayMenu->addAction(QStringLiteral("退出程序"));

    QObject::connect(m_restoreAction, &QAction::triggered, this, &NotificationManager::restoreRequested);
    QObject::connect(m_exitAction, &QAction::triggered, this, &NotificationManager::exitRequested);
    QObject::connect(&m_trayIcon, &QSystemTrayIcon::activated, this, [this](QSystemTrayIcon::ActivationReason reason) {
        if (reason == QSystemTrayIcon::Trigger || reason == QSystemTrayIcon::DoubleClick) {
            emit restoreRequested();
        }
    });

    m_trayIcon.setContextMenu(m_trayMenu);
    m_trayIcon.show();
}

NotificationManager::~NotificationManager()
{
    if (m_trayIcon.isVisible()) {
        m_trayIcon.hide();
    }
    delete m_trayMenu;
}

bool NotificationManager::available() const
{
    return m_available;
}

void NotificationManager::playSystemAlertSound()
{
    QApplication::beep();
}

void NotificationManager::showNotification(const QString &title, const QString &message)
{
    if (!m_available) {
        return;
    }

    if (!m_trayIcon.isVisible()) {
        m_trayIcon.show();
    }

    m_trayIcon.setIcon(QIcon(QStringLiteral(":/qt/qml/everyday_plan/assets/ep_app_icon.ico")));
    m_trayIcon.showMessage(title, message, QSystemTrayIcon::NoIcon, 6000);
}

void NotificationManager::showReminderNotification(const QString &taskTitle, const QString &taskOutline, const QString &reminderTime)
{
    const QString safeTitle = taskTitle.trimmed().isEmpty() ? QStringLiteral("未命名任务") : taskTitle.trimmed();
    const QString safeOutline = taskOutline.trimmed();
    const QString safeTime = reminderTime.trimmed();

    QStringList lines;
    lines << QStringLiteral("标题：") + safeTitle;
    if (!safeOutline.isEmpty()) {
        lines << QStringLiteral("概要：") + safeOutline;
    }
    if (!safeTime.isEmpty()) {
        lines << QStringLiteral("提醒时间：") + safeTime;
    }

    playSystemAlertSound();
    showNotification(QStringLiteral("Everyday Plan 任务提醒"), lines.join(QStringLiteral("\n")));
}

void NotificationManager::showTrayHint()
{
    if (!m_available || m_trayHintShown) {
        return;
    }

    m_trayHintShown = true;
    showNotification(QStringLiteral("Everyday Plan"), QStringLiteral("主窗口已隐藏到系统托盘，提醒功能会继续运行。"));
}
