import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    property bool homeDarkMode: true
    property var categories: []
    property string titleText: "分类列表"
    property int selectedCategoryId: -1
    signal categorySelected(int categoryId, string categoryName)
    signal createCategoryRequested()

    readonly property color pageBackground: "transparent"
    readonly property color cardBackground: homeDarkMode ? "#3a4049" : "#ffffff"
    readonly property color cardBorder: homeDarkMode ? "#4b5563" : "#d9dee7"
    readonly property color titleColor: homeDarkMode ? "#f3f4f6" : "#1f2937"
    readonly property color subTitleColor: homeDarkMode ? "#cbd5e1" : "#6b7280"

    Rectangle {
        anchors.fill: parent
        color: root.pageBackground
    }

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: root.cardBackground
        border.color: root.cardBorder
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 10

            Button {
                Layout.fillWidth: true
                implicitHeight: 36
                text: qsTr("新建分类")
                onClicked: root.createCategoryRequested()

                background: Rectangle {
                    radius: 12
                    color: parent.down ? "#dbeafe" : "#eff6ff"
                    border.color: parent.down ? "#60a5fa" : "#93c5fd"
                    border.width: 1
                }

                contentItem: Text {
                    text: parent.text
                    color: "#2563eb"
                    font.pixelSize: 13
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ListView {
                    id: categoryListView
                    width: parent.width
                    model: root.categories
                    spacing: 6
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Rectangle {
                        width: categoryListView.width
                        height: 52
                        radius: 10
                        color: root.selectedCategoryId === (modelData.categoryId || 0)
                               ? (root.homeDarkMode ? "#4b5563" : "#eef4ff")
                               : (root.homeDarkMode ? "#454c56" : "#ffffff")
                        border.color: root.selectedCategoryId === (modelData.categoryId || 0)
                                      ? "#60a5fa"
                                      : root.cardBorder
                        border.width: root.selectedCategoryId === (modelData.categoryId || 0) ? 2 : 1

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.categorySelected(modelData.categoryId || 0, modelData.name || "未命名分类")
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8

                            Rectangle {
                                width: 10
                                height: 10
                                radius: 5
                                color: modelData.color || "#94a3b8"
                            }

                            Label {
                                Layout.fillWidth: true
                                text: modelData.name || "未命名分类"
                                color: root.titleColor
                                font.pixelSize: 13
                                font.bold: true
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }

        Label {
            anchors.centerIn: parent
            visible: root.categories.length === 0
            text: "暂无分类"
            horizontalAlignment: Text.AlignHCenter
            color: root.subTitleColor
            font.pixelSize: 12
        }
    }
}
