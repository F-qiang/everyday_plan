import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import AuthManager 1.0

Rectangle {
    id: leftSidebar

    required property var mainWindowRef
    readonly property string searchText: searchInput.text

    x: 0
    y: 0
    width: left_rectangle_width
    height: mainWindowRef.height
    visible: true
    color: mainWindowRef.homeDarkMode ? "#2f343c" : "#ffffff"
    z: 3

    property int left_rectangle_width: 244
    property int hight_account_tangle: 78
    property int hight_searchinput: 30
    property int topBargin: 12
    property int sidebarSectionGap: 12
    readonly property int sidebarContentWidth: width

    Row {
        id: accountRow
        anchors.left: parent.left
        anchors.top: parent.top
        width: leftSidebar.width
        height: leftSidebar.hight_account_tangle
        spacing: 0

        Rectangle {
            id: accountTangle
            visible: true
            readonly property bool loginPrompt: !AuthManager.isLoggedIn
            readonly property bool settingsActive: mainWindowRef.settingsVisible && AuthManager.isLoggedIn
            color: settingsActive ? "#1e3a5f" : (loginPrompt ? (loginHoverArea.containsMouse ? "#f8fafc" : "#ffffff") : "#ffffff")
            width: parent.width
            height: parent.height
            border.color: settingsActive ? "#60a5fa" : (loginPrompt ? (loginHoverArea.containsMouse ? "#60a5fa" : "#93c5fd") : "#d8dee8")
            border.width: settingsActive || loginPrompt ? 2 : 1

            Behavior on color { ColorAnimation { duration: 140 } }
            Behavior on border.color { ColorAnimation { duration: 140 } }

            Rectangle {
                id: loginPulse
                anchors.fill: parent
                visible: accountTangle.loginPrompt
                radius: 0
                color: "#93c5fd"
                opacity: 0.08
                z: 0

                SequentialAnimation on opacity {
                    running: accountTangle.loginPrompt && !loginHoverArea.containsMouse
                    loops: Animation.Infinite
                    NumberAnimation { from: 0.05; to: 0.14; duration: 1150; easing.type: Easing.InOutQuad }
                    NumberAnimation { from: 0.14; to: 0.05; duration: 1150; easing.type: Easing.InOutQuad }
                }
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: accountTangle.loginPrompt ? 1 : 0
                radius: 0
                color: "transparent"
                visible: accountTangle.loginPrompt
                border.color: "transparent"

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 10
                    height: 42
                    radius: 14
                    color: "#ffffff"
                    border.color: loginHoverArea.containsMouse ? "#cbd5e1" : "#d8dee8"
                    border.width: 1
                    opacity: 0.98

                    Behavior on border.color { ColorAnimation { duration: 140 } }
                }
            }

            MouseArea {
                id: loginHoverArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: mainWindowRef.showSettings()
                cursorShape: Qt.PointingHandCursor
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    spacing: 3

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Text {
                            text: AuthManager.isLoggedIn ? AuthManager.currentUserNickname : "未登录账号"
                            font.pixelSize: 16
                            font.bold: true
                            color: accountTangle.settingsActive ? "#f8fafc" : "#0f172a"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignTop
                        }

                        Button {
                            visible: AuthManager.isLoggedIn
                            text: mainWindowRef.sidebarBackupJustCompleted ? "已备份" : "备份"
                            font.pixelSize: 11
                            enabled: !mainWindowRef.settingsVisible
                            opacity: mainWindowRef.settingsVisible ? 0.55 : 1
                            implicitHeight: 28
                            implicitWidth: mainWindowRef.sidebarBackupJustCompleted ? 72 : 68
                            Layout.alignment: Qt.AlignTop
                            hoverEnabled: true
                            background: Rectangle {
                                radius: 14
                                color: parent.down ? (accountTangle.settingsActive ? "#2f435c" : "#eef4fb") : (parent.hovered ? (accountTangle.settingsActive ? "#2b4158" : "#f6f9fc") : (accountTangle.settingsActive ? "#284059" : "#f8fbff"))
                                border.color: mainWindowRef.sidebarBackupJustCompleted ? (accountTangle.settingsActive ? "#9dd6b8" : "#86cfa9") : (accountTangle.settingsActive ? "#5f7fa3" : "#d7e5f5")
                                border.width: 1
                            }
                            contentItem: Row {
                                spacing: 5
                                anchors.centerIn: parent
                                Text { text: mainWindowRef.sidebarBackupJustCompleted ? "✓" : "↓"; font.pixelSize: 12; color: mainWindowRef.sidebarBackupJustCompleted ? (accountTangle.settingsActive ? "#d7f5e3" : "#2f855a") : (accountTangle.settingsActive ? "#dbeafe" : "#5b7da6") }
                                Text { text: parent.parent.text; font.pixelSize: 11; font.bold: mainWindowRef.sidebarBackupJustCompleted; color: mainWindowRef.sidebarBackupJustCompleted ? (accountTangle.settingsActive ? "#eafbf0" : "#2f855a") : (accountTangle.settingsActive ? "#e5eefb" : "#4f6f96"); verticalAlignment: Text.AlignVCenter }
                            }
                            onClicked: mainWindowRef.runBackupExport()
                        }
                    }

                    Text {
                        text: AuthManager.isLoggedIn ? AuthManager.currentUserEmail : "点击登录后同步任务与分类"
                        font.pixelSize: 10
                        color: accountTangle.settingsActive ? "#9fb4d1" : (accountTangle.loginPrompt ? (loginHoverArea.containsMouse ? "#4f86c6" : "#6b8bb5") : "#94a3b8")
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                Rectangle {
                    visible: accountTangle.loginPrompt
                    Layout.alignment: Qt.AlignVCenter
                    implicitWidth: loginPillRow.implicitWidth + 18
                    implicitHeight: 24
                    radius: 999
                    color: loginHoverArea.containsMouse ? "#2563eb" : "#eff6ff"
                    border.color: loginHoverArea.containsMouse ? "#1d4ed8" : "#93c5fd"
                    border.width: 1

                    RowLayout {
                        id: loginPillRow
                        anchors.centerIn: parent
                        spacing: 4
                        Text { text: "登录"; font.pixelSize: 10; font.bold: true; color: loginHoverArea.containsMouse ? "#ffffff" : "#1d4ed8" }
                        Text { text: "→"; font.pixelSize: 12; font.bold: true; color: loginHoverArea.containsMouse ? "#ffffff" : "#1d4ed8" }
                    }
                }
            }
        }
    }

    TextField {
        id: searchInput
        x: 0
        y: accountRow.y + accountRow.height + leftSidebar.topBargin
        width: leftSidebar.sidebarContentWidth
        height: leftSidebar.hight_searchinput + 4
        placeholderText: mainWindowRef.t("搜索任务标题或概要", "Search titles or summaries")
        anchors.top: accountRow.bottom
        anchors.topMargin: leftSidebar.topBargin
        font.pixelSize: 15
        leftPadding: 10
        rightPadding: 10
        color: "#0f172a"
        selectedTextColor: "#eff6ff"
        selectionColor: "#3b82f6"
        background: Rectangle { radius: 12; color: "#ffffff"; border.color: "#d8dee8"; border.width: 1 }
    }

    ToolBar {
        id: toolBar
        width: leftSidebar.sidebarContentWidth
        height: toolBarColumn.implicitHeight
        anchors.top: searchInput.bottom
        anchors.topMargin: leftSidebar.sidebarSectionGap
        background: Rectangle { color: "transparent"; border.width: 0 }

        ColumnLayout {
            id: toolBarColumn
            anchors.fill: parent
            spacing: 6
            MainNavToolButton { text: mainWindowRef.t("今日任务", "Today"); navFontSize: mainWindowRef.navFontSize; height: 32; checked: !mainWindowRef.settingsVisible && !mainWindowRef.newTaskVisible && !mainWindowRef.newCategoryVisible && mainWindowRef.currentPageType === mainWindowRef.pageToday; Layout.fillHeight: false; display: AbstractButton.TextBesideIcon; onClicked: mainWindowRef.showTodayTasks() }
            MainNavToolButton { text: mainWindowRef.t("全部任务", "All Tasks"); navFontSize: mainWindowRef.navFontSize; height: 32; checked: !mainWindowRef.settingsVisible && !mainWindowRef.newTaskVisible && !mainWindowRef.newCategoryVisible && mainWindowRef.currentPageType === mainWindowRef.pageAllTasks; icon.height: 17; icon.width: 17; icon.color: "#00000000"; onClicked: mainWindowRef.showAllTasks() }
            MainNavToolButton { text: mainWindowRef.t("已完成", "Completed"); navFontSize: mainWindowRef.navFontSize; height: 32; checked: !mainWindowRef.settingsVisible && !mainWindowRef.newTaskVisible && !mainWindowRef.newCategoryVisible && mainWindowRef.currentPageType === mainWindowRef.pageCompleted; icon.height: 17; icon.width: 17; icon.color: "#00000000"; onClicked: mainWindowRef.showCompletedTasks() }
            MainNavToolButton { text: mainWindowRef.t("甘特图", "Gantt"); navFontSize: mainWindowRef.navFontSize; height: 32; checked: !mainWindowRef.settingsVisible && !mainWindowRef.newTaskVisible && !mainWindowRef.newCategoryVisible && mainWindowRef.currentPageType === mainWindowRef.pageGantt; icon.height: 17; icon.width: 17; onClicked: mainWindowRef.showGanttChart() }
        }
    }

    CategoryListPanel {
        width: searchInput.width
        anchors.top: toolBar.bottom
        anchors.topMargin: leftSidebar.sidebarSectionGap
        anchors.left: parent.left
        anchors.bottom: toolBar1.top
        anchors.bottomMargin: leftSidebar.sidebarSectionGap
        homeDarkMode: mainWindowRef.homeDarkMode
        categories: mainWindowRef.categoryList
        selectedCategoryId: mainWindowRef.newCategoryVisible ? mainWindowRef.editingCategoryId : (mainWindowRef.settingsVisible ? -1 : mainWindowRef.activeCategoryId)
        titleText: mainWindowRef.currentPageType === mainWindowRef.pageGantt ? mainWindowRef.t("甘特图分类", "Gantt Categories") : mainWindowRef.t("已有分类", "Categories")
        onCategorySelected: function(categoryId, categoryName) { mainWindowRef.showCategoryTasks(categoryId, categoryName); mainWindowRef.openCategoryEditor(categoryId) }
        onCreateCategoryRequested: mainWindowRef.showNewCategoryForm()
    }

    ToolBar {
        id: toolBar1
        width: leftSidebar.sidebarContentWidth
        height: 38
        anchors.bottom: parent.bottom
        anchors.bottomMargin: leftSidebar.sidebarSectionGap + 2
        background: Rectangle { color: "transparent"; border.width: 0 }
        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            MainNavToolButton { text: mainWindowRef.t("新建任务", "New Task"); navFontSize: mainWindowRef.navFontSize; checked: mainWindowRef.newTaskVisible; implicitHeight: 30; Layout.alignment: Qt.AlignLeft | Qt.AlignTop; onClicked: mainWindowRef.showNewTaskForm() }
        }
    }
}
