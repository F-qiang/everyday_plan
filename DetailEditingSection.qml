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
    property int pendingFocusIndex: -1
    signal outlineEdited(string value)
    signal editingFinished()
    signal contentEdited(string value)
    signal completedEdited(bool value)

    function checklistItemsFromContent(content) {
        const lines = ((content || "") + "").replace(/\r/g, "").split("\n")
        const items = []
        for (let i = 0; i < lines.length; ++i) {
            const raw = lines[i]
            if (raw.trim() === "") continue
            let completed = false
            let text = raw
            if (/^\s*\[x\]\s*/i.test(raw)) { completed = true; text = raw.replace(/^\s*\[x\]\s*/i, "") }
            else if (/^\s*\[ \]\s*/.test(raw)) text = raw.replace(/^\s*\[ \]\s*/, "")
            else if (/^\s*✓\s*/.test(raw)) { completed = true; text = raw.replace(/^\s*✓\s*/, "") }
            else if (/^\s*○\s*/.test(raw)) text = raw.replace(/^\s*○\s*/, "")
            items.push({ completed: completed, text: text })
        }
        return items
    }
    function checklistContentFromItems(items) {
        const lines = []
        for (let i = 0; i < items.length; ++i) {
            const text = (items[i].text || "").trim()
            if (text !== "") lines.push((items[i].completed ? "[x] " : "[ ] ") + text)
        }
        return lines.join("\n")
    }
    function toggleChecklistItem(index) {
        const items = checklistItemsFromContent(editTaskContent)
        if (index < 0 || index >= items.length) return
        items[index].completed = !items[index].completed
        contentEdited(checklistContentFromItems(items))
    }
    function updateChecklistItemText(index, value) {
        const items = checklistItemsFromContent(editTaskContent)
        if (index < 0 || index >= items.length) return
        items[index].text = value
        contentEdited(checklistContentFromItems(items))
    }
    function removeChecklistItem(index) {
        const items = checklistItemsFromContent(editTaskContent)
        if (index < 0 || index >= items.length) return
        items.splice(index, 1)
        contentEdited(checklistContentFromItems(items))
    }
    function appendChecklistItem() {
        const source = ((editTaskContent || "") + "").replace(/\r/g, "")
        pendingFocusIndex = checklistItemsFromContent(editTaskContent).length
        contentEdited(source === "" ? "[ ] " : source + "\n[ ] ")
    }
    function createChecklistItemAfter(index, value) {
        const items = checklistItemsFromContent(editTaskContent)
        if (index < 0 || index >= items.length) return
        items[index].text = value
        items.splice(index + 1, 0, { completed: false, text: "" })
        pendingFocusIndex = index + 1
        contentEdited(checklistContentFromItems(items) + "\n[ ] ")
    }

    visible: visibleSection
    Layout.fillWidth: true
    spacing: 4

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: summaryColumn.implicitHeight + 6
        radius: 12
        color: root.homeDarkMode ? "#323945" : "#fcfaf5"
        border.color: root.detailBorderColor
        border.width: 1
        ColumnLayout {
            id: summaryColumn
            anchors.fill: parent
            anchors.margins: 4
            spacing: 2
            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                Rectangle { width: 3; height: 24; radius: 1.5; color: root.detailAccentColor }
                Label { text: qsTr("概要"); color: root.detailTextColor; font.pixelSize: Math.max(13, root.detailFontSize - 5); font.bold: true }
                Label { text: qsTr("支持修改摘要说明，正文为空时会自动复用概要"); color: root.detailHintTextColor; font.pixelSize: Math.max(11, root.detailFontSize - 8) }
            }
            TextArea {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(64, Math.min(contentHeight + topPadding + bottomPadding, 140))
                wrapMode: TextEdit.Wrap
                text: root.editTaskOutline
                onTextChanged: root.outlineEdited(text)
                onActiveFocusChanged: {
                    if (!activeFocus) {
                        root.editingFinished()
                    }
                }
                color: root.detailTextColor
                placeholderText: root.tFunc("请输入概要说明", "Enter summary")
                selectedTextColor: root.detailOnAccentColor
                selectionColor: root.detailAccentColor
                topPadding: 6; bottomPadding: 6; leftPadding: 12; rightPadding: 12
                background: Rectangle { color: root.homeDarkMode ? "#313b47" : "#fbfdff"; radius: 12; border.color: parent.activeFocus ? (root.homeDarkMode ? "#6d8299" : "#c9d9e8") : root.detailBorderColor; border.width: 1 }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.minimumHeight: 160
        implicitHeight: Math.max(160, checklistSection.implicitHeight + 4)
        visible: !root.contentIsImageFunc(root.editTaskContent) && !root.contentIsFileFunc(root.editTaskContent)
        radius: 12
        color: root.homeDarkMode ? "#313b47" : "#fbfdff"
        border.color: root.detailBorderColor
        border.width: 1
        ColumnLayout {
            id: checklistSection
            anchors.fill: parent
            anchors.margins: 8
            spacing: 4
            Repeater {
                model: root.checklistItemsFromContent(root.editTaskContent)
                delegate: Rectangle {
                    property var itemData: modelData
                    Layout.fillWidth: true
                    implicitHeight: 38
                    color: "transparent"
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            spacing: 10
                            Button {
                                implicitWidth: 24; implicitHeight: 24
                                onClicked: {
                                    root.toggleChecklistItem(index)
                                    root.editingFinished()
                                }
                                background: Rectangle { radius: 12; color: "transparent"; border.color: itemData.completed ? "#94a3b8" : root.detailHintTextColor; border.width: 2 }
                                contentItem: Text { text: itemData.completed ? "•" : ""; color: root.detailHintTextColor; font.pixelSize: 11; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            }
                            TextField {
                                id: checklistInput
                                Layout.fillWidth: true
                                text: itemData.text
                                placeholderText: root.tFunc("下一步", "Next step")
                                color: itemData.completed ? root.detailHintTextColor : root.detailTextColor
                                font.pixelSize: Math.max(12, root.detailFontSize - 6)
                                font.strikeout: itemData.completed
                                background: null
                                leftPadding: 0; rightPadding: 0; topPadding: 0; bottomPadding: 0
                                selectByMouse: true
                                Component.onCompleted: {
                                    if (index === root.pendingFocusIndex) {
                                        Qt.callLater(function() {
                                            checklistInput.forceActiveFocus()
                                            checklistInput.cursorPosition = checklistInput.text.length
                                            root.pendingFocusIndex = -1
                                        })
                                    }
                                }
                                onAccepted: {
                                    root.createChecklistItemAfter(index, text)
                                    root.editingFinished()
                                }
                                onEditingFinished: {
                                    root.updateChecklistItemText(index, text)
                                    root.editingFinished()
                                }
                            }
                            Button {
                                text: "🗑"
                                implicitWidth: 24; implicitHeight: 24
                                hoverEnabled: true
                                ToolTip.visible: hovered
                                ToolTip.delay: 200
                                ToolTip.text: root.tFunc("删除该行", "Delete this row")
                                onClicked: {
                                    root.removeChecklistItem(index)
                                    root.editingFinished()
                                }
                                background: Rectangle {
                                    radius: 12
                                    color: parent.hovered ? (root.homeDarkMode ? "#3f1d24" : "#fee2e2") : "transparent"
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: parent.hovered ? "#ef4444" : root.detailHintTextColor
                                    font.pixelSize: 13
                                    font.bold: parent.hovered
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: root.detailBorderColor; opacity: index < root.checklistItemsFromContent(root.editTaskContent).length - 1 ? 1 : 0 }
                    }
                }
            }
            Button {
                Layout.fillWidth: true
                text: root.tFunc("+ 下一步", "+ Next step")
                flat: true
                implicitHeight: 32
                onClicked: {
                    root.appendChecklistItem()
                    root.editingFinished()
                }
                contentItem: Text { text: parent.text; color: root.detailHintTextColor; font.pixelSize: Math.max(12, root.detailFontSize - 6); horizontalAlignment: Text.AlignLeft; verticalAlignment: Text.AlignVCenter }
                background: Rectangle { color: "transparent" }
            }
        }
    }
}
