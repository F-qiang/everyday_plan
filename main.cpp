#include <QQmlContext>
#include <QQmlEngine>
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QIcon>

#include "abstractcontentsmodel.h"
#include "databasemanager.h"
#include "authmanager.h"
#include "ganttmodel.h"
#include "oneDriveManager.h"
#include "notificationmanager.h"

int main(int argc, char *argv[])
{
    QQuickStyle::setStyle("Basic");
    QApplication app(argc, argv);
    const QIcon appIcon(QStringLiteral(":/qt/qml/everyday_day/assets/ep_app_icon.ico"));
    app.setWindowIcon(appIcon);

    // 初始化数据库
    DatabaseManager::instance()->initialize("./data.db");
    
    // 清理过期验证码
    DatabaseManager::instance()->cleanExpiredCodes();

    QQmlApplicationEngine engine;
    
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    // 注册 C++ 类为 QML 类型
    
    // 原有模型
    qmlRegisterType<AbstractContentsModel>("AbstractContentsModel", 1, 0, "AbstractContent");
    
    // 新增：数据库管理器（单例）
    qmlRegisterSingletonInstance<DatabaseManager>("DatabaseManager", 1, 0, "DatabaseManager", 
                                                    DatabaseManager::instance());
    
    // 新增：认证管理器（单例）
    qmlRegisterSingletonInstance<AuthManager>("AuthManager", 1, 0, "AuthManager",
                                               AuthManager::instance());

    qmlRegisterSingletonInstance<OneDriveManager>("OneDriveManager", 1, 0, "OneDriveManager",
                                                   OneDriveManager::instance());

    qmlRegisterSingletonInstance<NotificationManager>("NotificationManager", 1, 0, "NotificationManager",
                                                      new NotificationManager(&app));
    
    // 新增：甘特图模型
    qmlRegisterType<GanttModel>("GanttModel", 1, 0, "GanttModelType");

    // 创建模型实例，并设置为 QML 上下文属性
    AbstractContentsModel *abstractContentsModel = new AbstractContentsModel(&app);
    engine.rootContext()->setContextProperty("AbstractContentsModel", abstractContentsModel);

    // 创建甘特图模型实例
    GanttModel *ganttModel = new GanttModel(&app);
    engine.rootContext()->setContextProperty("GanttModel", ganttModel);

    // 加载 QML 文件
    engine.loadFromModule("everyday_day", "Main");

    return app.exec();
}
