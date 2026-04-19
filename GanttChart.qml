// 甘特图主组件 - 任务时间轴可视化
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import GanttModel 1.0

Item {
    id: ganttChart
    anchors.fill: parent

    property int dayWidth: 60
    property int rowHeight: 58
    property int headerHeight: 60
    property int toolbarHeight: 52
    property int taskListWidth: 220
    property color backgroundColor: "#ffffff"
    property color gridColor: blueGridLinesEnabled ? "#cfe4f8" : "#e0e0e0"
    property color todayColor: blueTodayColumnEnabled ? "#e0f2fe" : "#fff3cd"
    property bool blueTaskBarsEnabled: true
    property bool blueTodayColumnEnabled: true
    property bool blueGridLinesEnabled: true
    readonly property color toolbarBg: "#f8fbff"
    readonly property color toolbarBorder: "#dbe4f0"
    readonly property color toolbarText: "#1e293b"
    readonly property color toolbarButtonBg: "#e0f2fe"
    readonly property color toolbarButtonBgPressed: "#bae6fd"
    readonly property color toolbarButtonBorder: "#7dd3fc"
    readonly property color toolbarButtonText: "#0f4c81"
    readonly property color toolbarButtonActiveBg: "#38bdf8"
    readonly property color toolbarButtonActiveText: "#ffffff"
    readonly property color ganttBarThemeColor: "#38bdf8"

    function priorityColor(priority) {
        switch (priority) {
        case 4:
            return "#dc2626"
        case 3:
            return "#ea580c"
        case 2:
            return "#d97706"
        default:
            return "#64748b"
        }
    }

    function priorityLabel(priority) {
        switch (priority) {
        case 4:
            return "P4"
        case 3:
            return "P3"
        case 2:
            return "P2"
        default:
            return "P1"
        }
    }

    signal taskClicked(int taskId)
    signal taskDatesChanged(int taskId, string startDate, string endDate)
    signal taskProgressChanged(int taskId, int progress)

    property date currentDate: new Date()

    component ToolbarButton: Button {
        implicitHeight: 34
        font.pixelSize: 13

        background: Rectangle {
            radius: 10
            color: parent.highlighted ? toolbarButtonActiveBg : (parent.pressed ? toolbarButtonBgPressed : toolbarButtonBg)
            border.color: parent.highlighted ? "#0ea5e9" : toolbarButtonBorder
            border.width: 1
        }

        contentItem: Text {
            text: parent.text
            color: parent.highlighted ? toolbarButtonActiveText : toolbarButtonText
            font.pixelSize: 13
            font.bold: parent.highlighted
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: taskListPanel
            Layout.preferredWidth: ganttChart.taskListWidth
            Layout.fillHeight: true
            color: "#f8fbff"
            border.color: "#dbe4f0"
            border.width: 1

            Column {
                anchors.fill: parent

                Rectangle {
                    width: parent.width
                    height: toolbarHeight
                    color: toolbarBg
                    border.width: 0
                }

                Rectangle {
                    width: parent.width
                    height: headerHeight
                    color: "#eef6ff"
                    border.color: "#dbe4f0"
                    border.width: 1

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        text: "任务"
                        font.pixelSize: 15
                        font.bold: true
                        color: "#0f172a"
                    }
                }

                ListView {
                    id: taskTitleListView
                    width: parent.width
                    height: parent.height - toolbarHeight - headerHeight
                    model: GanttModel
                    interactive: false
                    clip: true

                    delegate: Rectangle {
                        width: taskTitleListView.width
                        height: rowHeight
                        color: index % 2 === 0 ? "#f8fbff" : "#fdfefe"
                        border.color: "#e2e8f0"
                        border.width: 1

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 12
                            anchors.rightMargin: 10
                            spacing: 10

                            Rectangle {
                                width: 8
                                height: parent.height - 20
                                radius: 4
                                color: ganttChart.priorityColor(model.priority)
                            }

                            Column {
                                width: parent.parent.width - 58
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 3

                                Row {
                                    spacing: 6

                                    Text {
                                        text: model.title
                                        width: Math.max(40, parent.parent.width - priorityBadge.width - 10)
                                        font.pixelSize: 13
                                        font.bold: true
                                        color: "#0f172a"
                                        elide: Text.ElideRight
                                    }

                                    Rectangle {
                                        id: priorityBadge
                                        height: 20
                                        width: 30
                                        radius: 10
                                        color: ganttChart.priorityColor(model.priority)

                                        Text {
                                            anchors.centerIn: parent
                                            text: ganttChart.priorityLabel(model.priority)
                                            font.pixelSize: 10
                                            font.bold: true
                                            color: "#ffffff"
                                        }
                                    }
                                }

                                Text {
                                    text: (model.categoryName || "未分类")
                                    width: parent.width
                                    font.pixelSize: 11
                                    color: "#64748b"
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: ganttPanel
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: backgroundColor

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: toolbarHeight
                    color: toolbarBg
                    border.width: 0

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 10

                        ToolbarButton {
                            text: "上一周"
                            implicitWidth: 74
                            onClicked: GanttModel.moveToPreviousWeek()
                        }

                        ToolbarButton {
                            text: "今天"
                            highlighted: true
                            implicitWidth: 60
                            onClicked: GanttModel.moveToToday()
                        }

                        ToolbarButton {
                            text: "下一周"
                            implicitWidth: 74
                            onClicked: GanttModel.moveToNextWeek()
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            radius: 12
                            color: "#eef8ff"
                            border.color: "#b9e6fb"
                            border.width: 1
                            implicitHeight: 34
                            implicitWidth: dateRangeText.implicitWidth + 22

                            Text {
                                id: dateRangeText
                                anchors.centerIn: parent
                                text: {
                                    var start = GanttModel.viewStartDate
                                    var end = GanttModel.viewEndDate
                                    return Qt.formatDate(start, "MM月dd日") + " - " + Qt.formatDate(end, "MM月dd日")
                                }
                                font.pixelSize: 13
                                font.bold: true
                                color: "#0f4c81"
                            }
                        }
                    }
                }

                GanttHeader {
                    id: ganttHeader
                    Layout.fillWidth: true
                    height: headerHeight
                    dayWidth: ganttChart.dayWidth
                    totalDays: GanttModel.totalDays
                    startDate: GanttModel.viewStartDate
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Canvas {
                        id: gridCanvas
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)

                            ctx.strokeStyle = gridColor
                            ctx.lineWidth = 1

                            var totalDays = GanttModel.totalDays
                            for (var i = 0; i <= totalDays; i++) {
                                var x = i * dayWidth
                                ctx.beginPath()
                                ctx.moveTo(x, 0)
                                ctx.lineTo(x, height)
                                ctx.stroke()
                            }

                            var rowCount = ganttListView.count
                            for (var j = 0; j <= rowCount; j++) {
                                var y = j * rowHeight
                                ctx.beginPath()
                                ctx.moveTo(0, y)
                                ctx.lineTo(width, y)
                                ctx.stroke()
                            }
                        }

                        Connections {
                            target: GanttModel
                            function onTasksLoaded() { gridCanvas.requestPaint() }
                            function onViewDateChanged() { gridCanvas.requestPaint() }
                        }
                    }

                    Rectangle {
                        id: todayHighlight
                        width: dayWidth
                        height: parent.height
                        color: todayColor
                        opacity: 0.5
                        visible: {
                            var today = new Date()
                            var start = GanttModel.viewStartDate
                            var end = GanttModel.viewEndDate
                            today >= start && today <= end
                        }
                        x: {
                            var today = new Date()
                            var start = GanttModel.viewStartDate
                            var diff = Math.floor((today - start) / (1000 * 60 * 60 * 24))
                            return diff * dayWidth
                        }
                    }

                    ListView {
                        id: ganttListView
                        anchors.fill: parent
                        model: GanttModel
                        interactive: false
                        clip: true

                        delegate: Item {
                            width: ganttListView.width
                            height: rowHeight

                            GanttTaskBar {
                                y: 7
                                height: rowHeight - 14
                                taskId: model.taskId
                                title: model.title
                                categoryName: model.categoryName
                                description: model.description
                                barColor: ganttChart.blueTaskBarsEnabled ? ganttChart.ganttBarThemeColor : (model.categoryColor ? model.categoryColor : (model.color ? model.color : "#94a3b8"))
                                progress: model.progress
                                startOffset: model.startOffset
                                duration: model.duration
                                dayWidth: ganttChart.dayWidth
                                priority: model.priority

                                onDragFinished: function(newStartOffset, newDuration) {
                                    var startDate = new Date(GanttModel.viewStartDate)
                                    startDate.setDate(startDate.getDate() + newStartOffset)
                                    var endDate = new Date(startDate)
                                    endDate.setDate(endDate.getDate() + newDuration - 1)

                                    GanttModel.updateTaskDates(model.taskId, startDate, endDate)
                                    ganttChart.taskDatesChanged(model.taskId,
                                        startDate.toISOString().split('T')[0],
                                        endDate.toISOString().split('T')[0])
                                }

                                onProgressChangedByUser: (newProgress) => {
                                    GanttModel.updateTaskProgress(model.taskId, newProgress)
                                    ganttChart.taskProgressChanged(model.taskId, newProgress)
                                }

                                onClicked: ganttChart.taskClicked(model.taskId)
                            }
                        }
                    }
                }
            }
        }
    }


}
