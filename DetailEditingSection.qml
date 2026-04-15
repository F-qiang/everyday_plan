import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: root

    property bool visibleSection: true
    property bool homeDarkMode: true
    property int detailFontSize: 20
    property string editTaskOutline: ""
    property string editTaskContent: ""
    property bool editTaskCompleted: false
    property color detailTextColor: "#0f172a"
    property color detailHintTextColor: "#64748b"
    property color detailMutedTextColor: "#475569"
    property color detailBorderColor: "#d8dee8"
    property color detailAccentColor: "#2563eb"
    property color detailOnAccentColor: "#ffffff"
    property var tFunc
    property var contentIsImageFunc
    property var contentIsFileFunc
    signal outlineEdited(string value)
    signal contentEdited(string value)
    signal completedEdited(bool value)

    visible: visibleSection
    Layout.fillWidth: true
    spacing: 8

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 144
        radius: 12
        color: root.homeDarkMode ? "#323945" : "#fcfaf5"
        border.color: root.detailBorderColor
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 6

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Rectangle {
                    width: 3
                    height: 24
                    radius: 1.5
                    color: root.detailAccentColor
                    Layout.alignment: Qt.AlignVCenter
                }

                Label {
                    text: qsTr("概要")
                    color: root.detailTextColor
                    font.pixelSize: Math.max(13, root.detailFontSize - 5)
                    font.bold: true
                    Layout.alignment: Qt.AlignVCenter
                }

                Label {
                    text: qsTr("支持修改摘要说明，正文为空时会自动复用概要")
                    color: root.detailHintTextColor
                    font.pixelSize: Math.max(11, root.detailFontSize - 8)
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            TextArea {
                Layout.fillWidth: true
                Layout.fillHeight: true
                wrapMode: TextEdit.Wrap
                text: root.editTaskOutline
                onTextChanged: root.outlineEdited(text)
                color: root.detailTextColor
                placeholderText: root.tFunc("请输入概要说明", "Enter summary")
                selectedTextColor: root.detailOnAccentColor
                selectionColor: root.detailAccentColor
                topPadding: 14
                bottomPadding: 14
                leftPadding: 14
                rightPadding: 14

                background: Rectangle {
                    color: root.homeDarkMode ? "#313b47" : "#fbfdff"
                    radius: 12
                    border.color: parent.activeFocus ? (root.homeDarkMode ? "#6d8299" : "#c9d9e8") : root.detailBorderColor
                    border.width: 1

                    Rectangle {
                        anchors.fill: parent
                        radius: 12
                        color: root.detailAccentColor
                        opacity: parent.parent.activeFocus ? (root.homeDarkMode ? 0.045 : 0.028) : 0
                    }
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        radius: 12
        color: root.editTaskCompleted ? (root.homeDarkMode ? "#173a2d" : "#edf9f1") : (root.homeDarkMode ? "#423225" : "#fff6ea")
        border.color: root.editTaskCompleted ? (root.homeDarkMode ? "#3fbf89" : "#9adbb8") : (root.homeDarkMode ? "#f2a365" : "#f6c48a")

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 6

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    width: 22
                    height: 22
                    radius: 11
                    color: root.editTaskCompleted ? (root.homeDarkMode ? "#1f5a42" : "#dcfce7") : (root.homeDarkMode ? "#5a4026" : "#ffedd5")
                    border.color: root.editTaskCompleted ? (root.homeDarkMode ? "#4ade80" : "#86efac") : "#fdba74"
                    border.width: 1
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        anchors.centerIn: parent
                        text: root.editTaskCompleted ? "✓" : "·"
                        color: root.editTaskCompleted ? (root.homeDarkMode ? "#bbf7d0" : "#15803d") : (root.homeDarkMode ? "#fed7aa" : "#c2410c")
                        font.pixelSize: root.editTaskCompleted ? 12 : 18
                        font.bold: root.editTaskCompleted
                    }
                }

                Label {
                    text: root.editTaskCompleted ? root.tFunc("当前状态：已完成", "Status: Completed") : root.tFunc("当前状态：未完成", "Status: Incomplete")
                    color: root.editTaskCompleted ? (root.homeDarkMode ? "#bbf7d0" : "#166534") : (root.homeDarkMode ? "#fed7aa" : "#9a3412")
                    font.pixelSize: Math.max(12, root.detailFontSize - 6)
                    font.bold: true
                }

                Item { Layout.fillWidth: true }
            }

            Label {
                Layout.fillWidth: true
                text: root.editTaskCompleted ? root.tFunc("任务已完成，可随时切回未完成状态。", "This task is completed. You can switch it back anytime.") : root.tFunc("任务仍在进行中，完成后可切换状态。", "This task is still in progress. Mark it complete when finished.")
                color: root.detailHintTextColor
                wrapMode: Text.WordWrap
                font.pixelSize: Math.max(11, root.detailFontSize - 8)
                bottomPadding: 6
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Item { Layout.fillWidth: true }

                Button {
                    text: root.editTaskCompleted ? root.tFunc("设为未完成", "Mark incomplete") : root.tFunc("设为完成", "Mark complete")
                    implicitWidth: 126
                    implicitHeight: 36
                    onClicked: root.completedEdited(!root.editTaskCompleted)
                }
            }
        }
    }

    TextArea {
        Layout.fillWidth: true
        Layout.minimumHeight: 156
        wrapMode: TextEdit.Wrap
        visible: !root.contentIsImageFunc(root.editTaskContent) && !root.contentIsFileFunc(root.editTaskContent)
        text: root.editTaskContent
        onTextChanged: root.contentEdited(text)
        color: root.detailTextColor
        selectedTextColor: root.detailOnAccentColor
        selectionColor: root.detailAccentColor
        placeholderText: root.tFunc("请输入正文或附件路径", "Enter content or attachment path")
        topPadding: 14
        bottomPadding: 14
        leftPadding: 14
        rightPadding: 14

        background: Rectangle {
            color: root.homeDarkMode ? "#313b47" : "#fbfdff"
            radius: 12
            border.color: parent.activeFocus ? (root.homeDarkMode ? "#6d8299" : "#c9d9e8") : root.detailBorderColor
            border.width: 1

            Rectangle {
                anchors.fill: parent
                radius: 12
                color: root.detailAccentColor
                opacity: parent.parent.activeFocus ? (root.homeDarkMode ? 0.045 : 0.028) : 0
            }
        }
    }
}
