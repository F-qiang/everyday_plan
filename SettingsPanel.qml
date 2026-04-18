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
    property string backupDirectory: "./backups"
    property string backupStatusText: ""
    property string currentUserName: ""
    signal logoutRequested()
    signal chooseBackupDirectoryRequested()
    signal backupNowRequested()
    signal restoreBackupRequested()
    signal testNotificationRequested()
    signal displayNameEdited(string value)

    readonly property color pageBackground: homeDarkMode ? "#2f343c" : "#ffffff"
    readonly property color panelBackground: homeDarkMode ? "#3a4049" : "#ffffff"
    readonly property color panelBorder: homeDarkMode ? "#4b5563" : "#d9dee7"
    readonly property color titleColor: homeDarkMode ? "#f3f4f6" : "#1f2937"
    readonly property color subTitleColor: homeDarkMode ? "#cbd5e1" : "#6b7280"
    readonly property color fieldBackground: homeDarkMode ? "#454c56" : "#ffffff"

    function t(zh, en) {
        return uiLanguage === "en" ? en : zh
    }

    function isOneDriveDirectory(path) {
        const source = (path || "").toLowerCase()
        return source.indexOf("onedrive") >= 0
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
                    implicitHeight: accountProfileLayout.implicitHeight + 32
                    radius: 18
                    color: root.panelBackground
                    border.color: root.panelBorder
                    border.width: 1

                    ColumnLayout {
                        id: accountProfileLayout
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 12

                        Label {
                            text: root.t("名称", "Display Name")
                            color: root.titleColor
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Label {
                            Layout.fillWidth: true
                            text: root.t("设置你在左上角账户区和任务作者里显示的名称。", "Set the name shown in the top-left account card and task author label.")
                            color: root.subTitleColor
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                        }

                        TextField {
                            Layout.fillWidth: true
                            implicitHeight: 42
                            placeholderText: root.t("输入你的显示名称", "Enter your display name")
                            text: root.currentUserName
                            selectByMouse: true
                            onEditingFinished: root.displayNameEdited(text)

                            background: Rectangle {
                                radius: 12
                                color: root.fieldBackground
                                border.color: root.panelBorder
                                border.width: 1
                            }

                            color: root.titleColor
                            placeholderTextColor: root.subTitleColor
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
                    implicitHeight: backupLayout.implicitHeight + 32
                    radius: 18
                    color: root.panelBackground
                    border.color: root.panelBorder
                    border.width: 1

                    ColumnLayout {
                        id: backupLayout
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 12

                        Label {
                            text: root.t("备份中心", "Backup Center")
                            color: root.titleColor
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Label {
                            Layout.fillWidth: true
                            text: root.t("先将数据导出到本地备份目录，后续可直接把该目录放进 OneDrive 同步。左侧小按钮可随时主动执行一次备份。", "Export your data to a local backup folder first, then place that folder inside OneDrive for sync later. The small left-side button can trigger a backup anytime.")
                            color: root.subTitleColor
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                        }

                        Label {
                            Layout.fillWidth: true
                            text: root.t("当前备份目录：", "Current backup folder: ") + root.backupDirectory
                            color: root.titleColor
                            font.pixelSize: 13
                            wrapMode: Text.WrapAnywhere
                        }

                        Label {
                            visible: root.backupStatusText !== ""
                            Layout.fillWidth: true
                            text: root.backupStatusText
                            color: root.subTitleColor
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Button {
                                text: root.t("选择备份目录", "Choose Backup Folder")
                                Layout.fillWidth: true
                                implicitHeight: 40
                                onClicked: root.chooseBackupDirectoryRequested()
                            }

                            Button {
                                text: root.t("立即备份", "Back Up Now")
                                Layout.fillWidth: true
                                implicitHeight: 40
                                onClicked: root.backupNowRequested()
                            }
                        }

                        Button {
                            text: root.t("从备份文件恢复", "Restore From Backup File")
                            Layout.fillWidth: true
                            implicitHeight: 40
                            onClicked: root.restoreBackupRequested()
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: oneDriveLayout.implicitHeight + 32
                    radius: 18
                    color: root.panelBackground
                    border.color: root.panelBorder
                    border.width: 1

                    ColumnLayout {
                        id: oneDriveLayout
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 12

                        Label {
                            text: root.t("OneDrive 同步", "OneDrive Sync")
                            color: root.titleColor
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Label {
                            Layout.fillWidth: true
                            text: root.t("这里不再走网页登录和云端 API 上传。只要你的电脑已经安装并登录 OneDrive，本应用会把备份文件直接写入 OneDrive 同步文件夹，后续由 OneDrive 客户端自动上传到云端。", "This app no longer uses browser sign-in or cloud API upload here. If OneDrive is installed and signed in on this computer, backups are written directly into the OneDrive sync folder and then uploaded by the OneDrive desktop client automatically.")
                            color: root.subTitleColor
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                        }

                        Label {
                            Layout.fillWidth: true
                            text: root.isOneDriveDirectory(root.backupDirectory)
                                  ? root.t("当前备份目录已经位于 OneDrive 同步目录中。点击“立即备份”后，文件会自动进入 OneDrive 待同步队列。", "The current backup folder is already inside your OneDrive sync directory. After you click Back Up Now, the file will automatically be picked up by OneDrive for syncing.")
                                  : root.t("当前备份目录还不在 OneDrive 同步目录中。建议把备份目录切换到系统中的 OneDrive 文件夹，例如 OneDrive/EverydayPlanBackup。", "The current backup folder is not inside your OneDrive sync directory yet. It is recommended to switch the backup folder to something like OneDrive/EverydayPlanBackup.")
                            color: root.subTitleColor
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Button {
                                text: root.t("选择 OneDrive 文件夹", "Choose OneDrive Folder")
                                Layout.fillWidth: true
                                implicitHeight: 40
                                onClicked: root.chooseBackupDirectoryRequested()
                            }

                            Button {
                                text: root.t("立即备份到同步目录", "Back Up to Sync Folder")
                                Layout.fillWidth: true
                                implicitHeight: 40
                                onClicked: root.backupNowRequested()
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: notificationLayout.implicitHeight + 32
                    radius: 18
                    color: root.panelBackground
                    border.color: root.panelBorder
                    border.width: 1

                    ColumnLayout {
                        id: notificationLayout
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 12

                        Label {
                            text: root.t("系统通知", "System Notifications")
                            color: root.titleColor
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Label {
                            Layout.fillWidth: true
                            text: root.t("测试 Windows 系统通知是否能正常弹出。后续任务提醒也会使用这一套通知通道。", "Test whether Windows system notifications can appear correctly. Task reminders will use the same notification channel.")
                            color: root.subTitleColor
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                        }

                        Button {
                            text: root.t("测试通知", "Test Notification")
                            Layout.fillWidth: true
                            implicitHeight: 40
                            onClicked: root.testNotificationRequested()
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
