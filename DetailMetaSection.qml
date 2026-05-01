import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: root

    property bool visibleSection: true
    property bool showTitleEditor: true
    property bool homeDarkMode: true
    property int detailFontSize: 20
    property string editTaskTitle: ""
    property color selectedTaskCategoryColor: "#94a3b8"
    property string selectedTaskCategoryName: ""
    property string selectedTaskAuthor: ""
    property string selectedTaskCreatedAt: ""
    property string editTaskTime: ""
    property bool editTaskReminderEnabled: false
    property string editTaskStartDate: ""
    property string editTaskDueDate: ""
    property int editTaskPriority: 1
    property int editTaskCategoryIndex: 0
    property var categoryList: []
    property bool showDetailAuthor: true
    property bool showDetailCreatedDate: true
    property bool showDetailStartDate: true
    property bool showDetailDueDate: true
    property bool showDetailPriority: true
    property bool showIdentitySection: true
    property bool showScheduleSection: true
    property color detailTextColor: "#0f172a"
    property color detailMutedTextColor: "#475569"
    property color detailHintTextColor: "#64748b"
    property color detailBorderColor: "#d8dee8"
    property color detailElevatedColor: "#ffffff"
    property color detailAccentColor: "#2563eb"
    property color detailOnAccentColor: "#ffffff"
    property color detailTonalColor: "#e8f0fe"
    property var tFunc
    property var formatDateTimeFunc
    property var openDateTimeEditorFunc
    signal titleEdited(string value)
    signal titleEditFinished()
    signal reminderEdited(string value)
    signal reminderEnabledEdited(bool value)
    signal startDateEdited(string value)
    signal dueDateEdited(string value)
    signal priorityEdited(int value)
    signal categoryIndexEdited(int value)

    visible: visibleSection
    Layout.fillWidth: true
    spacing: 4

    readonly property bool identityVisible: root.showIdentitySection && (root.showDetailAuthor || root.showDetailCreatedDate)
    readonly property bool scheduleVisible: root.showScheduleSection && (root.showDetailStartDate || root.showDetailDueDate || root.showDetailPriority)

    TextField {
        visible: root.visibleSection && root.showTitleEditor
        Layout.fillWidth: true
        implicitHeight: 42
        text: root.editTaskTitle
        font.pixelSize: root.detailFontSize + 2
        font.bold: true
        placeholderText: qsTr("请输入任务标题")
        color: root.detailTextColor
        selectByMouse: true
        selectedTextColor: root.detailOnAccentColor
        selectionColor: root.detailAccentColor
        onTextChanged: root.titleEdited(text)
        onEditingFinished: root.titleEditFinished()

        background: Rectangle {
            radius: 8
            color: root.detailElevatedColor
            border.color: parent.activeFocus ? root.detailAccentColor : root.detailBorderColor
            border.width: parent.activeFocus ? 2 : 1
        }
    }

    ColumnLayout {
        visible: root.identityVisible
        Layout.fillWidth: true
        spacing: 6

        RowLayout {
            visible: root.identityVisible
            Layout.fillWidth: true
            spacing: 6

            Rectangle {
                visible: root.showDetailAuthor
                Layout.fillWidth: true
                implicitHeight: 46
                radius: 12
                color: root.detailElevatedColor
                border.color: root.detailBorderColor
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    Label {
                        text: root.tFunc("作者：", "Author: ")
                        color: root.detailHintTextColor
                        font.pixelSize: Math.max(12, root.detailFontSize - 7)
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Label {
                        Layout.fillWidth: true
                        text: root.selectedTaskAuthor
                        color: root.detailHintTextColor
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: Math.max(12, root.detailFontSize - 7)
                    }
                }
            }

            Rectangle {
                visible: root.showDetailCreatedDate
                Layout.fillWidth: true
                implicitHeight: 46
                radius: 12
                color: root.detailElevatedColor
                border.color: root.detailBorderColor
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    Label {
                        text: root.tFunc("创建日期：", "Created: ")
                        color: root.detailHintTextColor
                        font.pixelSize: Math.max(12, root.detailFontSize - 7)
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Label {
                        Layout.fillWidth: true
                        text: root.formatDateTimeFunc(root.selectedTaskCreatedAt)
                        color: root.detailHintTextColor
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: Math.max(12, root.detailFontSize - 7)
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 52
            radius: 12
            color: root.detailElevatedColor
            border.color: root.detailBorderColor
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                CheckBox {
                    checked: root.editTaskReminderEnabled
                    Layout.alignment: Qt.AlignVCenter
                    onToggled: root.reminderEnabledEdited(checked)
                }

                Label {
                    text: root.tFunc("提醒", "Reminder")
                    color: root.detailHintTextColor
                    font.pixelSize: Math.max(12, root.detailFontSize - 7)
                    Layout.preferredWidth: 44
                    Layout.alignment: Qt.AlignVCenter
                }

                TextField {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    text: root.editTaskTime === "" ? root.tFunc("未设置", "Not set") : root.editTaskTime
                    readOnly: true
                    enabled: root.editTaskReminderEnabled
                    color: root.editTaskReminderEnabled ? root.detailTextColor : root.detailHintTextColor
                    background: Rectangle {
                        radius: 8
                        color: root.detailElevatedColor
                        border.color: root.detailBorderColor
                        border.width: 1
                        opacity: root.editTaskReminderEnabled ? 1 : 0.7
                    }
                }

                Button {
                    text: root.tFunc("选择", "Pick")
                    implicitWidth: 56
                    implicitHeight: 34
                    Layout.alignment: Qt.AlignVCenter
                    onClicked: root.openDateTimeEditorFunc("reminder")
                }

                Button {
                    visible: root.editTaskReminderEnabled && root.editTaskTime !== ""
                    text: root.tFunc("清空", "Clear")
                    implicitWidth: 56
                    implicitHeight: 34
                    Layout.alignment: Qt.AlignVCenter
                    onClicked: root.reminderEdited("")
                }
            }
        }
    }

    ColumnLayout {
        visible: root.scheduleVisible
        Layout.fillWidth: true
        spacing: 6

        Rectangle {
            visible: root.showDetailStartDate
            Layout.fillWidth: true
            implicitHeight: 52
            radius: 12
            color: root.detailElevatedColor
            border.color: root.detailBorderColor
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                Label {
                    text: root.tFunc("开始时间", "Start time")
                    color: root.detailHintTextColor
                    font.pixelSize: Math.max(12, root.detailFontSize - 7)
                    Layout.preferredWidth: 56
                    Layout.alignment: Qt.AlignVCenter
                }

                TextField {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    text: root.editTaskStartDate === "" ? root.tFunc("未设置", "Not set") : root.editTaskStartDate
                    readOnly: true
                    color: root.detailTextColor
                    background: Rectangle {
                        radius: 8
                        color: root.detailElevatedColor
                        border.color: root.detailBorderColor
                        border.width: 1
                    }
                }

                Button {
                    text: root.tFunc("选择", "Pick")
                    implicitWidth: 56
                    implicitHeight: 34
                    Layout.alignment: Qt.AlignVCenter
                    onClicked: root.openDateTimeEditorFunc("start")
                }

                Button {
                    visible: root.editTaskStartDate !== ""
                    text: root.tFunc("清空", "Clear")
                    implicitWidth: 56
                    implicitHeight: 34
                    Layout.alignment: Qt.AlignVCenter
                    onClicked: root.startDateEdited("")
                }
            }
        }

        Rectangle {
            visible: root.showDetailDueDate
            Layout.fillWidth: true
            implicitHeight: 52
            radius: 12
            color: root.detailElevatedColor
            border.color: root.detailBorderColor
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                Label {
                    text: root.tFunc("结束时间", "Due time")
                    color: root.detailHintTextColor
                    font.pixelSize: Math.max(12, root.detailFontSize - 7)
                    Layout.preferredWidth: 56
                    Layout.alignment: Qt.AlignVCenter
                }

                TextField {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    text: root.editTaskDueDate === "" ? root.tFunc("未设置", "Not set") : root.editTaskDueDate
                    readOnly: true
                    color: root.detailTextColor
                    background: Rectangle {
                        radius: 8
                        color: root.detailElevatedColor
                        border.color: root.detailBorderColor
                        border.width: 1
                    }
                }

                Button {
                    text: root.tFunc("选择", "Pick")
                    implicitWidth: 56
                    implicitHeight: 34
                    Layout.alignment: Qt.AlignVCenter
                    onClicked: root.openDateTimeEditorFunc("due")
                }

                Button {
                    visible: root.editTaskDueDate !== ""
                    text: root.tFunc("清空", "Clear")
                    implicitWidth: 56
                    implicitHeight: 34
                    Layout.alignment: Qt.AlignVCenter
                    onClicked: root.dueDateEdited("")
                }
            }
        }

        Rectangle {
            visible: root.showDetailPriority
            Layout.fillWidth: true
            implicitHeight: 58
            radius: 12
            color: root.detailElevatedColor
            border.color: root.detailBorderColor
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                Label {
                    text: root.tFunc("优先级", "Priority")
                    color: root.detailHintTextColor
                    font.pixelSize: Math.max(12, root.detailFontSize - 7)
                    Layout.preferredWidth: 52
                    Layout.alignment: Qt.AlignVCenter
                }

                ComboBox {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    model: ["低", "中", "高", "紧急"]
                    currentIndex: Math.max(0, root.editTaskPriority - 1)
                    implicitWidth: 144
                    onActivated: root.priorityEdited(currentIndex + 1)
                }

                Item { visible: false; Layout.fillWidth: true }
            }
        }
    }
}
