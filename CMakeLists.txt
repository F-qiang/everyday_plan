cmake_minimum_required(VERSION 3.16)

project(everyday_day VERSION 0.2 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 查找 Qt6 必需模块
find_package(Qt6 REQUIRED COMPONENTS Quick Sql Network)

# Qt6 自动 MOC/RCC/UIC
qt_standard_project_setup(REQUIRES 6.5)

# 生成可执行文件
qt_add_executable(appeveryday_day
    main.cpp
)

# 配置 QML 模块
qt_add_qml_module(appeveryday_day
    URI everyday_day
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
        DetailHeaderBar.qml
        EmptyDetailState.qml
        DetailMetaSection.qml
        DetailEditingSection.qml

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


)

# 设置目标程序属性
set_target_properties(appeveryday_day PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

# 链接 Qt6 模块
target_link_libraries(appeveryday_day
    PRIVATE Qt6::Quick
    PRIVATE Qt6::Sql
    PRIVATE Qt6::Network
)

include(GNUInstallDirs)
install(TARGETS appeveryday_day
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
