// 甘特图任务条组件 - 可拖拽调整
import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: taskBar
    height: 40

    property int taskId: 0
    property string title: ""
    property string categoryName: "未分类"
    property string description: ""
    property color barColor: "#3498db"
    readonly property color barBase: barColor
    readonly property color barProgressStart: Qt.lighter(barBase, 1.38)
    readonly property color barProgressEnd: Qt.lighter(barBase, 1.18)
    readonly property color barTextColor: Qt.hsla(0.0, 0.0, 1.0, 0.96)
    readonly property color barSubTextColor: Qt.hsla(0.58, 0.55, 0.96, 0.94)
    property int progress: 0
    property int startOffset: 0
    property int duration: 1
    property int dayWidth: 60
    property int priority: 1

    signal clicked()
    signal dragFinished(int newStartOffset, int newDuration)
    signal progressChangedByUser(int newProgress)

    x: startOffset * dayWidth
    width: duration * dayWidth

    property bool isDragging: false
    property bool isResizing: false

    Rectangle {
        id: barRect
        anchors.fill: parent
        anchors.margins: 2
        radius: 6
        color: barBase

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * (progress / 100)
            radius: 6
            color: barProgressEnd

            gradient: Gradient {
                GradientStop { position: 0.0; color: barProgressStart }
                GradientStop { position: 1.0; color: barProgressEnd }
            }
        }

        Column {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 1

            Text {
                width: parent.width
                text: title
                font.pixelSize: 12
                font.bold: true
                color: barTextColor
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: categoryName === "" ? "未分类" : categoryName
                font.pixelSize: 10
                color: barSubTextColor
                elide: Text.ElideRight
                visible: taskBar.width >= 90
            }
        }

        Text {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 4
            text: progress + "%"
            font.pixelSize: 10
            color: barTextColor
            visible: progress > 0
        }

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: 4
            width: 8
            height: 8
            radius: 4
            color: {
                switch(priority) {
                    case 4: return "#e74c3c"
                    case 3: return "#e67e22"
                    case 2: return "#f1c40f"
                    default: return "transparent"
                }
            }
        }

        MouseArea {
            id: dragArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.SizeHorCursor

            drag.target: taskBar
            drag.axis: Drag.XAxis
            drag.minimumX: 0
            drag.maximumX: taskBar.parent.width - taskBar.width

            onPressed: {
                isDragging = true
                taskBar.z = 100
            }

            onReleased: {
                isDragging = false
                taskBar.z = 1

                var newOffset = Math.round(taskBar.x / dayWidth)
                taskBar.x = newOffset * dayWidth

                dragFinished(newOffset, duration)
            }

            onClicked: taskBar.clicked()
        }

        Rectangle {
            id: leftHandle
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 8
            color: "transparent"

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.SizeHorCursor

                property real startX: 0
                property int originalOffset: 0

                onPressed: {
                    startX = mouse.x
                    originalOffset = startOffset
                    isResizing = true
                }

                onPositionChanged: {
                    if (pressed) {
                        var deltaX = mouse.x - startX
                        var offsetDelta = Math.round(deltaX / dayWidth)
                        var newOffset = originalOffset + offsetDelta

                        if (newOffset >= 0 && newOffset < startOffset + duration - 1) {
                            var newDuration = duration - offsetDelta
                            if (newDuration >= 1) {
                                taskBar.x = newOffset * dayWidth
                                taskBar.width = newDuration * dayWidth
                            }
                        }
                    }
                }

                onReleased: {
                    isResizing = false
                    var newOffset = Math.round(taskBar.x / dayWidth)
                    var newDuration = Math.round(taskBar.width / dayWidth)
                    dragFinished(newOffset, newDuration)
                }
            }
        }

        Rectangle {
            id: rightHandle
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 8
            color: "transparent"

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.SizeHorCursor

                property real startX: 0
                property int originalWidth: 0

                onPressed: {
                    startX = mouse.x
                    originalWidth = taskBar.width
                    isResizing = true
                }

                onPositionChanged: {
                    if (pressed) {
                        var deltaX = mouse.x - startX
                        var newWidth = originalWidth + deltaX
                        var newDuration = Math.round(newWidth / dayWidth)

                        if (newDuration >= 1) {
                            taskBar.width = newDuration * dayWidth
                        }
                    }
                }

                onReleased: {
                    isResizing = false
                    var newDuration = Math.round(taskBar.width / dayWidth)
                    dragFinished(startOffset, newDuration)
                }
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 6
            radius: 3
            color: "#ffffff"
            opacity: 0.22
            visible: taskBar.width >= 100

            Rectangle {
                width: parent.width * (progress / 100)
                height: parent.height
                radius: 3
                color: "#ffffff"
                opacity: 0.45
            }

            MouseArea {
                anchors.fill: parent
                enabled: taskBar.width >= 100
                onClicked: (mouse) => {
                    const ratio = Math.max(0, Math.min(1, mouse.x / width))
                    progressChangedByUser(Math.round(ratio * 100))
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "#ffffff"
            opacity: dragArea.containsMouse ? 0.1 : 0
            radius: 6

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }
        }

        ToolTip.visible: dragArea.containsMouse
        ToolTip.text: title + "\n" + (description === "" ? "暂无描述" : description) + "\n进度：" + progress + "%"
        ToolTip.delay: 250
    }

    Rectangle {
        anchors.fill: barRect
        anchors.margins: -3
        radius: 9
        color: "transparent"
        border.color: barColor
        border.width: 2
        visible: isDragging || isResizing
        opacity: 0.5
    }

    Behavior on x {
        enabled: !isDragging && !isResizing
        NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
    }

    Behavior on width {
        enabled: !isDragging && !isResizing
        NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
    }
}
