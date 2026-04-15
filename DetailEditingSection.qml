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

    function checklistItemsFromContent(content) {
        const source = (content || "").replace(/\r/g, "")
        const rawLines = source === "" ? [] : source.split("\n")
        const items = []
        for (let i = 0; i < rawLines.length; ++i) {
            const rawLine = rawLines[i]
            if (rawLine.trim() === "") {
                continue
            }
            let completed = false
            let text = rawLine
            if (/^\s*\[x\]\s*/i.test(rawLine)) {
                completed = true
                text = rawLine.replace(/^\s*\[x\]\s*/i, "")
            } else if (/^\s*\[ \]\s*/.test(rawLine)) {
                text = rawLine.replace(/^\s*\[ \]\s*/, "")
            } else if (/^\s*✓\s*/.test(rawLine)) {
                completed = true
                text = rawLine.replace(/^\s*✓\s*/, "")
            } else if (/^\s*○\s*/.test(rawLine)) {
                text = rawLine.replace(/^\s*○\s*/, "")
            }
            items.push({
                completed: completed,
                text: text
            })
        }
        return items
    }

    function checklistContentFromItems(items) {
        const lines = []
        for (let i = 0; i < items.length; ++i) {
            const text = (items[i].text || "").trim()
            if (text === "") {
                continue
            }
            lines.push((items[i].completed ? "[x] " : "[ ] ") + text)
        }
        return lines.join("\n")
    }

    function toggleChecklistItem(index) {
        const items = checklistItemsFromContent(editTaskContent)
        if (index < 0 || index >= items.length) {
            return
        }
        items[index].completed = !items[index].completed
        contentEdited(checklistContentFromItems(items))
    }

    function updateChecklistItemText(index, value) {
        const items = checklistItemsFromContent(editTaskContent)
        if (index < 0 || index >= items.length) {
            return
        }
        items[index].text = value
        contentEdited(checklistContentFromItems(items))
    }

    function removeChecklistItem(index) {
        const items = checklistItemsFromContent(editTaskContent)
        if (index < 0 || index >= items.length) {
            return
        }
        items.splice(index, 1)
        contentEdited(checklistContentFromItems(items))
    }

    function appendChecklistItem() {
        const items = checklistItemsFromContent(editTaskContent)
        items.push({
            completed: false,
            text: tFunc("下一步", "Next step")
        })
        contentEdited(checklistContentFromItems(items))
    }

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

    Rectangle {
        Layout.fillWidth: true
        Layout.minimumHeight: 180
        implicitHeight: Math.max(180, checklistSection.implicitHeight + 8)
        visible: !root.contentIsImageFunc(root.editTaskContent) && !root.contentIsFileFunc(root.editTaskContent)
        radius: 12
        color: root.homeDarkMode ? "#313b47" : "#fbfdff"
        border.color: root.detailBorderColor
        border.width: 1

        ColumnLayout {
            id: checklistSection
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            Repeater {
                model: root.checklistItemsFromContent(root.editTaskContent)

                delegate: Rectangle {
                    property var itemData: modelData

                    Layout.fillWidth: true
                    implicitHeight: 44
                    radius: 0
                    color: "transparent"

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            spacing: 10

                            Button {
                                implicitWidth: 24
                                implicitHeight: 24
                                Layout.alignment: Qt.AlignVCenter
                                onClicked: root.toggleChecklistItem(index)

                                background: Rectangle {
                                    radius: 12
                                    color: "transparent"
                                    border.color: itemData.completed ? "#94a3b8" : root.detailHintTextColor
                                    border.width: 2
                                }

                                contentItem: Text {
                                    text: itemData.completed ? "•" : ""
                                    color: root.detailHintTextColor
                                    font.pixelSize: 11
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            TextField {
                                Layout.fillWidth: true
                                text: itemData.text
                                color: itemData.completed ? root.detailHintTextColor : root.detailTextColor
                                font.pixelSize: Math.max(12, root.detailFontSize - 6)
                                font.strikeout: itemData.completed
                                background: null
                                leftPadding: 0
                                rightPadding: 0
                                topPadding: 0
                                bottomPadding: 0
                                selectByMouse: true
                                onEditingFinished: root.updateChecklistItemText(index, text)
                            }

                            Button {
                                text: "⋮"
                                implicitWidth: 24
                                implicitHeight: 24
                                Layout.alignment: Qt.AlignVCenter
                                onClicked: root.removeChecklistItem(index)

                                background: Rectangle {
                                    radius: 12
                                    color: "transparent"
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: root.detailHintTextColor
                                    font.pixelSize: 16
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: root.detailBorderColor
                            opacity: index < root.checklistItemsFromContent(root.editTaskContent).length - 1 ? 1 : 0
                        }
                    }
                }
            }

            Button {
                Layout.fillWidth: true
                text: root.tFunc("+ 下一步", "+ Next step")
                flat: true
                implicitHeight: 32
                onClicked: root.appendChecklistItem()

                contentItem: Text {
                    text: parent.text
                    color: root.detailHintTextColor
                    font.pixelSize: Math.max(12, root.detailFontSize - 6)
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: "transparent"
                }
            }
        }
    }
}

