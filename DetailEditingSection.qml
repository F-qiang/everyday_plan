import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

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
    property var selectedFileNameFunc
    property int pendingFocusIndex: -1
    signal outlineEdited(string value)
    signal editingFinished()
    signal contentEdited(string value)
    signal completedEdited(bool value)
    signal uploadFileRequested(string replacePath)
    signal openFileRequested(string path)
    signal removeAttachmentRequested(string path)

    property bool attachmentMenuPinned: false
    property real attachmentMenuTargetX: 0
    property real attachmentMenuTargetY: 0
    property real attachmentCopyToastTargetX: 0
    property real attachmentCopyToastTargetY: 0
    property string activeAttachmentPath: ""
    property string copiedAttachmentPath: ""
    property var activeAttachmentMenuAnchor: null

    function showAttachmentMenu(anchor, attachmentPath) {
        attachmentMenuHideTimer.stop()
        const nextPath = (attachmentPath || "").trim()
        activeAttachmentMenuAnchor = anchor || null
        activeAttachmentPath = nextPath
        if (attachmentOptionsPopup.parent && activeAttachmentMenuAnchor) {
            const point = activeAttachmentMenuAnchor.mapToItem(attachmentOptionsPopup.parent, activeAttachmentMenuAnchor.width - attachmentOptionsPopup.width, activeAttachmentMenuAnchor.height + 2)
            attachmentMenuTargetX = Math.max(8, point.x)
            attachmentMenuTargetY = Math.max(8, point.y)
        }

        if (attachmentOptionsPopup.visible) {
            attachmentMenuContent.opacity = 1
            attachmentOptionsPopup.x = attachmentMenuTargetX
            attachmentOptionsPopup.y = attachmentMenuTargetY
            return
        }

        attachmentOptionsPopup.x = attachmentMenuTargetX
        attachmentOptionsPopup.y = attachmentMenuTargetY
        attachmentMenuContent.opacity = 0
        attachmentOptionsPopup.open()
    }

    function copyAttachmentPath(path) {
        const targetPath = ((path || activeAttachmentPath || "") + "").trim()
        if (targetPath === "") {
            return
        }
        attachmentClipboardProxy.text = targetPath
        attachmentClipboardProxy.selectAll()
        attachmentClipboardProxy.copy()
        attachmentClipboardProxy.deselect()
        copiedAttachmentPath = targetPath
        showAttachmentCopiedToast()
    }

    function showAttachmentCopiedToast() {
        attachmentCopyToastTimer.stop()
        if (attachmentCopiedToast.parent && activeAttachmentMenuAnchor) {
            if (attachmentOptionsPopup.visible) {
                attachmentCopyToastTargetX = attachmentOptionsPopup.x + attachmentOptionsPopup.width - attachmentCopiedToast.width
                attachmentCopyToastTargetY = attachmentOptionsPopup.y + attachmentOptionsPopup.height + 8
            } else {
                const point = activeAttachmentMenuAnchor.mapToItem(attachmentCopiedToast.parent, activeAttachmentMenuAnchor.width - attachmentCopiedToast.width, activeAttachmentMenuAnchor.height + 8)
                attachmentCopyToastTargetX = point.x
                attachmentCopyToastTargetY = point.y
            }
            attachmentCopiedToast.x = Math.max(8, attachmentCopyToastTargetX)
            attachmentCopiedToast.y = Math.max(8, attachmentCopyToastTargetY)
        }
        attachmentCopiedToast.opacity = 0
        attachmentCopiedToast.x = Math.max(8, attachmentCopyToastTargetX)
        attachmentCopiedToast.y = Math.max(8, attachmentCopyToastTargetY)
        attachmentCopiedToast.open()
        attachmentCopyToastTimer.restart()
    }

    function scheduleAttachmentMenuHide() {
        if (!attachmentMenuPinned) {
            attachmentMenuHideTimer.restart()
        }
    }

    function attachmentPathsFromContent(content) {
        const source = ((content || "") + "").replace(/\r/g, "")
        const matches = source.match(/^\s*(\[\[attachment:.+\]\]\s*)+/)
        if (!matches) {
            const trimmed = source.trim()
            return root.contentIsFileFunc(trimmed) ? [trimmed] : []
        }

        const attachmentLines = matches[0].match(/\[\[attachment:(.+?)\]\]/g) || []
        const paths = []
        for (let i = 0; i < attachmentLines.length; ++i) {
            const lineMatch = attachmentLines[i].match(/^\[\[attachment:(.+)\]\]$/)
            if (lineMatch && (lineMatch[1] || "").trim() !== "") {
                paths.push((lineMatch[1] || "").trim())
            }
        }
        return paths
    }

    function attachmentPathFromContent(content) {
        const paths = attachmentPathsFromContent(content)
        return paths.length > 0 ? paths[0] : ""
    }

    function bodyTextFromContent(content) {
        const source = ((content || "") + "").replace(/\r/g, "")
        const trimmed = source.trim()
        if (trimmed === "") {
            return ""
        }

        const matches = source.match(/^\s*(\[\[attachment:.+\]\]\s*)+/)
        if (matches) {
            return source.slice(matches[0].length).replace(/^\n+/, "")
        }
        return root.contentIsFileFunc(trimmed) ? "" : source
    }

    function composeContent(bodyText, attachmentPaths) {
        const body = ((bodyText || "") + "").replace(/\r/g, "").replace(/[ \t\n]+$/, "")
        const paths = attachmentPaths || []
        const normalizedPaths = []
        for (let i = 0; i < paths.length; ++i) {
            const path = ((paths[i] || "") + "").trim()
            if (path !== "") {
                normalizedPaths.push(path)
            }
        }
        if (normalizedPaths.length === 0) {
            return body
        }
        const attachmentBlock = normalizedPaths.map(function(path) {
            return "[[attachment:" + path + "]]"
        }).join("\n")
        return body === "" ? attachmentBlock : attachmentBlock + "\n\n" + body
    }

    function appendAttachmentPath(content, attachmentPath) {
        const paths = attachmentPathsFromContent(content)
        const path = ((attachmentPath || "") + "").trim()
        if (path === "") {
            return content
        }
        paths.push(path)
        return composeContent(bodyTextFromContent(content), paths)
    }

    function removeAttachmentPath(content, attachmentPath) {
        const path = ((attachmentPath || "") + "").trim()
        const paths = attachmentPathsFromContent(content).filter(function(item) {
            return item !== path
        })
        return composeContent(bodyTextFromContent(content), paths)
    }

    function attachmentIconForPath(path) {
        const source = ((path || "") + "").trim().toLowerCase()
        if (/\.(png|jpg|jpeg|gif|bmp|webp|svg|ico|heic)$/.test(source)) return "🖼"
        if (/\.(pdf)$/.test(source)) return "📕"
        if (/\.(doc|docx|odt|rtf|pages)$/.test(source)) return "📘"
        if (/\.(xls|xlsx|csv|ods)$/.test(source)) return "📗"
        if (/\.(ppt|pptx|key)$/.test(source)) return "📙"
        if (/\.(zip|rar|7z|tar|gz|bz2|xz)$/.test(source)) return "🗜"
        if (/\.(mp3|wav|flac|aac|ogg|m4a)$/.test(source)) return "🎵"
        if (/\.(mp4|mkv|mov|avi|wmv|webm)$/.test(source)) return "🎬"
        if (/\.(txt|md|json|xml|yml|yaml|ini|cfg|log)$/.test(source)) return "📄"
        if (/\.(exe|msi|apk|dmg|app)$/.test(source)) return "⚙"
        return "📎"
    }

    function checklistItemsFromContent(content) {
        const lines = (bodyTextFromContent(content) + "").replace(/\r/g, "").split("\n")
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
        contentEdited(composeContent(checklistContentFromItems(items), attachmentPathsFromContent(editTaskContent)))
    }
    function updateChecklistItemText(index, value) {
        const items = checklistItemsFromContent(editTaskContent)
        if (index < 0 || index >= items.length) return
        items[index].text = value
        contentEdited(composeContent(checklistContentFromItems(items), attachmentPathsFromContent(editTaskContent)))
    }
    function removeChecklistItem(index) {
        const items = checklistItemsFromContent(editTaskContent)
        if (index < 0 || index >= items.length) return
        items.splice(index, 1)
        contentEdited(composeContent(checklistContentFromItems(items), attachmentPathsFromContent(editTaskContent)))
    }
    function appendChecklistItem() {
        const source = bodyTextFromContent(editTaskContent)
        pendingFocusIndex = checklistItemsFromContent(editTaskContent).length
        contentEdited(composeContent(source === "" ? "[ ] " : source + "\n[ ] ", attachmentPathsFromContent(editTaskContent)))
    }
    function createChecklistItemAfter(index, value) {
        const items = checklistItemsFromContent(editTaskContent)
        if (index < 0 || index >= items.length) return
        items[index].text = value
        items.splice(index + 1, 0, { completed: false, text: "" })
        pendingFocusIndex = index + 1
        contentEdited(composeContent(checklistContentFromItems(items) + "\n[ ] ", attachmentPathsFromContent(editTaskContent)))
    }

    visible: visibleSection
    Layout.fillWidth: true
    spacing: 4

    Timer {
        id: attachmentMenuHideTimer
        interval: 160
        repeat: false
        onTriggered: {
            if (!attachmentMenuMouseArea.containsMouse
                    && !attachmentCopyArea.containsMouse
                    && !attachmentUploadArea.containsMouse
                    && !attachmentDeleteArea.containsMouse
                    && !attachmentMenuPinned) {
                attachmentOptionsPopup.close()
            }
        }
    }

    Timer {
        id: attachmentCopyToastTimer
        interval: 1100
        repeat: false
        onTriggered: attachmentCopiedToast.close()
    }

    Popup {
        id: attachmentCopiedToast
        parent: Overlay.overlay
        modal: false
        focus: false
        padding: 0
        closePolicy: Popup.NoAutoClose
        width: Math.min(root.width - 16, Math.max(copiedToastColumn.implicitWidth + 30, 180))
        height: copiedToastColumn.implicitHeight + 22
        opacity: 1

        enter: Transition {
            NumberAnimation { target: attachmentCopiedToast; property: "opacity"; from: 0; to: 1; duration: 110; easing.type: Easing.OutCubic }
        }

        exit: Transition {
            NumberAnimation { target: attachmentCopiedToast; property: "opacity"; from: attachmentCopiedToast.opacity; to: 0; duration: 110; easing.type: Easing.InCubic }
        }

        background: Rectangle {
            radius: 12
            color: root.homeDarkMode ? "#1f2937" : "#0f172a"
            opacity: 0.94
        }

        contentItem: Column {
            id: copiedToastColumn
            spacing: 4

            Text {
                id: copiedToastLabel
                text: root.tFunc("已复制", "Copied")
                color: "#f8fafc"
                font.pixelSize: Math.max(13, root.detailFontSize - 6)
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                width: attachmentCopiedToast.width - 30
                text: root.copiedAttachmentPath
                color: "#cbd5e1"
                font.pixelSize: Math.max(11, root.detailFontSize - 8)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideMiddle
            }
        }
    }

    Popup {
        id: attachmentOptionsPopup
        parent: Overlay.overlay
        modal: false
        focus: false
        padding: 0
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        width: 168
        height: attachmentMenuColumn.implicitHeight + 12

        Behavior on x {
            NumberAnimation { duration: 110; easing.type: Easing.OutCubic }
        }

        Behavior on y {
            NumberAnimation { duration: 110; easing.type: Easing.OutCubic }
        }

        enter: Transition {
            NumberAnimation { target: attachmentMenuContent; property: "opacity"; from: 0; to: 1; duration: 90; easing.type: Easing.OutCubic }
        }

        exit: Transition {
            NumberAnimation { target: attachmentMenuContent; property: "opacity"; from: attachmentMenuContent.opacity; to: 0; duration: 70; easing.type: Easing.InCubic }
        }

        background: Rectangle {
            radius: 12
            color: root.homeDarkMode ? "#f8fafc" : "#ffffff"
            border.color: root.homeDarkMode ? "#cbd5e1" : "#d8dee8"
            border.width: 1
            layer.enabled: true
            layer.smooth: true
            layer.effect: DropShadow {
                transparentBorder: true
                color: root.homeDarkMode ? "#1a000000" : "#120f172a"
                radius: 6
                samples: 16
                horizontalOffset: 0
                verticalOffset: 1
            }
        }

        contentItem: Column {
            id: attachmentMenuContent
            opacity: 1

            Column {
                id: attachmentMenuColumn
                spacing: 0
                padding: 6

            Rectangle {
                width: parent.width
                height: 34
                radius: 8
                color: attachmentCopyArea.containsMouse ? (root.homeDarkMode ? "#dde7f3" : "#eef4ff") : "transparent"

                Behavior on color {
                    ColorAnimation { duration: 140 }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 10
                    Text {
                        text: "📋"
                        font.pixelSize: 14
                        Layout.preferredWidth: 20
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Text {
                        Layout.fillWidth: true
                        text: root.tFunc("复制地址", "Copy path")
                        color: "#0f172a"
                        font.pixelSize: Math.max(12, root.detailFontSize - 7)
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    id: attachmentCopyArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: attachmentMenuHideTimer.stop()
                    onExited: root.scheduleAttachmentMenuHide()
                    onClicked: {
                        root.copyAttachmentPath(root.activeAttachmentPath)
                        attachmentMenuPinned = false
                        attachmentOptionsPopup.close()
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: root.homeDarkMode ? "#d7e0ea" : "#edf2f7"
                opacity: 0.75
            }

            Rectangle {
                width: parent.width
                height: 34
                radius: 8
                color: attachmentUploadArea.containsMouse ? (root.homeDarkMode ? "#dde7f3" : "#eef4ff") : "transparent"

                Behavior on color {
                    ColorAnimation { duration: 140 }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 10
                    Text {
                        text: "⤴"
                        font.pixelSize: 14
                        Layout.preferredWidth: 20
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Text {
                        Layout.fillWidth: true
                        text: root.tFunc("重新上传", "Upload again")
                        color: "#0f172a"
                        font.pixelSize: Math.max(12, root.detailFontSize - 7)
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    id: attachmentUploadArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: attachmentMenuHideTimer.stop()
                    onExited: root.scheduleAttachmentMenuHide()
                    onClicked: {
                        root.uploadFileRequested(root.activeAttachmentPath)
                        attachmentMenuPinned = false
                        attachmentOptionsPopup.close()
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: root.homeDarkMode ? "#d7e0ea" : "#edf2f7"
                opacity: 0.75
            }

            Rectangle {
                width: parent.width
                height: 34
                radius: 8
                color: attachmentDeleteArea.containsMouse ? "#fee2e2" : "transparent"

                Behavior on color {
                    ColorAnimation { duration: 140 }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 10
                    Text {
                        text: "🗑"
                        font.pixelSize: 14
                        Layout.preferredWidth: 20
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Text {
                        Layout.fillWidth: true
                        text: root.tFunc("删除附件", "Remove attachment")
                        color: attachmentDeleteArea.containsMouse ? "#991b1b" : "#b91c1c"
                        font.pixelSize: Math.max(12, root.detailFontSize - 7)
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    id: attachmentDeleteArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: attachmentMenuHideTimer.stop()
                    onExited: root.scheduleAttachmentMenuHide()
                    onClicked: {
                        root.removeAttachmentRequested(root.activeAttachmentPath)
                        attachmentMenuPinned = false
                        attachmentOptionsPopup.close()
                    }
                }
            }
            }
        }

        MouseArea {
            id: attachmentMenuMouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onEntered: attachmentMenuHideTimer.stop()
            onExited: root.scheduleAttachmentMenuHide()
            z: -1
        }

        onClosed: {
            attachmentMenuPinned = false
            attachmentMenuHideTimer.stop()
            attachmentMenuContent.opacity = 1
            activeAttachmentPath = ""
            activeAttachmentMenuAnchor = null
        }
    }

    TextArea {
        id: attachmentClipboardProxy
        visible: false
        width: 0
        height: 0
        text: ""
    }

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
                Item { Layout.fillWidth: true }
                Button {
                    text: root.tFunc("上传文件", "Upload file")
                    implicitHeight: 30
                    implicitWidth: 96
                    onClicked: root.uploadFileRequested("")
                }
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
        implicitHeight: checklistSection.implicitHeight + 16
        visible: !root.contentIsImageFunc(bodyTextFromContent(root.editTaskContent))
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

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: fileSection.implicitHeight + 16
        visible: root.attachmentPathsFromContent(root.editTaskContent).length > 0
        radius: 12
        color: root.homeDarkMode ? "#313b47" : "#fbfdff"
        border.color: root.detailBorderColor
        border.width: 1

        ColumnLayout {
            id: fileSection
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            Repeater {
                model: root.attachmentPathsFromContent(root.editTaskContent)
                delegate: Rectangle {
                    required property string modelData
                    Layout.fillWidth: true
                    implicitHeight: attachmentRow.implicitHeight + 8
                    radius: 10
                    color: root.homeDarkMode ? "#2f3742" : "#f8fafc"
                    border.color: root.detailBorderColor
                    border.width: 1

                    RowLayout {
                        id: attachmentRow
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        Rectangle { width: 3; height: 24; radius: 1.5; color: root.detailAccentColor }
                        Text {
                            text: root.attachmentIconForPath(modelData)
                            font.pixelSize: 16
                            Layout.preferredWidth: 22
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        Label {
                            Layout.fillWidth: true
                            text: root.selectedFileNameFunc ? root.selectedFileNameFunc(modelData) : modelData
                            color: fileTitleArea.containsMouse ? root.detailAccentColor : root.detailTextColor
                            font.pixelSize: Math.max(13, root.detailFontSize - 5)
                            font.bold: true
                            elide: Text.ElideMiddle

                            Behavior on color {
                                ColorAnimation { duration: 120 }
                            }

                            MouseArea {
                                id: fileTitleArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.openFileRequested(modelData)
                            }
                        }

                        Item {
                            id: attachmentMenuAnchor
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 30

                            Button {
                                id: attachmentOptionsButton
                                anchors.fill: parent
                                hoverEnabled: true
                                text: "⋯"
                                font.pixelSize: 18
                                onClicked: {
                                    attachmentMenuHideTimer.stop()
                                    if (attachmentOptionsPopup.visible && root.activeAttachmentPath === modelData && attachmentMenuPinned) {
                                        attachmentMenuPinned = false
                                        attachmentOptionsPopup.close()
                                    } else {
                                        attachmentMenuPinned = true
                                        root.showAttachmentMenu(attachmentMenuAnchor, modelData)
                                    }
                                }
                                onHoveredChanged: {
                                    if (hovered) {
                                        attachmentMenuHideTimer.stop()
                                        root.showAttachmentMenu(attachmentMenuAnchor, modelData)
                                    } else {
                                        root.scheduleAttachmentMenuHide()
                                    }
                                }
                                background: Rectangle {
                                    radius: 10
                                    color: attachmentOptionsPopup.visible && root.activeAttachmentPath === modelData ? (root.homeDarkMode ? "#2f3c4e" : "#dbeafe") : (parent.hovered ? (root.homeDarkMode ? "#3b4250" : "#e2e8f0") : "transparent")
                                    border.color: attachmentOptionsPopup.visible && root.activeAttachmentPath === modelData ? (root.homeDarkMode ? "#93c5fd" : "#60a5fa") : (parent.hovered ? (root.homeDarkMode ? "#64748b" : "#bfdbfe") : "transparent")
                                    border.width: attachmentOptionsPopup.visible && root.activeAttachmentPath === modelData ? 1.5 : (parent.hovered ? 1 : 0)

                                    Behavior on color {
                                        ColorAnimation { duration: 140 }
                                    }

                                    Behavior on border.color {
                                        ColorAnimation { duration: 140 }
                                    }
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: attachmentOptionsPopup.visible && root.activeAttachmentPath === modelData ? (root.homeDarkMode ? "#dbeafe" : "#2563eb") : root.detailHintTextColor
                                    font.pixelSize: parent.font.pixelSize
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter

                                    Behavior on color {
                                        ColorAnimation { duration: 140 }
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
