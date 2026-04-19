cmake_minimum_required(VERSION 3.16)

project(everyday_plan VERSION 0.2 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 查找 Qt6 必需模块
find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 Sql Network Widgets)

# Qt6 自动 MOC/RCC/UIC
qt_standard_project_setup(REQUIRES 6.5)

# 生成可执行文件
qt_add_executable(appeveryday_plan
    main.cpp
    windows.rc
)

# 配置 QML 模块
qt_add_qml_module(appeveryday_plan
    URI everyday_plan
    VERSION 1.0

    QML_FILES
        Main.qml
        AbstractContents.qml
        ContensElement.qml
        LoginWindow.qml
        GanttChart.qml
        GanttHeader.qml
        GanttTaskBar.qml
        SettingsPanel.qml
        NewTaskDialog.qml
        NewCategoryDialog.qml
        CategoryListPanel.qml
        MainNavToolButton.qml
        MainSidebar.qml
        MainMiddlePanel.qml
        MainRightShell.qml
        DetailHeaderBar.qml
        EmptyDetailState.qml
        DetailMetaSection.qml
        DetailEditingSection.qml

    RESOURCES
        assets/ep_app_icon.svg
        assets/ep_app_icon.ico

    SOURCES
        abstractContentsItem.cpp
        abstractContentsItem.h
        abstractcontentsmodel.cpp
        abstractcontentsmodel.h
        databasemanager.cpp
        databasemanager.h
        authmanager.cpp
        authmanager.h
        ganttmodel.cpp
        ganttmodel.h
        oneDriveManager.cpp
        oneDriveManager.h
        oneDriveAppConfig.cpp
        oneDriveAppConfig.h
        notificationmanager.cpp
        notificationmanager.h


)

# 设置目标程序属性
set_target_properties(appeveryday_plan PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
    QT_TARGET_RC_ICONS "${CMAKE_CURRENT_SOURCE_DIR}/assets/ep_app_icon.ico"
)

# 链接 Qt6 模块
target_link_libraries(appeveryday_plan
    PRIVATE Qt6::Quick
    PRIVATE Qt6::QuickControls2
    PRIVATE Qt6::Sql
    PRIVATE Qt6::Network
    PRIVATE Qt6::Widgets
)

include(GNUInstallDirs)
install(TARGETS appeveryday_plan
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

