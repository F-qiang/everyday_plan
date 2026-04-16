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
    property bool editingTitle: false
    signal titleEdited(string value)
    signal titleEditFinished()
    signal deleteClicked()

    function beginTitleEdit() {
        if (root.compactDetailMode || !root.showActions) {
            return
        }
        root.editingTitle = true
        Qt.callLater(function() {
            titleInput.forceActiveFocus()
            titleInput.selectAll()
        })
    }

    function finishTitleEdit() {
        if (!root.editingTitle) {
            return
        }
        root.editingTitle = false
        root.titleEditFinished()
    }

    implicitHeight: root.showActions ? Math.max(40, detailActionRow.implicitHeight) : 34

    RowLayout {
        anchors.fill: parent
        spacing: 8

        Item {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            implicitHeight: Math.max(40, titleLabel.implicitHeight)
            visible: !root.compactDetailMode

            Label {
                id: titleLabel
                anchors.fill: parent
                visible: !root.editingTitle
                verticalAlignment: Text.AlignVCenter
                text: root.titleText
                font.pixelSize: root.showActions ? root.detailFontSize : Math.max(18, root.detailFontSize - 1)
                font.bold: true
                color: root.detailTextColor
                elide: Text.ElideRight
            }

            TextField {
                id: titleInput
                anchors.fill: parent
                visible: root.editingTitle
                text: root.titleText
                font.pixelSize: root.showActions ? root.detailFontSize : Math.max(18, root.detailFontSize - 1)
                font.bold: true
                color: root.detailTextColor
                selectByMouse: true
                selectedTextColor: root.homeDarkMode ? "#0f172a" : "#ffffff"
                selectionColor: root.homeDarkMode ? "#bfdbfe" : "#2563eb"
                background: Rectangle {
                    radius: 8
                    color: root.homeDarkMode ? "#ffffff" : "#ffffff"
                    border.color: root.homeDarkMode ? "#93c5fd" : "#2563eb"
                    border.width: 2
                }
                onTextChanged: root.titleEdited(text)
                onEditingFinished: root.finishTitleEdit()
            }

            MouseArea {
                anchors.fill: parent
                enabled: !root.editingTitle && root.showActions
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.beginTitleEdit()
            }
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
