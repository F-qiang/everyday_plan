import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    property bool homeDarkMode: true
    property string uiLanguage: "zh"
    property string backgroundImageSource: ""
    property int navFontSize: 18
    property int middleCardFontSize: 15
    property int detailFontSize: 20
    property string timeDisplayFormat: "ymd24"
    property bool showDetailAuthor: true
    property bool showDetailCreatedDate: true
    property bool showDetailStartDate: true
    property bool showDetailDueDate: true
    property bool showDetailPriority: true
    property bool ganttBlueTheme: true
    signal logoutRequested()

    readonly property color pageBackground: homeDarkMode ? "#2f343c" : "#ffffff"
    readonly property color panelBackground: homeDarkMode ? "#3a4049" : "#ffffff"
    readonly property color panelBorder: homeDarkMode ? "#4b5563" : "#d9dee7"
    readonly property color titleColor: homeDarkMode ? "#f3f4f6" : "#1f2937"
    readonly property color subTitleColor: homeDarkMode ? "#cbd5e1" : "#6b7280"
    readonly property color fieldBackground: homeDarkMode ? "#454c56" : "#ffffff"

    function t(zh, en) {
        return uiLanguage === "en" ? en : zh
    }

    Rectangle {
        anchors.fill: parent
        color: root.pageBackground
    }

    ScrollView {
        anchors.fill: parent
        clip: true

        Rectangle {
            width: root.width
            implicitHeight: contentColumn.implicitHeight + 40
            color: "transparent"

            ColumnLayout {
                id: contentColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 20
                spacing: 18

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: headerLayout.implicitHeight + 32
                    radius: 20
                    color: root.panelBackground
                    border.color: root.panelBorder
                    border.width: 1

                    ColumnLayout {
                        id: headerLayout
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 8

                        Label {
                            text: root.t("界面设置", "Interface Settings")
                            color: root.titleColor
                            font.pixelSize: 24
                            font.bold: true
                        }

                        Label {
                            Layout.fillWidth: true
                            text: root.t("统一调整主题、背景图、字号和详情页展示内容，让整个任务界面保持整洁一致。", "Adjust theme, background, font sizes, and detail visibility in one place for a consistent task workspace.")
                            color: root.subTitleColor
                            font.pixelSize: 13
                            wrapMode: Text.WordWrap
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: languageLayout.implicitHeight + 32
                    radius: 18
                    color: root.panelBackground
                    border.color: root.panelBorder
                    border.width: 1

                    ColumnLayout {
                        id: languageLayout
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 12

                        Label {
                            text: root.t("界面语言", "Interface Language")
                            color: root.titleColor
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Label {
                            Layout.fillWidth: true
                            text: root.t("切换整个应用的主要界面文案，目前支持中文和英文。", "Switch the main interface text across the app. Chinese and English are currently supported.")
                            color: root.subTitleColor
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                        }

                        ComboBox {
                            Layout.fillWidth: true
                            implicitHeight: 42
                            model: ["中文", "English"]
                            currentIndex: root.uiLanguage === "en" ? 1 : 0
                            onActivated: root.uiLanguage = currentIndex === 1 ? "en" : "zh"
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: backgroundLayout.implicitHeight + 32
                    radius: 18
                    color: root.panelBackground
                    border.color: root.panelBorder
                    border.width: 1

                    ColumnLayout {
                        id: backgroundLayout
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 12

                        Label {
                            text: root.t("背景图", "Background Image")
                            color: root.titleColor
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Label {
                            Layout.fillWidth: true
                            text: root.t("输入本地图片路径，例如 C:/pics/bg.jpg。", "Enter a local image path, for example C:/pics/bg.jpg.")
                            color: root.subTitleColor
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                        }

                        TextField {
                            id: backgroundInput
                            Layout.fillWidth: true
                            placeholderText: root.t("输入图片路径，例如 C:/pics/bg.jpg", "Enter an image path, for example C:/pics/bg.jpg")
                            text: root.backgroundImageSource
                            selectByMouse: true
                            implicitHeight: 42

                            background: Rectangle {
                                radius: 12
                                color: root.fieldBackground
                                border.color: root.panelBorder
                                border.width: 1
                            }

                            color: root.titleColor
                            placeholderTextColor: root.subTitleColor
                            onEditingFinished: root.backgroundImageSource = text
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Button {
                                text: "应用路径"
                                Layout.fillWidth: true
                                implicitHeight: 40
                                onClicked: root.backgroundImageSource = backgroundInput.text
                            }

                            Button {
                                text: "清除背景图"
                                Layout.fillWidth: true
                                implicitHeight: 40
                                onClicked: {
                                    root.backgroundImageSource = ""
                                    backgroundInput.text = ""
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: timeFormatLayout.implicitHeight + 32
                    radius: 18
                    color: root.panelBackground
                    border.color: root.panelBorder
                    border.width: 1

                    ColumnLayout {
                        id: timeFormatLayout
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 12

                        Label {
                            text: "时间显示格式"
                            color: root.titleColor
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Label {
                            Layout.fillWidth: true
                            text: "用下拉框切换任务时间、创建日期、开始日期和结束日期的显示样式。"
                            color: root.subTitleColor
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                        }

                        ComboBox {
                            Layout.fillWidth: true
                            implicitHeight: 42
                            model: [
                                "2026-04-13 18:30",
                                "04-13 18:30",
                                "2026年04月13日 18:30",
                                "2026-04-13 下午 06:30",
                                "2026-04-13 18:30:00"
                            ]
                            currentIndex: {
                                switch (root.timeDisplayFormat) {
                                case "md24": return 1
                                case "cn24": return 2
                                case "ymd12": return 3
                                case "full": return 4
                                case "ymd24":
                                default: return 0
                                }
                            }
                            onActivated: {
                                switch (currentIndex) {
                                case 1:
                                    root.timeDisplayFormat = "md24"
                                    break
                                case 2:
                                    root.timeDisplayFormat = "cn24"
                                    break
                                case 3:
                                    root.timeDisplayFormat = "ymd12"
                                    break
                                case 4:
                                    root.timeDisplayFormat = "full"
                                    break
                                case 0:
                                default:
                                    root.timeDisplayFormat = "ymd24"
                                    break
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: detailLayout.implicitHeight + 32
                    radius: 18
                    color: root.panelBackground
                    border.color: root.panelBorder
                    border.width: 1

                    ColumnLayout {
                        id: detailLayout
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 10

                        Label {
                            text: "详情显示"
                            color: root.titleColor
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Label {
                            Layout.fillWidth: true
                            text: "选择任务详情页中需要展示的附加信息。"
                            color: root.subTitleColor
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                        }

                        Switch {
                            text: "显示作者"
                            checked: root.showDetailAuthor
                            onToggled: root.showDetailAuthor = checked
                        }

                        Switch {
                            text: "显示创建日期"
                            checked: root.showDetailCreatedDate
                            onToggled: root.showDetailCreatedDate = checked
                        }

                        Switch {
                            text: "显示开始日期"
                            checked: root.showDetailStartDate
                            onToggled: root.showDetailStartDate = checked
                        }

                        Switch {
                            text: "显示截至日期"
                            checked: root.showDetailDueDate
                            onToggled: root.showDetailDueDate = checked
                        }

                        Switch {
                            text: "显示优先级并允许修改"
                            checked: root.showDetailPriority
                            onToggled: root.showDetailPriority = checked
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: ganttThemeLayout.implicitHeight + 32
                    radius: 18
                    color: root.panelBackground
                    border.color: root.panelBorder
                    border.width: 1

                    ColumnLayout {
                        id: ganttThemeLayout
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 10

                        Label {
                            text: "甘特图主题"
                            color: root.titleColor
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Label {
                            Layout.fillWidth: true
                            text: "控制甘特任务条、今日高亮列和网格线是否统一使用浅蓝主题。"
                            color: root.subTitleColor
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                        }

                        Switch {
                            text: "使用浅蓝主题"
                            checked: root.ganttBlueTheme
                            onToggled: root.ganttBlueTheme = checked
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: fontLayout.implicitHeight + 32
                    radius: 18
                    color: root.panelBackground
                    border.color: root.panelBorder
                    border.width: 1

                    ColumnLayout {
                        id: fontLayout
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 14

                        Label { text: "字体大小"; color: root.titleColor; font.pixelSize: 18; font.bold: true }
                        Label { text: "导航字体：" + root.navFontSize; color: root.titleColor; font.pixelSize: 13 }
                        Slider { Layout.fillWidth: true; from: 14; to: 24; value: root.navFontSize; stepSize: 1; onMoved: root.navFontSize = Math.round(value) }
                        Label { text: "中部卡片字体：" + root.middleCardFontSize; color: root.titleColor; font.pixelSize: 13 }
                        Slider { Layout.fillWidth: true; from: 12; to: 22; value: root.middleCardFontSize; stepSize: 1; onMoved: root.middleCardFontSize = Math.round(value) }
                        Label { text: "详情字体：" + root.detailFontSize; color: root.titleColor; font.pixelSize: 13 }
                        Slider { Layout.fillWidth: true; from: 16; to: 30; value: root.detailFontSize; stepSize: 1; onMoved: root.detailFontSize = Math.round(value) }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: accountLayout.implicitHeight + 32
                    radius: 18
                    color: root.panelBackground
                    border.color: root.panelBorder
                    border.width: 1

                    ColumnLayout {
                        id: accountLayout
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 12

                        Label {
                            text: "账户"
                            color: root.titleColor
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Label {
                            Layout.fillWidth: true
                            text: "退出当前账户并返回登录状态。"
                            color: root.subTitleColor
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                        }

                        Button {
                            text: "退出账户"
                            implicitHeight: 42
                            onClicked: root.logoutRequested()
                        }
                    }
                }
            }
        }
    }
}
