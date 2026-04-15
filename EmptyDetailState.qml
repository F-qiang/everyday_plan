import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    property bool homeDarkMode: true
    property int detailFontSize: 20
    property color detailTextColor: "#0f172a"
    property color detailHintTextColor: "#64748b"
    property var tFunc

    Layout.fillWidth: true
    Layout.fillHeight: true

    ColumnLayout {
        id: emptyStateColumn
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 28
        width: Math.min(parent.width * 0.72, 420)
        spacing: 14

        Rectangle {
            id: welcomeCard
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            implicitHeight: welcomeCardContent.implicitHeight + 44
            radius: 20
            color: root.homeDarkMode ? "#334155" : "#f8fbff"
            border.color: root.homeDarkMode ? "#475569" : "#dbe7f5"
            border.width: 1

            ColumnLayout {
                id: welcomeCardContent
                anchors.fill: parent
                anchors.margins: 22
                spacing: 14

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 54
                    height: 54
                    radius: 18
                    color: root.homeDarkMode ? "#1e293b" : "#eef4ff"
                    border.color: root.homeDarkMode ? "#475569" : "#c7d2fe"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "◫"
                        color: root.homeDarkMode ? "#bfdbfe" : "#2563eb"
                        font.pixelSize: 24
                        font.bold: true
                    }
                }

                Label {
                    Layout.fillWidth: true
                    text: root.tFunc("欢迎来到任务详情区", "Welcome to the detail view")
                    color: root.detailTextColor
                    font.pixelSize: root.detailFontSize
                    font.bold: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }

                Label {
                    Layout.fillWidth: true
                    text: root.tFunc("从左侧列表点选一个任务，这里会立即显示完整信息与可编辑内容。", "Pick a task from the list on the left and its full details will appear here instantly.")
                    color: root.detailHintTextColor
                    font.pixelSize: Math.max(11, root.detailFontSize - 7)
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: hintRow.implicitHeight + 18
                    radius: 14
                    color: root.homeDarkMode ? "#1f2937" : "#ffffff"
                    border.color: root.homeDarkMode ? "#475569" : "#d8dee8"
                    border.width: 1

                    RowLayout {
                        id: hintRow
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: root.homeDarkMode ? "#93c5fd" : "#2563eb"
                            Layout.alignment: Qt.AlignTop
                        }

                        Label {
                            Layout.fillWidth: true
                            text: root.tFunc("你可以在右侧查看标题、时间、概要、附件与正文内容；保存和删除按钮会在选中任务后出现在顶部。", "You can review title, dates, summary, attachments, and content here. Save and delete buttons appear at the top after a task is selected.")
                            color: root.detailHintTextColor
                            font.pixelSize: Math.max(11, root.detailFontSize - 8)
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }
    }
}
