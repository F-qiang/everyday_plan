// 甘特图时间轴头部组件
import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: ganttHeader
    height: 60
    
    property int dayWidth: 60
    property int totalDays: 14
    property date startDate: new Date()
    readonly property color weekdayBg: "#38bdf8"
    readonly property color weekdayBorder: "#0ea5e9"
    readonly property color weekendOverlay: "#e0f2fe"
    readonly property color todayOverlay: "#7dd3fc"
    readonly property color weekdayText: "#eff8ff"
    readonly property color todayText: "#0f4c81"
    
    Row {
        id: headerRow
        height: parent.height
        
        Repeater {
            model: totalDays
            
            Rectangle {
                width: dayWidth
                height: ganttHeader.height
                color: weekdayBg
                border.color: weekdayBorder
                border.width: 1
                
                // 判断是否是今天
                property bool isToday: {
                    var date = new Date(startDate)
                    date.setDate(date.getDate() + index)
                    var today = new Date()
                    return date.toDateString() === today.toDateString()
                }
                
                // 判断是否是周末
                property bool isWeekend: {
                    var date = new Date(startDate)
                    date.setDate(date.getDate() + index)
                    var day = date.getDay()
                    return day === 0 || day === 6
                }
                
                // 背景色
                Rectangle {
                    anchors.fill: parent
                    color: isToday ? todayOverlay : (isWeekend ? weekendOverlay : "transparent")
                    opacity: isToday ? 0.9 : 0.32
                }
                
                Column {
                    anchors.centerIn: parent
                    spacing: 2
                    
                    // 星期
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: {
                            var date = new Date(startDate)
                            date.setDate(date.getDate() + index)
                            var days = ["日", "一", "二", "三", "四", "五", "六"]
                            return "周" + days[date.getDay()]
                        }
                        font.pixelSize: 12
                        color: isToday ? todayText : weekdayText
                    }
                    
                    // 日期
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: {
                            var date = new Date(startDate)
                            date.setDate(date.getDate() + index)
                            return Qt.formatDate(date, "MM/dd")
                        }
                        font.pixelSize: 14
                        font.bold: isToday
                        color: isToday ? todayText : weekdayText
                    }
                }
            }
        }
    }
    
    // 底部阴影
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 3
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#20000000" }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }
}
