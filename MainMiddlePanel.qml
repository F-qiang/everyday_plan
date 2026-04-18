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
    property bool showSortControl: false
    property var sortOptions: []
    property int selectedSortIndex: 0
    property int hoveredSortIndex: -1
    property var selectedSortOption: sortOptions.length > 0 && selectedSortIndex >= 0 && selectedSortIndex < sortOptions.length ? sortOptions[selectedSortIndex] : null
    readonly property string hoveredSortLabel: hoveredSortIndex >= 0 && hoveredSortIndex < sortOptions.length ? sortOptions[hoveredSortIndex].label : ""
    signal sortIndexChanged(int index)
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
                    Layout.alignment: Qt.AlignVCenter
                    text: root.pageTitle
                    color: homeDarkMode ? "#f3f4f6" : "#0f172a"
                    font.pixelSize: 18
                    font.bold: true
                }

                Label {
                    Layout.alignment: Qt.AlignVCenter
                    visible: parent.parent.abstractVisible
                    text: qsTr("可直接点击标题选择任务")
                    color: root.detailHintTextColor
                    font.pixelSize: 12
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    id: sortActionButton
                    visible: root.showSortControl && root.sortOptions.length > 0
                    implicitWidth: 34
                    implicitHeight: 34
                    Layout.alignment: Qt.AlignVCenter
                    radius: 17
                    color: sortButtonArea.containsMouse || sortMenu.visible
                           ? (homeDarkMode ? "#313844" : "#f8fafc")
                           : (homeDarkMode ? "#3a4049" : "#ffffff")
                    border.color: sortMenu.visible
                                  ? (homeDarkMode ? "#60a5fa" : "#2563eb")
                                  : (homeDarkMode ? "#4b5563" : "#d8dee8")
                    border.width: 1

                    Canvas {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: -1
                        width: 16
                        height: 16
                        contextType: "2d"

                        onPaint: {
                            context.reset()
                            context.strokeStyle = homeDarkMode ? "#dbeafe" : "#2563eb"
                            context.lineWidth = 1.6
                            context.lineCap = "round"
                            context.lineJoin = "round"

                            context.beginPath()
                            context.moveTo(2, 3)
                            context.lineTo(14, 3)
                            context.lineTo(10, 7)
                            context.lineTo(10, 12)
                            context.lineTo(6, 14)
                            context.lineTo(6, 7)
                            context.closePath()
                            context.stroke()

                            context.beginPath()
                            context.moveTo(3, 5)
                            context.lineTo(13, 5)
                            context.stroke()
                        }
                    }

                    MouseArea {
                        id: sortButtonArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        function openSortMenu() {
                            const point = sortActionButton.mapToItem(root, 0, sortActionButton.height + 4)
                            sortMenu.x = Math.min(Math.max(8, point.x), Math.max(8, root.width - sortMenu.width - 8))
                            sortMenu.y = point.y
                            if (!sortMenu.visible) {
                                sortMenu.open()
                            }
                        }

                        onEntered: {
                            sortMenuCloseTimer.stop()
                            openSortMenu()
                        }
                        onExited: sortMenuCloseTimer.restart()
                        onClicked: openSortMenu()
                    }
                }
            }
        }

        Popup {
            id: sortMenu
            parent: root
            modal: false
            focus: true
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
            width: 204
            height: 112
            padding: 0

            enter: Transition {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 120 }
            }

            exit: Transition {
                NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 90 }
            }

            background: Rectangle {
                radius: 18
                color: "#ffffff"
                border.color: homeDarkMode ? "#dbe4f0" : "#d8dee8"
                border.width: 1
            }

            Rectangle {
                visible: root.hoveredSortLabel !== ""
                x: Math.max(8, Math.min(sortMenu.width - width - 8, 12))
                y: -34
                width: hoverHintText.implicitWidth + 20
                height: 28
                radius: 10
                color: "#ffffff"
                border.color: homeDarkMode ? "#dbe4f0" : "#d8dee8"
                border.width: 1
                z: 10

                Text {
                    id: hoverHintText
                    anchors.centerIn: parent
                    text: root.hoveredSortLabel
                    color: "#0f172a"
                    font.pixelSize: 12
                    font.bold: true
                }
            }

            contentItem: Item {
                id: sortMenuContent
                anchors.fill: parent
                anchors.margins: 10

                HoverHandler {
                    id: sortMenuHoverArea
                    target: sortMenuContent
                    onHoveredChanged: {
                        if (hovered) {
                            sortMenuCloseTimer.stop()
                        } else {
                            root.hoveredSortIndex = -1
                            sortMenuCloseTimer.restart()
                        }
                    }
                }

                Grid {
                    anchors.centerIn: parent
                    rows: 2
                    columns: 4
                    rowSpacing: 8
                    columnSpacing: 8

                    Repeater {
                        model: root.sortOptions

                        delegate: Rectangle {
                            required property int index
                            required property var modelData
                            width: 40
                            height: 40
                            radius: 12
                            color: index === root.selectedSortIndex
                                   ? "#e8f0fe"
                                   : (menuHover.containsMouse ? "#f8fbff" : "transparent")
                            border.color: index === root.selectedSortIndex ? "#2563eb" : "transparent"
                            border.width: index === root.selectedSortIndex ? 1 : 0

                            readonly property string mainIcon: modelData.field === "priority"
                                                               ? "⚑"
                                                               : (modelData.field === "createdAt"
                                                                  ? "🕒"
                                                                  : (modelData.field === "dueDate" ? "⏰" : "↗"))
                            readonly property string orderIcon: modelData.descending ? "↓" : "↑"
                            readonly property string hoverLabel: modelData.label

                            Text {
                                anchors.centerIn: parent
                                text: parent.mainIcon
                                font.pixelSize: 16
                                color: index === root.selectedSortIndex ? "#2563eb" : "#475569"
                            }

                            Text {
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.rightMargin: 6
                                anchors.bottomMargin: 4
                                text: parent.orderIcon
                                font.pixelSize: 10
                                font.bold: true
                                color: index === root.selectedSortIndex ? "#2563eb" : "#94a3b8"
                            }

                            MouseArea {
                                id: menuHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: root.hoveredSortIndex = index
                                onExited: if (root.hoveredSortIndex === index) root.hoveredSortIndex = -1
                                onClicked: {
                                    root.sortIndexChanged(index)
                                    root.hoveredSortIndex = -1
                                    sortMenu.close()
                                }
                            }
                        }
                    }
                }
            }
        }

        Timer {
            id: sortMenuCloseTimer
            interval: 260
            repeat: false
            onTriggered: {
                if (!sortButtonArea.containsMouse && !sortMenuHoverArea.hovered) {
                    sortMenu.close()
                }
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
