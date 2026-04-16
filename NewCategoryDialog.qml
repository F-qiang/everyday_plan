import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    property bool homeDarkMode: true
    property bool active: false
    property bool editMode: false
    property string categoryName: ""
    property string selectedCategoryColor: "#3b82f6"
    readonly property int shellMargin: 18
    readonly property int shellRadius: 22
    signal createCategoryRequested(string name, string color)
    signal updateCategoryRequested(string name, string color)
    signal deleteCategoryRequested()

    readonly property color bg: homeDarkMode ? "#2f343c" : "#fbf6ec"
    readonly property color card: homeDarkMode ? "#3a4049" : "#fffaf0"
    readonly property color soft: homeDarkMode ? "#454c56" : "#fffdf7"
    readonly property color border: homeDarkMode ? "#4b5563" : "#e6d9bf"
    readonly property color titleC: homeDarkMode ? "#f8fafc" : "#3f3120"
    readonly property color subC: homeDarkMode ? "#d1d5db" : "#8b6b42"
    readonly property color heroA: homeDarkMode ? "#374151" : "#fff0d8"
    readonly property color heroB: homeDarkMode ? "#2f343c" : "#fff9ef"
    readonly property var colors: ["#ef4444", "#f59e0b", "#10b981", "#3b82f6", "#8b5cf6", "#ec4899"]

    function inputBorder(focus) { return focus ? "#60a5fa" : border }
    function resetForm() {
        editMode = false
        categoryNameInput.text = ""
        selectedCategoryColor = colors[3]
    }
    function loadCategory(name, color) {
        editMode = true
        categoryNameInput.text = name || ""
        selectedCategoryColor = color || colors[3]
    }
    function submitCategoryForm() {
        if (categoryNameInput.text.trim() === "") {
            categoryNameInput.forceActiveFocus()
            return
        }
        if (editMode) {
            updateCategoryRequested(categoryNameInput.text.trim(), selectedCategoryColor)
        } else {
            createCategoryRequested(categoryNameInput.text.trim(), selectedCategoryColor)
            categoryNameInput.text = ""
        }
    }

    onActiveChanged: if (active) { motion.restart(); categoryNameInput.forceActiveFocus() }
    onCategoryNameChanged: if (categoryNameInput.text !== categoryName) categoryNameInput.text = categoryName

    component Card: Rectangle {
        radius: 18
        color: root.soft
        border.color: root.border
        border.width: 1
    }

    Rectangle { anchors.fill: parent; color: bg }

    Item {
        id: body
        anchors.fill: parent
        anchors.margins: shellMargin
        opacity: 0
        y: 18

        ParallelAnimation {
            id: motion
            NumberAnimation { target: body; property: "opacity"; from: 0; to: 1; duration: 220; easing.type: Easing.OutCubic }
            NumberAnimation { target: body; property: "y"; from: 18; to: 0; duration: 260; easing.type: Easing.OutCubic }
        }

        Rectangle {
            anchors.fill: parent
            radius: shellRadius
            color: card
            border.color: border
            border.width: 1
            clip: true

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 118
                radius: shellRadius
                color: "transparent"

                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: heroA }
                        GradientStop { position: 0.72; color: heroB }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 22
                spacing: 14

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 92
                    radius: 20
                    color: "transparent"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 4
                        spacing: 8

                        Label { text: root.editMode ? "编辑分类" : "新建分类"; color: titleC; font.pixelSize: 26; font.bold: true }
                        Label { text: root.editMode ? "修改分类名称和颜色，或直接删除当前分类。" : "分类会出现在任务创建页、详情页和分类列表中。"; color: subC; font.pixelSize: 13 }
                    }
                }

                Card {
                    Layout.fillWidth: true
                    implicitHeight: 190

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 10

                        Label { text: "分类名称"; color: titleC; font.pixelSize: 14; font.bold: true }
                        TextField {
                            id: categoryNameInput
                            Layout.fillWidth: true
                            color: titleC
                            implicitHeight: 42
                            background: Rectangle { radius: 12; color: homeDarkMode ? "#2b3138" : "#ffffff"; border.color: root.inputBorder(categoryNameInput.activeFocus); border.width: categoryNameInput.activeFocus ? 2 : 1 }
                        }

                        Label { text: "颜色"; color: titleC; font.pixelSize: 14; font.bold: true }
                        RowLayout {
                            spacing: 10
                            Repeater {
                                model: colors
                                delegate: Rectangle {
                                    width: 28; height: 28; radius: 14; color: modelData
                                    border.color: root.selectedCategoryColor === modelData ? titleC : "transparent"
                                    border.width: 2
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.selectedCategoryColor = modelData }
                                }
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                Card {
                    Layout.fillWidth: true
                    implicitHeight: 74
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 8
                        Label { text: root.editMode ? "保存后会立刻刷新分类列表" : "创建后会立刻刷新分类列表"; color: subC; font.pixelSize: 12 }
                        Item { Layout.fillWidth: true }
                        Button {
                            visible: root.editMode
                            text: "删除"
                            implicitWidth: 88
                            implicitHeight: 40
                            onClicked: root.deleteCategoryRequested()
                        }
                        Button { text: "重置"; implicitWidth: 88; implicitHeight: 40; onClicked: root.editMode ? root.loadCategory(root.categoryName, root.selectedCategoryColor) : resetForm() }
                        Button { text: root.editMode ? "保存修改" : "新建分类"; implicitWidth: 112; implicitHeight: 40; highlighted: true; onClicked: submitCategoryForm() }
                    }
                }
            }
        }
    }
}
