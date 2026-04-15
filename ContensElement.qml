//数据纲要显示模型
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    width: 432
    height: 112
    property int taskId: -1
    property string title: "未命名标题"
    property string time: "2025-01-01 00:00:00"
    property string timeFormat: "yyyy-MM-dd HH:mm:ss"
    property string displayTime: time
    property string outline: "暂无概要"
    property string dueDate: ""
    property string categoryName: "未分类"
    property string categoryColor: "#94a3b8"
    property bool completed: false
    property bool todaySelected: false
    property real doneScale: 1
    property real doneCheckOpacity: completed ? 1 : 0
    property real doneFlashOpacity: 0
    property real donePulseOpacity: 0
    signal markTodayRequested()
    signal completedToggled(bool completed)
    property int fontScale: 15
    signal detailedRequested()
    signal outlineEdited(string outline)
    signal categoryChanged(int categoryId, string categoryName, string categoryColor)

    readonly property color cardBackground: completed
                                            ? (mainWindow.homeDarkMode ? "#2f3640" : "#f8fafc")
                                            : (mainWindow.homeDarkMode ? "#3a4049" : "#ffffff")
    readonly property color cardBorder: completed
                                        ? (mainWindow.homeDarkMode ? "#64748b" : "#cbd5e1")
                                        : (mainWindow.homeDarkMode ? "#4b5563" : "#d8dee8")
    readonly property color titleColor: completed
                                        ? (mainWindow.homeDarkMode ? "#94a3b8" : "#64748b")
                                        : (mainWindow.homeDarkMode ? "#f3f4f6" : "#0f172a")
    readonly property color textColor: completed
                                       ? (mainWindow.homeDarkMode ? "#94a3b8" : "#64748b")
                                       : (mainWindow.homeDarkMode ? "#d1d5db" : "#475569")
    readonly property color timeColor: completed
                                       ? (mainWindow.homeDarkMode ? "#64748b" : "#94a3b8")
                                       : (mainWindow.homeDarkMode ? "#9ca3af" : "#64748b")
    readonly property color editorBackground: completed
                                              ? (mainWindow.homeDarkMode ? "#39414c" : "#e2e8f0")
                                              : (mainWindow.homeDarkMode ? "#454c56" : "#ffffff")
    readonly property color doneBadgeBackground: mainWindow.homeDarkMode ? "#14532d" : "#dcfce7"
    readonly property color doneBadgeBorder: mainWindow.homeDarkMode ? "#22c55e" : "#86efac"
    readonly property color doneBadgeText: mainWindow.homeDarkMode ? "#bbf7d0" : "#166534"
    readonly property color remindBackground: completed
                                              ? (mainWindow.homeDarkMode ? "#243447" : "#dbeafe")
                                              : (mainWindow.homeDarkMode ? "#374151" : "#eff6ff")
    readonly property color remindBorder: completed
                                          ? (mainWindow.homeDarkMode ? "#3b82f6" : "#93c5fd")
                                          : "#93c5fd"
    readonly property color remindTextColor: completed
                                             ? (mainWindow.homeDarkMode ? "#dbeafe" : "#1d4ed8")
                                             : "#1d4ed8"
    readonly property color statusBackground: completed
                                              ? (mainWindow.homeDarkMode ? "#163826" : "#ecfdf5")
                                              : (mainWindow.homeDarkMode ? "#3f1d24" : "#fff1f2")
    readonly property color statusBorder: completed
                                          ? (mainWindow.homeDarkMode ? "#4ade80" : "#86efac")
                                          : (mainWindow.homeDarkMode ? "#f87171" : "#fca5a5")
    readonly property color statusTextColor: completed
                                             ? (mainWindow.homeDarkMode ? "#bbf7d0" : "#166534")
                                             : (mainWindow.homeDarkMode ? "#fecaca" : "#b91c1c")
    readonly property color todayButtonBackground: completed
                                                   ? (mainWindow.homeDarkMode ? "#303844" : "#e5e7eb")
                                                   : todaySelected
                                                     ? (mainWindow.homeDarkMode ? "#1e293b" : "#dbeafe")
                                                     : (mainWindow.homeDarkMode ? "#334155" : "#f8fafc")
    readonly property color todayButtonBorder: completed
                                               ? (mainWindow.homeDarkMode ? "#4b5563" : "#cbd5e1")
                                               : todaySelected
                                                 ? (mainWindow.homeDarkMode ? "#60a5fa" : "#2563eb")
                                                 : (mainWindow.homeDarkMode ? "#64748b" : "#cbd5e1")
    readonly property color todayButtonText: completed
                                             ? (mainWindow.homeDarkMode ? "#94a3b8" : "#94a3b8")
                                             : todaySelected
                                               ? "#ffffff"
                                               : (mainWindow.homeDarkMode ? "#e2e8f0" : "#475569")
    readonly property color archiveEditorBorder: completed
                                                ? (mainWindow.homeDarkMode ? "#475569" : "#cbd5e1")
                                                : "transparent"
    readonly property real doneCardOpacity: completed ? 0.84 : 1
    readonly property real doneFlashPeakOpacity: mainWindow.homeDarkMode ? 0.6 : 0.95
    readonly property real donePulsePeakOpacity: mainWindow.homeDarkMode ? 0.12 : 0.22

    onCompletedChanged: {
        if (completed) {
            doneCheckOpacity = 0
            doneFlashOpacity = doneFlashPeakOpacity
            donePulseOpacity = donePulsePeakOpacity
            bounceOut.start()
            checkFadeIn.start()
            flashFadeOut.start()
            pulseFadeOut.start()
        } else {
            bounceOut.stop()
            bounceBack.stop()
            checkFadeIn.stop()
            flashFadeOut.stop()
            pulseFadeOut.stop()
            doneScale = 1
            doneCheckOpacity = 0
            doneFlashOpacity = 0
            donePulseOpacity = 0
        }
    }

    SequentialAnimation {
        id: bounceOut
        running: false

        NumberAnimation {
            target: root
            property: "doneScale"
            from: 1
            to: 0.94
            duration: 75
            easing.type: Easing.OutQuad
        }

        ScriptAction {
            script: bounceBack.start()
        }
    }

    NumberAnimation {
        id: bounceBack
        target: root
        property: "doneScale"
        from: 0.94
        to: 1
        duration: 75
        easing.type: Easing.OutBack
    }

    NumberAnimation {
        id: checkFadeIn
        target: root
        property: "doneCheckOpacity"
        from: 0
        to: 1
        duration: 180
        easing.type: Easing.OutQuad
    }

    NumberAnimation {
        id: flashFadeOut
        target: root
        property: "doneFlashOpacity"
        from: 0.95
        to: 0
        duration: 240
        easing.type: Easing.OutQuad
    }

    NumberAnimation {
        id: pulseFadeOut
        target: root
        property: "donePulseOpacity"
        from: 0.22
        to: 0
        duration: 300
        easing.type: Easing.OutCubic
    }

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: 1
        anchors.rightMargin: 1
        anchors.topMargin: 1
        anchors.bottomMargin: 1
        color: cardBackground
        radius: 10
        border.color: cardBorder
        border.width: 1
        opacity: doneCardOpacity
        scale: doneScale
        transformOrigin: Item.Center

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: mainWindow.homeDarkMode ? "#34d399" : "#bbf7d0"
            opacity: donePulseOpacity
            z: 1
        }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: completed ? (mainWindow.homeDarkMode ? "#cbd5e1" : "#ffffff") : "transparent"
            opacity: completed ? (mainWindow.homeDarkMode ? 0.04 : 0.26) : 0
        }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.color: mainWindow.homeDarkMode ? "#22c55e" : "#22c55e"
            border.width: mainWindow.homeDarkMode ? 1.5 : 2
            opacity: doneFlashOpacity
            z: 2
        }

        Rectangle {
            visible: completed
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 8
            anchors.rightMargin: 8
            width: 26
            height: 26
            radius: 13
            color: mainWindow.homeDarkMode ? "#166534" : "#22c55e"
            border.color: mainWindow.homeDarkMode ? "#86efac" : "#bbf7d0"
            border.width: 1
            z: 3
            opacity: doneCheckOpacity

            Text {
                anchors.centerIn: parent
                text: "✓"
                color: "#f8fafc"
                font.pixelSize: 14
                font.bold: true
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 6

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: title
                    font.pixelSize: fontScale
                    font.bold: !completed
                    font.strikeout: completed
                    color: titleHoverArea.containsMouse ? "#2563eb" : titleColor
                    Layout.fillWidth: true
                    elide: Text.ElideRight

                    MouseArea {
                        id: titleHoverArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: detailedRequested()
                    }
                }

                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    implicitWidth: titleHoverArea.containsMouse ? 18 : 12
                    implicitHeight: 18
                    radius: 9
                    color: "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "→"
                        color: titleHoverArea.containsMouse ? "#2563eb" : timeColor
                        font.pixelSize: 12
                        font.bold: true
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: editorBackground
                opacity: completed ? 0.82 : 1
                border.color: completed ? archiveEditorBorder : (outlineEditor.activeFocus ? "#60a5fa" : "transparent")
                border.width: completed ? 1 : (outlineEditor.activeFocus ? 1 : 0)

                TextArea {
                    id: outlineEditor
                    anchors.fill: parent
                    anchors.margins: 5
                    wrapMode: TextEdit.Wrap
                    selectByMouse: true
                    readOnly: completed
                    activeFocusOnPress: !completed
                    text: outline === "" ? "" : outline
                    color: textColor
                    font.pixelSize: Math.max(11, fontScale - 3)
                    placeholderText: completed ? "已归档概要" : "点击这里直接修改描述"
                    opacity: completed ? 0.9 : 1
                    background: null

                    onActiveFocusChanged: {
                        if (!activeFocus) {
                            const trimmed = text.trim()
                            const normalizedOld = outline === "暂无概要" ? "" : outline
                            if (trimmed !== normalizedOld) {
                                outlineEdited(trimmed)
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                Rectangle {
                    width: 10
                    height: 10
                    radius: 5
                    color: completed ? (mainWindow.homeDarkMode ? "#86efac" : "#22c55e") : categoryColor
                }

                Rectangle {
                    visible: completed
                    implicitWidth: 52
                    implicitHeight: 24
                    radius: 999
                    color: doneBadgeBackground
                    border.color: doneBadgeBorder
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "✓ 完成"
                        color: doneBadgeText
                        font.pixelSize: 11
                        font.bold: true
                    }
                }


                Button {
                    text: completed ? "已完成" : "未完成"
                    implicitHeight: 24
                    implicitWidth: 54
                    onClicked: completedToggled(!completed)

                    background: Rectangle {
                        radius: 8
                        color: statusBackground
                        border.color: statusBorder
                        border.width: 1
                    }

                    contentItem: Text {
                        text: parent.text
                        color: statusTextColor
                        font.pixelSize: 11
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    text: "今日"
                    implicitHeight: 24
                    implicitWidth: 50
                    enabled: !completed && !todaySelected
                    opacity: completed ? 0.6 : 1
                    onClicked: if (!todaySelected) markTodayRequested()

                    background: Rectangle {
                        radius: 8
                        color: todayButtonBackground
                        border.color: todayButtonBorder
                        border.width: 1
                    }

                    contentItem: Text {
                        text: parent.text
                        color: todayButtonText
                        font.pixelSize: 11
                        font.bold: !completed
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                ComboBox {
                    id: categorySelector
                    implicitHeight: 24
                    implicitWidth: 88
                    enabled: !completed
                    model: {
                        const items = [mainWindow.t("未分类", "Uncategorized")]
                        for (let i = 0; i < mainWindow.categoryList.length; ++i) {
                            items.push(mainWindow.categoryList[i].name)
                        }
                        return items
                    }
                    currentIndex: {
                        if (!categoryName || categoryName === "" || categoryName === "未分类") {
                            return 0
                        }
                        for (let i = 0; i < mainWindow.categoryList.length; ++i) {
                            if (mainWindow.categoryList[i].name === categoryName) {
                                return i + 1
                            }
                        }
                        return 0
                    }

                    onActivated: {
                        if (currentIndex <= 0) {
                            categoryChanged(0, mainWindow.t("未分类", "Uncategorized"), "#94a3b8")
                            return
                        }
                        const category = mainWindow.categoryList[currentIndex - 1]
                        categoryChanged(category.categoryId, category.name, category.color)
                    }

                    indicator: Text {
                        x: categorySelector.width - width - 8
                        y: (categorySelector.height - height) / 2
                        text: "▾"
                        color: timeColor
                        font.pixelSize: Math.max(10, fontScale - 3)
                    }

                    background: Rectangle {
                        radius: 8
                        color: completed ? (mainWindow.homeDarkMode ? "#303844" : "#f8fafc") : (mainWindow.homeDarkMode ? "#334155" : "#ffffff")
                        border.color: categorySelector.popup.visible
                                      ? "#60a5fa"
                                      : (completed ? (mainWindow.homeDarkMode ? "#4b5563" : "#cbd5e1") : (mainWindow.homeDarkMode ? "#64748b" : "#d8dee8"))
                        border.width: 1
                    }

                    contentItem: Text {
                        text: categorySelector.displayText
                        color: timeColor
                        font.pixelSize: Math.max(10, fontScale - 4)
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 8
                        rightPadding: 18
                        elide: Text.ElideRight
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: displayTime
                    font.pixelSize: Math.max(10, fontScale - 4)
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideNone
                    wrapMode: Text.NoWrap
                    color: timeColor
                }
            }
        }
    }
}
