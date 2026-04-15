import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    property string titleText: ""
    property string compactTitleText: ""
    property bool compactDetailMode: false
    property bool showActions: false
    property bool homeDarkMode: true
    property int detailFontSize: 20
    property color detailTextColor: "#0f172a"
    property color compactTitleColor: "#111827"
    signal saveClicked()
    signal deleteClicked()

    implicitHeight: root.showActions ? Math.max(40, detailActionRow.implicitHeight) : 34

    RowLayout {
        anchors.fill: parent
        spacing: 8

        Label {
            visible: !root.compactDetailMode
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            text: root.titleText
            font.pixelSize: root.showActions ? root.detailFontSize : Math.max(18, root.detailFontSize - 1)
            font.bold: true
            color: root.detailTextColor
            elide: Text.ElideRight
        }

        Item { Layout.fillWidth: true; visible: !root.showActions }

        Item {
            visible: root.showActions
            implicitWidth: detailActionRow.implicitWidth
            implicitHeight: detailActionRow.implicitHeight

            RowLayout {
                id: detailActionRow
                anchors.right: parent.right
                spacing: 8

                Button {
                    text: qsTr("保存")
                    implicitWidth: 92
                    implicitHeight: 36
                    onClicked: root.saveClicked()

                    background: Rectangle {
                        radius: 18
                        color: parent.down ? Qt.darker("#2563eb", 1.14) : "#2563eb"
                        border.color: parent.hovered ? Qt.lighter("#2563eb", 1.18) : "transparent"
                        border.width: parent.hovered ? 1 : 0
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        font.pixelSize: Math.max(12, root.detailFontSize - 6)
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    text: qsTr("删除")
                    implicitWidth: 84
                    implicitHeight: 36
                    onClicked: root.deleteClicked()

                    background: Rectangle {
                        radius: 18
                        color: parent.down ? (root.homeDarkMode ? "#2e3949" : "#dde7f3") : (root.homeDarkMode ? "#364152" : "#edf3fb")
                        border.color: parent.hovered ? (root.homeDarkMode ? "#7c8aa0" : "#c7d6ea") : (root.homeDarkMode ? "#4b5563" : "#d8dee8")
                        border.width: 1
                    }

                    contentItem: Text {
                        text: parent.text
                        color: root.homeDarkMode ? "#dbeafe" : "#33527f"
                        font.pixelSize: Math.max(12, root.detailFontSize - 6)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }

    Label {
        visible: root.compactDetailMode
        anchors.centerIn: parent
        text: root.compactTitleText
        font.pixelSize: root.detailFontSize - 2
        color: root.compactTitleColor
    }
}
