import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ToolButton {
    id: root

    property int navFontSize: 18

    autoExclusive: false
    font.pointSize: navFontSize - 1
    implicitHeight: 32
    padding: 0
    topPadding: 0
    bottomPadding: 0
    leftPadding: 10
    rightPadding: 10
    Layout.fillWidth: true
    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

    background: Rectangle {
        radius: 12
        color: parent.checked ? "#eff6ff" : (parent.pressed ? "#f8fafc" : "#ffffff")
        border.color: parent.checked ? "#60a5fa" : (parent.pressed ? "#bfdbfe" : "#d8dee8")
        border.width: parent.checked ? 2 : 1
    }

    contentItem: Text {
        text: parent.text
        color: parent.checked ? "#1d4ed8" : "#1f2937"
        font.pointSize: root.navFontSize
        font.bold: parent.checked
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        elide: Text.ElideRight
    }
}
