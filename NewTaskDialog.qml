import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects
import QtQuick.Dialogs

Item {
    id: root
    property bool homeDarkMode: true
    property bool active: false
    property string uiLanguage: "zh"
    property var categories: []
    property bool compactTimeLayout: width < 760
    property bool compactMetaLayout: width < 860
    readonly property int shellMargin: 18
    readonly property int shellRadius: 22
    readonly property int actionBarHeight: 74
    signal submitRequested(string title, string description, string content, string startDate, string endDate, int priority, int categoryId, bool completed)

    readonly property color bg: homeDarkMode ? "#2f343c" : "#f6efe2"
    readonly property color card: homeDarkMode ? "#3a4049" : "#fffaf1"
    readonly property color panel: homeDarkMode ? "#454c56" : "#fffdf7"
    readonly property color border: homeDarkMode ? "#4b5563" : "#e5d6ba"
    readonly property color strongBorder: homeDarkMode ? "#60a5fa" : "#d97706"
    readonly property color titleC: homeDarkMode ? "#f8fafc" : "#3f3120"
    readonly property color subC: homeDarkMode ? "#d1d5db" : "#8b6b42"
    readonly property color heroA: homeDarkMode ? "#374151" : "#fde7c7"
    readonly property color heroB: homeDarkMode ? "#2f343c" : "#fff7ea"
    readonly property color inputBg: homeDarkMode ? "#2b3138" : "#fffdfa"
    readonly property color accent: homeDarkMode ? "#93c5fd" : "#c67a1a"

    function t(zh, en) {
        return uiLanguage === "en" ? en : zh
    }

    function inputBorder(focus, enabled) {
        if (!enabled) {
            return border
        }
        return focus ? strongBorder : border
    }

    function resetForm() {
        taskTitleInput.text = ""
        taskDescInput.text = ""
        taskContentInput.text = ""
        completedInput.checked = false
        enableStartDate.checked = true
        enableEndDate.checked = true
        startDateInput.text = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm")
        endDateInput.text = Qt.formatDateTime(new Date(new Date().getTime() + 7 * 24 * 60 * 60 * 1000), "yyyy-MM-dd HH:mm")
        priorityInput.currentIndex = 0
        categoryInput.currentIndex = categories.length > 0 ? 1 : 0
    }

    function submitTaskForm() {
        if (taskTitleInput.text.trim() === "") {
            taskTitleInput.forceActiveFocus()
            return
        }
        const cid = categoryInput.currentIndex > 0 && categories.length >= categoryInput.currentIndex ? categories[categoryInput.currentIndex - 1].categoryId : 0
        const startValue = enableStartDate.checked ? startDateInput.text.trim() : ""
        const endValue = enableEndDate.checked ? endDateInput.text.trim() : ""
        submitRequested(taskTitleInput.text.trim(), taskDescInput.text.trim(), taskContentInput.text.trim(), startValue, endValue, priorityInput.currentIndex + 1, cid, completedInput.checked)
    }

    function normalizeSelectedFile(selectedFile) {
        const source = (selectedFile || "").toString()
        if (source === "") {
            return ""
        }
        if (source.startsWith("file:///")) {
            const localPath = decodeURIComponent(source.substring(8))
            return Qt.platform.os === "windows" ? localPath.replace(/\//g, "\\") : "/" + localPath
        }
        if (source.startsWith("file://")) {
            return decodeURIComponent(source.substring(7))
        }
        return decodeURIComponent(source)
    }

    function selectedFileName(path) {
        const source = (path || "").trim()
        if (source === "") {
            return root.t("未选择附件", "No file selected")
        }
        const parts = source.split(/[\/]/)
        return parts.length > 0 ? parts[parts.length - 1] : source
    }

    onActiveChanged: if (active) { motion.restart(); taskTitleInput.forceActiveFocus() }

    component InputCard: Rectangle {
        radius: 18
        color: root.panel
        border.color: root.border
        border.width: 1
    }

    component SectionLabel: Label {
        color: root.titleC
        font.pixelSize: 14
        font.bold: true
    }

    component HintLabel: Label {
        color: root.subC
        font.pixelSize: 11
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
    }

    component FormField: TextField {
        implicitHeight: 44
        color: root.titleC
        selectByMouse: true
        background: Rectangle {
            radius: 13
            color: root.inputBg
            border.color: root.inputBorder(parent.activeFocus, parent.enabled)
            border.width: parent.activeFocus ? 2 : 1
            opacity: parent.enabled ? 1 : 0.58
        }
    }

    FileDialog {
        id: contentFileDialog
        title: root.t("选择附件文件", "Choose a file to attach")
        fileMode: FileDialog.OpenFile
        onAccepted: taskContentInput.text = root.normalizeSelectedFile(selectedFile)
    }

    Rectangle {
        anchors.fill: parent
        color: bg

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            gradient: Gradient {
                GradientStop { position: 0.0; color: heroA }
                GradientStop { position: 1.0; color: "transparent" }
            }
            opacity: 0.45
        }
    }

    Item {
        id: body
        anchors.fill: parent
        anchors.margins: shellMargin
        opacity: 0
        y: 20

        ParallelAnimation {
            id: motion
            NumberAnimation { target: body; property: "opacity"; from: 0; to: 1; duration: 220; easing.type: Easing.OutCubic }
            NumberAnimation { target: body; property: "y"; from: 20; to: 0; duration: 260; easing.type: Easing.OutCubic }
        }

        Rectangle {
            anchors.fill: parent
            radius: shellRadius
            color: card
            border.color: border
            border.width: 1
            clip: true

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 126
                radius: shellRadius
                color: "transparent"

                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: heroA }
                        GradientStop { position: 0.7; color: heroB }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 22
                spacing: 16

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 102
                    radius: 22
                    color: "transparent"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 4
                        spacing: 8

                        Label {
                            text: root.t("新建任务", "Create Task")
                            color: titleC
                            font.pixelSize: 28
                            font.bold: true
                        }

                        Label {
                            Layout.fillWidth: true
                            text: root.t("集中填写标题、时间、优先级、分类与附件，更高效地创建任务。", "Keep title, timing, priority, category, and attachments in one place for faster task entry.")
                            color: subC
                            font.pixelSize: 13
                            wrapMode: Text.WordWrap
                        }

                        RowLayout {
                            spacing: 8

                            Rectangle {
                                radius: 999
                                color: homeDarkMode ? "#eff6ff" : "#fff3dd"
                                border.color: homeDarkMode ? "#bfdbfe" : "#f2c078"
                                implicitHeight: 28
                                implicitWidth: quickHint.implicitWidth + 18

                                Label {
                                    id: quickHint
                                    anchors.centerIn: parent
                                    text: root.t("时间可选", "Time is optional")
                                    color: accent
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                            }

                            Rectangle {
                                radius: 999
                                color: homeDarkMode ? "#3f4650" : "#fffaf0"
                                border.color: border
                                implicitHeight: 28
                                implicitWidth: quickHint2.implicitWidth + 18

                                Label {
                                    id: quickHint2
                                    anchors.centerIn: parent
                                    text: root.t("创建后可继续补充详情", "Details open after creation")
                                    color: subC
                                    font.pixelSize: 11
                                }
                            }
                        }
                    }
                }

                ScrollView {
                    id: formScroll
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    contentWidth: formScroll.availableWidth
                    bottomPadding: 14
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    Item {
                        width: formScroll.availableWidth
                        implicitHeight: formColumn.implicitHeight

                        ColumnLayout {
                            id: formColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: 12

                            InputCard {
                                Layout.fillWidth: true
                                implicitHeight: 96

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 8

                                    SectionLabel { text: root.t("任务标题", "Task title") }

                                    FormField {
                                        id: taskTitleInput
                                        Layout.fillWidth: true
                                        placeholderText: root.t("例如：完成本周项目周报", "Example: finish weekly project report")
                                    }
                                }
                            }

                            InputCard {
                                Layout.fillWidth: true
                                implicitHeight: 220

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 8

                                    SectionLabel { text: root.t("任务描述", "Description") }
                                    HintLabel { text: root.t("写下目标、备注或执行步骤，详情面板会按原样展示。", "Write the goal, notes, or steps. The detail panel will display it as entered.") }

                                    TextArea {
                                        id: taskDescInput
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        placeholderText: root.t("填写任务目标、备注或行动项", "Write the goal, notes, or action items")
                                        wrapMode: TextEdit.Wrap
                                        selectByMouse: true
                                        color: root.titleC
                                        background: Rectangle {
                                            radius: 14
                                            color: root.inputBg
                                            border.color: root.inputBorder(taskDescInput.activeFocus, true)
                                            border.width: taskDescInput.activeFocus ? 2 : 1
                                        }
                                    }
                                }
                            }

                            InputCard {
                                Layout.fillWidth: true
                                implicitHeight: 286

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 8

                                    RowLayout {
                                        Layout.fillWidth: true
                                        SectionLabel { text: root.t("内容 / 附件", "Content / attachment") }
                                        Item { Layout.fillWidth: true }
                                        CheckBox {
                                            id: completedInput
                                            text: root.t("已完成", "Completed")
                                        }
                                    }

                                    HintLabel { text: root.t("可直接输入文字、粘贴图片或文件路径，或选择本地文件自动填入路径。", "You can type text, paste an image/file path, or pick a local file and auto-fill the path.") }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 10

                                        Button {
                                            text: root.t("选择文件", "Choose file")
                                            implicitHeight: 36
                                            implicitWidth: 96
                                            onClicked: contentFileDialog.open()
                                        }

                                        Button {
                                            text: root.t("清空", "Clear")
                                            implicitHeight: 36
                                            implicitWidth: 72
                                            enabled: taskContentInput.text.trim() !== ""
                                            onClicked: taskContentInput.text = ""
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            implicitHeight: 36
                                            radius: 12
                                            color: homeDarkMode ? "#eff6ff" : "#fff5e8"
                                            border.color: homeDarkMode ? "#bfdbfe" : "#f2c078"
                                            border.width: 1

                                            Label {
                                                anchors.fill: parent
                                                anchors.leftMargin: 12
                                                anchors.rightMargin: 12
                                                verticalAlignment: Text.AlignVCenter
                                                elide: Text.ElideMiddle
                                                color: root.subC
                                                text: root.selectedFileName(taskContentInput.text)
                                            }
                                        }
                                    }

                                    TextArea {
                                        id: taskContentInput
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        placeholderText: root.t("可在此输入内容，或在上方选择图片/文件", "Type content here, or choose an image/file above")
                                        wrapMode: TextEdit.Wrap
                                        selectByMouse: true
                                        color: root.titleC
                                        background: Rectangle {
                                            radius: 14
                                            color: root.inputBg
                                            border.color: root.inputBorder(taskContentInput.activeFocus, true)
                                            border.width: taskContentInput.activeFocus ? 2 : 1
                                        }
                                    }
                                }
                            }

                            InputCard {
                                Layout.fillWidth: true
                                implicitHeight: root.compactTimeLayout ? 292 : 156

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 12

                                    RowLayout {
                                        Layout.fillWidth: true
                                        SectionLabel { text: root.t("时间设置", "Time settings") }
                                        Item { Layout.fillWidth: true }
                                        HintLabel { text: root.t("格式：yyyy-MM-dd HH:mm", "Format: yyyy-MM-dd HH:mm") }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 12
                                        visible: !root.compactTimeLayout

                                        Rectangle {
                                            Layout.fillWidth: true
                                            implicitHeight: 86
                                            radius: 16
                                            color: inputBg
                                            border.color: border
                                            border.width: 1

                                            ColumnLayout {
                                                anchors.fill: parent
                                                anchors.margins: 12
                                                spacing: 8

                                                RowLayout {
                                                    Layout.fillWidth: true
                                                    SectionLabel { text: root.t("开始时间", "Start time") }
                                                    Item { Layout.fillWidth: true }
                                                    CheckBox { id: enableStartDate; text: root.t("启用", "Enable"); checked: true }
                                                }

                                                FormField {
                                                    id: startDateInput
                                                    Layout.fillWidth: true
                                                    enabled: enableStartDate.checked
                                                    placeholderText: "yyyy-MM-dd HH:mm"
                                                    text: Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm")
                                                }
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            implicitHeight: 86
                                            radius: 16
                                            color: inputBg
                                            border.color: border
                                            border.width: 1

                                            ColumnLayout {
                                                anchors.fill: parent
                                                anchors.margins: 12
                                                spacing: 8

                                                RowLayout {
                                                    Layout.fillWidth: true
                                                    SectionLabel { text: root.t("结束时间", "End time") }
                                                    Item { Layout.fillWidth: true }
                                                    CheckBox { id: enableEndDate; text: root.t("启用", "Enable"); checked: true }
                                                }

                                                FormField {
                                                    id: endDateInput
                                                    Layout.fillWidth: true
                                                    enabled: enableEndDate.checked
                                                    placeholderText: "yyyy-MM-dd HH:mm"
                                                    text: Qt.formatDateTime(new Date(new Date().getTime() + 7 * 24 * 60 * 60 * 1000), "yyyy-MM-dd HH:mm")
                                                }
                                            }
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 12
                                        visible: root.compactTimeLayout

                                        InputCard {
                                            Layout.fillWidth: true
                                            implicitHeight: 96

                                            ColumnLayout {
                                                anchors.fill: parent
                                                anchors.margins: 16
                                                spacing: 8

                                                RowLayout {
                                                    Layout.fillWidth: true
                                                    SectionLabel { text: root.t("开始时间", "Start time") }
                                                    Item { Layout.fillWidth: true }
                                                    CheckBox { checked: enableStartDate.checked; onToggled: enableStartDate.checked = checked; text: root.t("启用", "Enable") }
                                                }

                                                FormField {
                                                    Layout.fillWidth: true
                                                    enabled: enableStartDate.checked
                                                    placeholderText: "yyyy-MM-dd HH:mm"
                                                    text: startDateInput.text
                                                    onTextChanged: startDateInput.text = text
                                                }
                                            }
                                        }

                                        InputCard {
                                            Layout.fillWidth: true
                                            implicitHeight: 96

                                            ColumnLayout {
                                                anchors.fill: parent
                                                anchors.margins: 16
                                                spacing: 8

                                                RowLayout {
                                                    Layout.fillWidth: true
                                                    SectionLabel { text: root.t("结束时间", "End time") }
                                                    Item { Layout.fillWidth: true }
                                                    CheckBox { checked: enableEndDate.checked; onToggled: enableEndDate.checked = checked; text: root.t("启用", "Enable") }
                                                }

                                                FormField {
                                                    Layout.fillWidth: true
                                                    enabled: enableEndDate.checked
                                                    placeholderText: "yyyy-MM-dd HH:mm"
                                                    text: endDateInput.text
                                                    onTextChanged: endDateInput.text = text
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12
                                visible: !root.compactMetaLayout

                                InputCard {
                                    Layout.fillWidth: true
                                    implicitHeight: 96

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 16
                                        spacing: 8

                                        SectionLabel { text: root.t("优先级", "Priority") }

                                        ComboBox {
                                            id: priorityInput
                                            Layout.fillWidth: true
                                            implicitHeight: 44
                                            model: root.uiLanguage === "en" ? ["Low", "Medium", "High", "Urgent"] : ["低", "中", "高", "紧急"]
                                            currentIndex: 0
                                        }
                                    }
                                }

                                InputCard {
                                    Layout.fillWidth: true
                                    implicitHeight: 96

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 16
                                        spacing: 8

                                        SectionLabel { text: root.t("分类", "Category") }

                                        ComboBox {
                                            id: categoryInput
                                            Layout.fillWidth: true
                                            implicitHeight: 44
                                            model: {
                                                const items = [root.t("未分类", "Uncategorized")]
                                                for (let i = 0; i < root.categories.length; ++i) {
                                                    items.push(root.categories[i].name)
                                                }
                                                return items
                                            }
                                        }
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 12
                                visible: root.compactMetaLayout

                                InputCard {
                                    Layout.fillWidth: true
                                    implicitHeight: 96

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 16
                                        spacing: 8

                                        SectionLabel { text: root.t("优先级", "Priority") }

                                        ComboBox {
                                            Layout.fillWidth: true
                                            implicitHeight: 44
                                            model: priorityInput.model
                                            currentIndex: priorityInput.currentIndex
                                            onActivated: priorityInput.currentIndex = currentIndex
                                        }
                                    }
                                }

                                InputCard {
                                    Layout.fillWidth: true
                                    implicitHeight: 96

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 16
                                        spacing: 8

                                        SectionLabel { text: root.t("分类", "Category") }

                                        ComboBox {
                                            Layout.fillWidth: true
                                            implicitHeight: 44
                                            model: categoryInput.model
                                            currentIndex: categoryInput.currentIndex
                                            onActivated: categoryInput.currentIndex = currentIndex
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.topMargin: 10
                                implicitHeight: actionBarHeight
                                radius: 22
                                color: card
                                border.color: homeDarkMode ? "#c7dbf8" : "#e7cfaa"
                                border.width: 1

                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    shadowEnabled: true
                                    shadowColor: homeDarkMode ? "#1d4ed822" : "#8a5a111f"
                                    shadowVerticalOffset: 8
                                    shadowHorizontalOffset: 0
                                    shadowBlur: 0.45
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: 1
                                    radius: 21
                                    color: panel
                                    border.color: "transparent"
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 18
                                    anchors.rightMargin: 18
                                    spacing: 12

                                    ColumnLayout {
                                        spacing: 2

                                        Label {
                                            text: root.t("准备创建", "Ready to create")
                                            color: titleC
                                            font.pixelSize: 13
                                            font.bold: true
                                        }

                                        Label {
                                            text: root.t("如果暂时不想设置时间，可以先关闭时间字段。", "Disable time fields if you do not want to set them yet.")
                                            color: subC
                                            font.pixelSize: 11
                                        }
                                    }

                                    Item { Layout.fillWidth: true }

                                    Button {
                                        text: root.t("重置", "Reset")
                                        implicitWidth: 90
                                        implicitHeight: 40
                                        onClicked: resetForm()
                                    }

                                    Button {
                                        text: root.t("创建任务", "Create task")
                                        implicitWidth: 118
                                        implicitHeight: 40
                                        highlighted: true
                                        onClicked: submitTaskForm()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}





