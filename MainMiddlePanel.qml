import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    property color pageBaseColor: "#ffffff"
    property bool homeDarkMode: false
    property bool ganttMode: false
    property bool settingsVisible: false
    property string pageTitle: ""
    property color detailHintTextColor: "#94a3b8"
    property string searchKeyword: ""
    property int selectedCategoryId: -1
    signal itemSelected(int taskId, string title, string outline, string content, string time, string startDate, string author, string createdAt, string dueDate, int priority, int categoryId, string categoryName, string categoryColor, bool completed)

    x: 0
    height: parent ? parent.height : 0
    visible: true
    color: pageBaseColor
    clip: true

    Behavior on width {
        NumberAnimation { duration: 260; easing.type: Easing.InOutQuad }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            radius: 12
            color: homeDarkMode ? "#3a4049" : "#ffffff"
            border.color: homeDarkMode ? "#4b5563" : "#d8dee8"
            border.width: 1
            visible: root.width > 0

            readonly property bool abstractVisible: !root.ganttMode && !root.settingsVisible

            MouseArea {
                anchors.fill: parent
                enabled: false
                cursorShape: Qt.ArrowCursor
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                Label {
                    text: root.pageTitle
                    color: homeDarkMode ? "#f3f4f6" : "#0f172a"
                    font.pixelSize: 18
                    font.bold: true
                }

                Label {
                    visible: parent.parent.abstractVisible
                    text: qsTr("可直接点击标题选择任务")
                    color: root.detailHintTextColor
                    font.pixelSize: 12
                }

                Item { Layout.fillWidth: true }
            }
        }

        AbstractContents {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !root.ganttMode && !root.settingsVisible
            searchKeyword: root.searchKeyword
            selectedCategoryId: root.selectedCategoryId
            onItemSelected: (taskId, title, outline, content, time, startDate, author, createdAt, dueDate, priority, categoryId, categoryName, categoryColor, completed) =>
                                root.itemSelected(taskId, title, outline, content, time, startDate, author, createdAt, dueDate, priority, categoryId, categoryName, categoryColor, completed)
        }
    }
}
