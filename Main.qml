// 主窗口 - 整合登录和甘特图功能
import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.15
import QtQuick.Dialogs

import AuthManager 1.0
import GanttModel 1.0
import AbstractContentsModel 1.0
import DatabaseManager 1.0

Window {
    id: mainWindow
    visible: true
    color: "#000000"
     property int self_height: Screen.height
    property int self_width: Screen.width
    property string databasePath: "./data.db"
    property bool sidebarBackupJustCompleted: false

    function formatDisplayDateTime(value) {
        const source = (value || "").trim()
        if (source === "") {
            return ""
        }

        const normalized = source.replace(" ", "T")
        let date = new Date(normalized)
        if (isNaN(date.getTime())) {
            date = new Date(source)
        }
        if (isNaN(date.getTime())) {
            return source
        }

        switch (timeDisplayFormat) {
        case "md24":
            return Qt.formatDateTime(date, "MM-dd HH:mm")
        case "cn24":
            return Qt.formatDateTime(date, "yyyy年MM月dd日 HH:mm")
        case "ymd12":
            return Qt.formatDateTime(date, "yyyy-MM-dd ap hh:mm")
        case "full":
            return Qt.formatDateTime(date, "yyyy-MM-dd HH:mm:ss")
        case "ymd24":
        default:
            return Qt.formatDateTime(date, "yyyy-MM-dd HH:mm")
        }
    }

    function contentIsImage(value) {
        if (!value || value === "") {
            return false
        }
        return value.startsWith("file:/") || value.startsWith("qrc:/") || value.startsWith("http://") || value.startsWith("https://") || /\.(png|jpg|jpeg|bmp|gif|webp|svg)$/i.test(value)
    }

    function contentIsFile(value) {
        if (!value || value === "") {
            return false
        }
        return !contentIsImage(value) && (value.startsWith("file:/") || /^[a-zA-Z]:[\\/]/.test(value) || /^\\\\/.test(value) || /\.[a-zA-Z0-9]{1,8}$/.test(value))
    }

    function textContentSections(value) {
        const source = (value || "").trim()
        if (source === "") {
            return []
        }
        return source.split(/\n{2,}|(?:\r\n){2,}/).map(function(part) {
            return part.trim()
        }).filter(function(part) {
            return part !== ""
        })
    }

    function normalizeSelectedFile(selectedFile) {
        const source = (selectedFile || "").toString()
        if (source === "") {
            return ""
        }
        if (source.startsWith("file:///")) {
            const localPath = decodeURIComponent(source.substring(8))
            return Qt.platform.os === "windows" ? localPath.replace(/\//g, "\\") : "/" + localPath
        }
        if (source.startsWith("file://")) {
            return decodeURIComponent(source.substring(7))
        }
        return decodeURIComponent(source)
    }

    function selectedFileName(path) {
        const source = (path || "").trim()
        if (source === "") {
            return "未选择附件"
        }
        const parts = source.split(/[\\/]/)
        return parts.length > 0 ? parts[parts.length - 1] : source
    }

    function isOneDriveSyncPath(path) {
        const source = (path || "").toLowerCase()
        return source.indexOf("onedrive") >= 0
    }

    function attachmentPathsFromContent(value) {
        const source = ((value || "") + "").replace(/\r/g, "")
        const matches = source.match(/^\s*(\[\[attachment:.+\]\]\s*)+/)
        if (!matches) {
            const trimmed = source.trim()
            return contentIsFile(trimmed) ? [trimmed] : []
        }

        const attachmentLines = matches[0].match(/\[\[attachment:(.+?)\]\]/g) || []
        const paths = []
        for (let i = 0; i < attachmentLines.length; ++i) {
            const lineMatch = attachmentLines[i].match(/^\[\[attachment:(.+)\]\]$/)
            if (lineMatch && (lineMatch[1] || "").trim() !== "") {
                paths.push((lineMatch[1] || "").trim())
            }
        }
        return paths
    }

    function attachmentPathFromContent(value) {
        const paths = attachmentPathsFromContent(value)
        return paths.length > 0 ? paths[0] : ""
    }

    function bodyTextFromContent(value) {
        const source = ((value || "") + "").replace(/\r/g, "")
        const trimmed = source.trim()
        if (trimmed === "") {
            return ""
        }

        const matches = source.match(/^\s*(\[\[attachment:.+\]\]\s*)+/)
        if (matches) {
            return source.slice(matches[0].length).replace(/^\n+/, "")
        }
        return contentIsFile(trimmed) ? "" : source
    }

    function composeContentWithAttachments(bodyText, attachmentPaths) {
        const body = ((bodyText || "") + "").replace(/\r/g, "").replace(/[ \t\n]+$/, "")
        const paths = attachmentPaths || []
        const normalizedPaths = []
        for (let i = 0; i < paths.length; ++i) {
            const path = ((paths[i] || "") + "").trim()
            if (path !== "") {
                normalizedPaths.push(path)
            }
        }
        if (normalizedPaths.length === 0) {
            return body
        }
        const attachmentBlock = normalizedPaths.map(function(path) {
            return "[[attachment:" + path + "]]"
        }).join("\n")
        return body === "" ? attachmentBlock : attachmentBlock + "\n\n" + body
    }

    function appendAttachmentToContent(value, attachmentPath) {
        const path = ((attachmentPath || "") + "").trim()
        if (path === "") {
            return value
        }
        const paths = attachmentPathsFromContent(value)
        paths.push(path)
        return composeContentWithAttachments(bodyTextFromContent(value), paths)
    }

    function removeAttachmentFromContent(value, attachmentPath) {
        const path = ((attachmentPath || "") + "").trim()
        const paths = attachmentPathsFromContent(value).filter(function(item) {
            return item !== path
        })
        return composeContentWithAttachments(bodyTextFromContent(value), paths)
    }

    function replaceAttachmentInContent(value, oldPath, newPath) {
        const oldTarget = ((oldPath || "") + "").trim()
        const newTarget = ((newPath || "") + "").trim()
        if (oldTarget === "") {
            return appendAttachmentToContent(value, newTarget)
        }
        const paths = attachmentPathsFromContent(value)
        const nextPaths = []
        let replaced = false
        for (let i = 0; i < paths.length; ++i) {
            if (!replaced && paths[i] === oldTarget) {
                if (newTarget !== "") {
                    nextPaths.push(newTarget)
                }
                replaced = true
            } else {
                nextPaths.push(paths[i])
            }
        }
        if (!replaced && newTarget !== "") {
            nextPaths.push(newTarget)
        }
        return composeContentWithAttachments(bodyTextFromContent(value), nextPaths)
    }

    function openLocalFile(path) {
        const source = (path || "").trim()
        if (source === "") {
            return
        }
        let fileUrl = source
        if (!source.startsWith("file://")) {
            if (Qt.platform.os === "windows") {
                fileUrl = "file:///" + source.replace(/\\/g, "/")
            } else if (source.startsWith("/")) {
                fileUrl = "file://" + source
            } else {
                fileUrl = "file:///" + source
            }
        }
        Qt.openUrlExternally(encodeURI(fileUrl))
    }

    function dateTimeParts(value) {
        const source = (value || "").trim()
        let date = source === "" ? new Date() : new Date(source.replace(" ", "T"))
        if (isNaN(date.getTime())) {
            date = new Date()
        }
        return {
            year: date.getFullYear(),
            month: date.getMonth() + 1,
            day: date.getDate(),
            hour: date.getHours(),
            minute: date.getMinutes()
        }
    }

    function openDateTimeEditor(fieldKey) {
        detailDateTimeField = fieldKey
        const parts = dateTimeParts(fieldKey === "start" ? editTaskStartDate : editTaskDueDate)
        detailDateYear.value = parts.year
        detailDateMonth.value = parts.month
        detailDateDay.value = parts.day
        detailDateHour.value = parts.hour
        detailDateMinute.value = parts.minute
        detailDatePopup.open()
    }

    function applyDetailDateTime() {
        const value = detailDateYear.value.toString().padStart(4, "0") + "-"
                    + detailDateMonth.value.toString().padStart(2, "0") + "-"
                    + detailDateDay.value.toString().padStart(2, "0") + " "
                    + detailDateHour.value.toString().padStart(2, "0") + ":"
                    + detailDateMinute.value.toString().padStart(2, "0")
        if (detailDateTimeField === "start") {
            editTaskStartDate = value
        } else if (detailDateTimeField === "due") {
            editTaskDueDate = value
        }
    }

    function t(zh, en) {
        return uiLanguage === "en" ? en : zh
    }

    readonly property int pageToday: 0
    readonly property int pageAllTasks: 1
    readonly property int pageCompleted: 2
    readonly property int pageGantt: 3

    property int currentPageType: pageToday
    property bool settingsVisible: false
    property bool middleCollapsed: false
    property bool detailVisible: false
    property bool newTaskVisible: false
    property bool newCategoryVisible: false
    property var categoryList: []
    property int activeCategoryId: -1
    property string activeCategoryName: ""
    property int editingCategoryId: -1
    property string editingCategoryName: ""
    property string editingCategoryColor: "#3b82f6"
    property int selectedTaskId: -1
    property int selectedTaskCategoryId: 0
    property string selectedTaskCategoryName: "未分类"
    property string selectedTaskCategoryColor: "#94a3b8"
    property int selectedDetailCategoryIndex: 0
    property bool categorySyncing: false
    property string selectedTaskTitle: ""
    property string selectedTaskOutline: ""
    property string selectedTaskContent: ""
    property bool selectedTaskCompleted: false
    property string selectedTaskTime: ""
    property string selectedTaskStartDate: ""
    property string selectedTaskAuthor: ""
    property string selectedTaskCreatedAt: ""
    property string selectedTaskDueDate: ""
    property int selectedTaskPriority: 1
    property string editTaskTitle: ""
    property string editTaskOutline: ""
    property string editTaskContent: ""
    property string editTaskStartDate: ""
    property string editTaskDueDate: ""
    property int editTaskPriority: 1
    property int editTaskCategoryIndex: 0
    property bool editTaskCompleted: false
    property string pendingAttachmentReplacePath: ""
    property var defaultUserSettings: DatabaseManager.defaultUserSettings()
    property bool showDetailAuthor: defaultUserSettings.showDetailAuthor
    property bool showDetailCreatedDate: defaultUserSettings.showDetailCreatedDate
    property bool showDetailStartDate: defaultUserSettings.showDetailStartDate
    property bool showDetailDueDate: defaultUserSettings.showDetailDueDate
    property bool showDetailPriority: defaultUserSettings.showDetailPriority
    property bool ganttBlueTaskBars: defaultUserSettings.ganttBlueTaskBars
    property bool ganttBlueTodayColumn: defaultUserSettings.ganttBlueTodayColumn
    property bool ganttBlueGridLines: defaultUserSettings.ganttBlueGridLines
    property bool ganttBlueTheme: ganttBlueTaskBars && ganttBlueTodayColumn && ganttBlueGridLines
    property bool homeDarkMode: false
    property string backupDirectory: defaultUserSettings.backupDirectory
    property string backupStatusText: ""
    property string latestBackupPath: ""
    property string backgroundImageSource: defaultUserSettings.backgroundImageSource
    property int navFontSize: defaultUserSettings.navFontSize
    property int middleCardFontSize: defaultUserSettings.middleCardFontSize
    property int detailFontSize: defaultUserSettings.detailFontSize
    property string uiLanguage: defaultUserSettings.uiLanguage
    property string timeDisplayFormat: defaultUserSettings.timeDisplayFormat
    readonly property color pageBaseColor: homeDarkMode ? "#2f343c" : "#ffffff"
    readonly property color detailSurfaceColor: homeDarkMode ? "#323841" : "#f8fafc"
    readonly property color detailElevatedColor: homeDarkMode ? "#3b4350" : "#ffffff"
    readonly property color detailBorderColor: homeDarkMode ? "#4b5563" : "#d8dee8"
    readonly property color detailTextColor: homeDarkMode ? "#f8fafc" : "#0f172a"
    readonly property color detailMutedTextColor: homeDarkMode ? "#d1d5db" : "#475569"
    readonly property color detailHintTextColor: homeDarkMode ? "#9ca3af" : "#64748b"
    readonly property color detailAccentColor: homeDarkMode ? "#93c5fd" : "#2563eb"
    readonly property color detailOnAccentColor: "#ffffff"
    readonly property color detailTonalColor: homeDarkMode ? "#334155" : "#e8f0fe"

    onBackgroundImageSourceChanged: persistUserSettings()
    onNavFontSizeChanged: persistUserSettings()
    onMiddleCardFontSizeChanged: persistUserSettings()
    onDetailFontSizeChanged: persistUserSettings()
    onUiLanguageChanged: persistUserSettings()
    onTimeDisplayFormatChanged: persistUserSettings()
    onShowDetailAuthorChanged: persistUserSettings()
    onShowDetailCreatedDateChanged: persistUserSettings()
    onShowDetailStartDateChanged: persistUserSettings()
    onShowDetailDueDateChanged: persistUserSettings()
    onShowDetailPriorityChanged: persistUserSettings()
    onGanttBlueTaskBarsChanged: persistUserSettings()
    onGanttBlueTodayColumnChanged: persistUserSettings()
    onGanttBlueGridLinesChanged: persistUserSettings()
    onGanttBlueThemeChanged: {
        if (ganttBlueTaskBars !== ganttBlueTheme) ganttBlueTaskBars = ganttBlueTheme
        if (ganttBlueTodayColumn !== ganttBlueTheme) ganttBlueTodayColumn = ganttBlueTheme
        if (ganttBlueGridLines !== ganttBlueTheme) ganttBlueGridLines = ganttBlueTheme
    }
    onBackupDirectoryChanged: persistUserSettings()

    width: self_width * 0.6
    height: self_height * 0.6
    title: qsTr("Everyday Plan")

    component DetailEditorField: TextField {
        implicitHeight: 40
        color: detailTextColor
        selectByMouse: true
        selectedTextColor: detailOnAccentColor
        selectionColor: detailAccentColor
        placeholderTextColor: detailHintTextColor
        background: Rectangle {
            radius: 8
            color: detailElevatedColor
            border.color: parent.activeFocus ? detailAccentColor : detailBorderColor
            border.width: parent.activeFocus ? 2 : 1
        }
    }

    component DetailActionButton: Button {
        implicitHeight: 36
        implicitWidth: 76

        background: Rectangle {
            radius: 18
            color: homeDarkMode
                   ? (parent.down ? Qt.darker(detailTonalColor, 1.12) : "#364152")
                   : (parent.down ? "#f8fafc" : "#ffffff")
            border.color: homeDarkMode
                          ? (parent.hovered ? "#7c8aa0" : detailBorderColor)
                          : (parent.hovered ? "#93c5fd" : "#d8dee8")
            border.width: 1
        }

        contentItem: Text {
            text: parent.text
            color: homeDarkMode ? "#dbeafe" : "#1d4ed8"
            font.pixelSize: Math.max(12, detailFontSize - 6)
            font.bold: false
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    component DetailPrimaryButton: Button {
        implicitHeight: 36
        implicitWidth: 82

        background: Rectangle {
            radius: 18
            color: parent.down ? Qt.darker(detailAccentColor, 1.14) : detailAccentColor
            border.color: parent.hovered ? Qt.lighter(detailAccentColor, 1.18) : "transparent"
            border.width: parent.hovered ? 1 : 0
        }

        contentItem: Text {
            text: parent.text
            color: detailOnAccentColor
            font.pixelSize: Math.max(12, detailFontSize - 6)
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    component DetailCard: Rectangle {
        radius: 12
        color: detailElevatedColor
        border.color: detailBorderColor
        border.width: 1
    }

    component DetailComboBox: ComboBox {
        implicitHeight: 40
        implicitWidth: 156

        delegate: ItemDelegate {
            width: parent.width
            highlighted: parent.highlightedIndex === index

            contentItem: Text {
                text: modelData
                color: detailTextColor
                font.pixelSize: Math.max(12, detailFontSize - 6)
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                color: parent.highlighted ? detailTonalColor : detailElevatedColor
            }
        }

        contentItem: Text {
            leftPadding: 12
            rightPadding: 32
            text: parent.displayText
            color: detailTextColor
            font.pixelSize: Math.max(12, detailFontSize - 6)
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        indicator: Canvas {
            x: parent.width - width - 12
            y: (parent.height - height) / 2
            width: 12
            height: 8
            contextType: "2d"

            onPaint: {
                context.reset()
                context.moveTo(0, 0)
                context.lineTo(width, 0)
                context.lineTo(width / 2, height)
                context.closePath()
                context.fillStyle = detailHintTextColor
                context.fill()
            }
        }

        background: Rectangle {
            radius: 8
            color: detailElevatedColor
            border.color: parent.visualFocus ? detailAccentColor : detailBorderColor
            border.width: parent.visualFocus ? 2 : 1
        }

        popup: Popup {
            y: parent.height + 6
            width: parent.width
            padding: 0

            background: Rectangle {
                radius: 10
                color: detailElevatedColor
                border.color: detailBorderColor
                border.width: 1
            }

            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight
                model: parent.parent.delegateModel
                currentIndex: parent.parent.highlightedIndex
            }
        }
    }

    function pageTitleText() {
        if (settingsVisible) return t("设置", "Settings")
        if (newTaskVisible) return t("新建任务", "New Task")
        if (newCategoryVisible) return t("新建分类", "New Category")
        if (activeCategoryId >= 0) return activeCategoryName === "" ? t("分类任务", "Category Tasks") : activeCategoryName + (uiLanguage === "en" ? " · Category" : " · 分类目录")
        if (currentPageType === pageToday) return t("今日任务", "Today")
        if (currentPageType === pageCompleted) return t("已完成", "Completed")
        return t("全部任务", "All Tasks")
    }

    function openLoginWindow() {
        if (loginLoader.active) {
            return
        }
        loginLoader.active = true
    }

    function ensureListPageForEditor() {
        if (currentPageType === pageGantt) {
            currentPageType = pageToday
            AbstractContentsModel.loadAllFromDatabase(databasePath, true, false)
        }
    }

    function clearCategoryFilter() {
        activeCategoryId = -1
        activeCategoryName = ""
    }

    function resetDetail() {
        detailVisible = false
        newTaskVisible = false
        newCategoryVisible = false
        selectedTaskId = -1
        selectedTaskTitle = ""
        selectedTaskOutline = ""
        selectedTaskContent = ""
        selectedTaskCompleted = false
        selectedTaskTime = ""
        selectedTaskStartDate = ""
        selectedTaskAuthor = ""
        selectedTaskCreatedAt = ""
        selectedTaskDueDate = ""
        selectedTaskPriority = 1
        selectedTaskCategoryId = 0
        selectedTaskCategoryName = "未分类"
        selectedTaskCategoryColor = "#94a3b8"
        selectedDetailCategoryIndex = 0
    }

    function loadCategories() {
        if (!AuthManager.isLoggedIn) {
            categoryList = []
            return
        }
        categoryList = DatabaseManager.getCategoriesByUser(AuthManager.currentUserId)
    }

    function collectUserSettings() {
        return {
            "homeDarkMode": homeDarkMode,
            "backgroundImageSource": backgroundImageSource,
            "navFontSize": navFontSize,
            "middleCardFontSize": middleCardFontSize,
            "detailFontSize": detailFontSize,
            "uiLanguage": uiLanguage,
            "timeDisplayFormat": timeDisplayFormat,
            "showDetailAuthor": showDetailAuthor,
            "showDetailCreatedDate": showDetailCreatedDate,
            "showDetailStartDate": showDetailStartDate,
            "showDetailDueDate": showDetailDueDate,
            "showDetailPriority": showDetailPriority,
            "ganttBlueTaskBars": ganttBlueTaskBars,
            "ganttBlueTodayColumn": ganttBlueTodayColumn,
            "ganttBlueGridLines": ganttBlueGridLines,
            "backupDirectory": backupDirectory
        }
    }

    function applyUserSettings(settings) {
        if (!settings) {
            return
        }

        if (settings.hasOwnProperty("homeDarkMode")) homeDarkMode = settings.homeDarkMode
        if (settings.hasOwnProperty("backgroundImageSource")) backgroundImageSource = settings.backgroundImageSource || ""
        if (settings.hasOwnProperty("navFontSize")) navFontSize = settings.navFontSize
        if (settings.hasOwnProperty("middleCardFontSize")) middleCardFontSize = settings.middleCardFontSize
        if (settings.hasOwnProperty("detailFontSize")) detailFontSize = settings.detailFontSize
        if (settings.hasOwnProperty("uiLanguage")) uiLanguage = settings.uiLanguage || "zh"
        if (settings.hasOwnProperty("timeDisplayFormat")) timeDisplayFormat = settings.timeDisplayFormat || "ymd24"
        if (settings.hasOwnProperty("showDetailAuthor")) showDetailAuthor = settings.showDetailAuthor
        if (settings.hasOwnProperty("showDetailCreatedDate")) showDetailCreatedDate = settings.showDetailCreatedDate
        if (settings.hasOwnProperty("showDetailStartDate")) showDetailStartDate = settings.showDetailStartDate
        if (settings.hasOwnProperty("showDetailDueDate")) showDetailDueDate = settings.showDetailDueDate
        if (settings.hasOwnProperty("showDetailPriority")) showDetailPriority = settings.showDetailPriority
        if (settings.hasOwnProperty("ganttBlueTaskBars")) ganttBlueTaskBars = settings.ganttBlueTaskBars
        if (settings.hasOwnProperty("ganttBlueTodayColumn")) ganttBlueTodayColumn = settings.ganttBlueTodayColumn
        if (settings.hasOwnProperty("ganttBlueGridLines")) ganttBlueGridLines = settings.ganttBlueGridLines
        if (settings.hasOwnProperty("backupDirectory")) backupDirectory = settings.backupDirectory || "./backups"
    }

    function loadUserSettings() {
        if (!AuthManager.isLoggedIn) {
            applyUserSettings(defaultUserSettings)
            return
        }
        applyUserSettings(DatabaseManager.getUserSettings(AuthManager.currentUserId))
        if (!backupDirectory || backupDirectory === "" || backupDirectory === "./backups") {
            backupDirectory = DatabaseManager.suggestedBackupDirectory()
        }
    }

    function persistUserSettings() {
        if (!AuthManager.isLoggedIn) {
            return
        }
        DatabaseManager.saveUserSettings(AuthManager.currentUserId, collectUserSettings())
    }

    function runBackupExport() {
        const accountLabel = AuthManager.currentUserNickname && AuthManager.currentUserNickname !== ""
                           ? AuthManager.currentUserNickname
                           : AuthManager.currentUserEmail
        const exportedPath = DatabaseManager.exportBackup(backupDirectory, accountLabel)
        if (exportedPath === "") {
            sidebarBackupJustCompleted = false
            backupStatusText = t("备份失败，请检查备份目录。", "Backup failed. Please check the backup folder.")
            return
        }
        latestBackupPath = exportedPath
        sidebarBackupJustCompleted = true
        sidebarBackupResetTimer.restart()
        backupStatusText = isOneDriveSyncPath(exportedPath)
                ? t("备份已写入 OneDrive 同步目录，等待 OneDrive 客户端自动上传：", "Backup saved into the OneDrive sync folder. Waiting for the OneDrive desktop client to upload: ") + exportedPath
                : t("备份成功：", "Backup created: ") + exportedPath
    }

    function restoreBackupFromFile(selectedFile) {
        const backupFilePath = normalizeSelectedFile(selectedFile)
        if (backupFilePath === "") {
            backupStatusText = t("未选择备份文件。", "No backup file selected.")
            return
        }

        if (!DatabaseManager.importBackup(backupFilePath)) {
            backupStatusText = t("恢复失败，请检查备份文件是否可用。", "Restore failed. Please check whether the backup file is valid.")
            return
        }

        latestBackupPath = backupFilePath
        AuthManager.reloadSessionFromStorage()
        loadUserSettings()
        loadCategories()
        refreshCurrentView()
        backupStatusText = t("已从备份文件恢复：", "Restored from backup file: ") + backupFilePath
    }


    Timer {
        id: sidebarBackupResetTimer
        interval: 2200
        repeat: false
        onTriggered: sidebarBackupJustCompleted = false
    }

    function categoryIndexById(categoryId) {
        if (categoryId <= 0) {
            return 0
        }
        for (let i = 0; i < categoryList.length; ++i) {
            if (categoryList[i].categoryId === categoryId) {
                return i + 1
            }
        }
        return 0
    }

    function showAllTasks() {
        console.log("打开全部任务")
        currentPageType = pageAllTasks
        settingsVisible = false
        middleCollapsed = false
        clearCategoryFilter()
        resetDetail()
        loadCategories()
        AbstractContentsModel.loadAllFromDatabase(databasePath, false, false)
    }

    function showCompletedTasks() {
        console.log("打开已完成任务")
        currentPageType = pageCompleted
        settingsVisible = false
        middleCollapsed = false
        clearCategoryFilter()
        resetDetail()
        loadCategories()
        AbstractContentsModel.loadAllFromDatabase(databasePath, false, true)
    }

    function showGanttChart() {
        console.log("打开甘特图")
        currentPageType = pageGantt
        settingsVisible = false
        middleCollapsed = true
        clearCategoryFilter()
        resetDetail()
        loadCategories()
        GanttModel.loadTasks()
    }

    function showTodayTasks() {
        console.log("打开今日任务")
        currentPageType = pageToday
        settingsVisible = false
        middleCollapsed = false
        clearCategoryFilter()
        resetDetail()
        loadCategories()
        AbstractContentsModel.loadAllFromDatabase(databasePath, true, false)
    }

    function showCategoryTasks(categoryId, categoryName) {
        currentPageType = pageAllTasks
        settingsVisible = false
        newTaskVisible = false
        newCategoryVisible = false
        detailVisible = false
        middleCollapsed = false
        activeCategoryId = categoryId
        activeCategoryName = categoryName || ""
        loadCategories()
        AbstractContentsModel.loadAllFromDatabase(databasePath, false, false)
    }

    function showSettings() {
        if (!AuthManager.isLoggedIn) {
            openLoginWindow()
            return
        }
        settingsVisible = true
        middleCollapsed = true
        resetDetail()
    }

    function showNewTaskForm() {
        if (!AuthManager.isLoggedIn) {
            openLoginWindow()
            return
        }

        const draftTitle = t("未命名任务", "Untitled Task")
        const draftStartDate = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm")
        const createdTaskId = DatabaseManager.createTask(
            AuthManager.currentUserId,
            draftTitle,
            "",
            "",
            draftStartDate,
            "",
            1,
            0,
            false
        )

        if (createdTaskId <= 0) {
            return
        }

        currentPageType = pageAllTasks
        settingsVisible = false
        detailVisible = false
        newCategoryVisible = false
        newTaskVisible = false
        middleCollapsed = false
        clearCategoryFilter()
        loadCategories()
        AbstractContentsModel.loadAllFromDatabase(databasePath, false, false)

        for (let i = 0; i < AbstractContentsModel.rowCount(); ++i) {
            const task = AbstractContentsModel.get(i)
            if (task.index_num === createdTaskId) {
                openTaskDetail(
                    task.index_num,
                    task.title,
                    task.outline,
                    task.content,
                    task.time,
                    task.startDate,
                    task.author,
                    task.created_at,
                    task.dueDate,
                    task.priority,
                    task.categoryId,
                    task.categoryName,
                    task.categoryColor,
                    task.completed
                )
                break
            }
        }
    }

    function showNewCategoryForm() {
        settingsVisible = false
        detailVisible = false
        newTaskVisible = false
        ensureListPageForEditor()
        newCategoryVisible = true
        middleCollapsed = false
        editingCategoryId = -1
        editingCategoryName = ""
        editingCategoryColor = "#3b82f6"
        loadCategories()
        newCategoryDialog.resetForm()
    }

    function openCategoryEditor(categoryId) {
        for (let i = 0; i < categoryList.length; ++i) {
            const category = categoryList[i]
            if (category.categoryId === categoryId) {
                detailVisible = false
                newTaskVisible = false
                ensureListPageForEditor()
                newCategoryVisible = true
                middleCollapsed = false
                editingCategoryId = category.categoryId
                editingCategoryName = category.name || ""
                editingCategoryColor = category.color || "#3b82f6"
                newCategoryDialog.loadCategory(editingCategoryName, editingCategoryColor)
                break
            }
        }
    }

    function openTaskDetail(taskId, title, outline, content, time, startDate, author, createdAt, dueDate, priority, categoryId, categoryName, categoryColor, completed) {
        settingsVisible = false
        newTaskVisible = false
        newCategoryVisible = false
        selectedTaskId = taskId
        selectedTaskTitle = title
        selectedTaskOutline = outline
        selectedTaskContent = content || outline
        selectedTaskTime = time
        selectedTaskStartDate = startDate || ""
        selectedTaskAuthor = author || "未知作者"
        selectedTaskCreatedAt = createdAt || time
        selectedTaskDueDate = dueDate || ""
        selectedTaskPriority = priority > 0 ? priority : 1
        selectedTaskCategoryId = categoryId > 0 ? categoryId : 0
        selectedTaskCategoryName = categoryName && categoryName !== "" ? categoryName : "未分类"
        selectedTaskCategoryColor = categoryColor && categoryColor !== "" ? categoryColor : "#94a3b8"
        selectedTaskCompleted = completed === true
        selectedDetailCategoryIndex = categoryIndexById(selectedTaskCategoryId)
        editTaskTitle = selectedTaskTitle
        editTaskOutline = selectedTaskOutline
        editTaskContent = selectedTaskContent
        editTaskStartDate = selectedTaskStartDate
        editTaskDueDate = selectedTaskDueDate
        editTaskPriority = selectedTaskPriority
        editTaskCategoryIndex = selectedDetailCategoryIndex
        editTaskCompleted = selectedTaskCompleted
        detailVisible = true
        middleCollapsed = false
    }

    function deleteSelectedTask() {
        if (selectedTaskId < 0) {
            return
        }

        if (DatabaseManager.deleteTask(selectedTaskId)) {
            refreshCurrentView()
            resetDetail()
        }
    }

    function saveSelectedTaskEdits() {
        if (selectedTaskId < 0) {
            return
        }

        const title = editTaskTitle.trim()
        if (title === "") {
            return
        }

        const categoryId = editTaskCategoryIndex > 0 && categoryList.length >= editTaskCategoryIndex ? categoryList[editTaskCategoryIndex - 1].categoryId : 0
        const contentValue = editTaskContent.trim()
        const outlineValue = editTaskOutline.trim()
        const targetTaskId = selectedTaskId
        const movedOutOfCompleted = currentPageType === pageCompleted && !editTaskCompleted
        const ok = DatabaseManager.updateTask(selectedTaskId, {
            "title": title,
            "description": outlineValue,
            "content": contentValue === "" ? outlineValue : contentValue,
            "startDate": editTaskStartDate.trim(),
            "endDate": editTaskDueDate.trim(),
            "priority": editTaskPriority,
            "categoryId": categoryId,
            "completed": editTaskCompleted
        })

        if (!ok) {
            return
        }

        selectedTaskTitle = title
        selectedTaskOutline = outlineValue
        selectedTaskContent = contentValue === "" ? outlineValue : contentValue
        selectedTaskStartDate = editTaskStartDate.trim()
        selectedTaskDueDate = editTaskDueDate.trim()
        selectedTaskPriority = editTaskPriority
        selectedTaskCompleted = editTaskCompleted
        selectedTaskCategoryId = categoryId
        selectedDetailCategoryIndex = editTaskCategoryIndex

        let matched = false
        for (let i = 0; i < categoryList.length; ++i) {
            if (categoryList[i].categoryId === categoryId) {
                selectedTaskCategoryName = categoryList[i].name
                selectedTaskCategoryColor = categoryList[i].color
                matched = true
                break
            }
        }
        if (!matched || categoryId === 0) {
            selectedTaskCategoryName = "未分类"
            selectedTaskCategoryColor = "#94a3b8"
        }

        if (movedOutOfCompleted) {
            showAllTasks()
            for (let i = 0; i < AbstractContentsModel.rowCount(); ++i) {
                const task = AbstractContentsModel.get(i)
                if (task.index_num === targetTaskId) {
                    openTaskDetail(
                        task.index_num,
                        task.title,
                        task.outline,
                        task.content,
                        task.time,
                        task.startDate,
                        task.author,
                        task.created_at,
                        task.dueDate,
                        task.priority,
                        task.categoryId,
                        task.categoryName,
                        task.categoryColor,
                        task.completed
                    )
                    break
                }
            }
            return
        }

        refreshCurrentView()
    }

    function refreshCurrentView() {
        if (currentPageType === pageGantt) {
            GanttModel.loadTasks()
        } else {
            loadCategories()
            AbstractContentsModel.loadAllFromDatabase(databasePath, currentPageType === pageToday, currentPageType === pageCompleted)
        }
    }

    // 登录状态检查
    Component.onCompleted: {
        if (!AuthManager.isLoggedIn) {
            GanttModel.userId = -1
            loadUserSettings()
            loadCategories()
            refreshCurrentView()
            openLoginWindow()
        } else {
            GanttModel.userId = AuthManager.currentUserId
            loadUserSettings()
            loadCategories()
            showTodayTasks()
        }
    }

    // 登录窗口加载器
    Loader {
        id: loginLoader
        active: false
        source: "LoginWindow.qml"
        
        onLoaded: {
            item.show()
            mainWindow.hide()
            
            item.loginSuccessful.connect(function() {
                item.close()
                loginLoader.active = false
                mainWindow.show()
                GanttModel.userId = AuthManager.currentUserId
                loadUserSettings()
                loadCategories()
                showTodayTasks()
            })

            item.closing.connect(function() {
                if (!AuthManager.isLoggedIn) {
                    loginLoader.active = false
                    mainWindow.show()
                }
            })
        }
    }

    // 监听登录状态变化
    Connections {
        target: AuthManager
        
        function onLoginStateChanged() {
            if (AuthManager.isLoggedIn) {
                GanttModel.userId = AuthManager.currentUserId
                loadUserSettings()
                loadCategories()
                refreshCurrentView()
            } else {
                GanttModel.userId = -1
                loadUserSettings()
                categoryList = []
                clearCategoryFilter()
                showTodayTasks()
            }
        }
    }

    Popup {
        id: detailDatePopup
        width: 360
        modal: true
        focus: true
        anchors.centerIn: Overlay.overlay
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        padding: 0

        background: Rectangle {
            radius: 18
            color: homeDarkMode ? "#ffffff" : "#ffffff"
            border.color: homeDarkMode ? "#dbe4f0" : "#d8dee8"
            border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            Label {
                text: detailDateTimeField === "start" ? "选择开始时间" : "选择结束时间"
                font.pixelSize: 18
                font.bold: true
                color: homeDarkMode ? "#111827" : "#1f2937"
            }

            GridLayout {
                columns: 2
                columnSpacing: 12
                rowSpacing: 10
                Layout.fillWidth: true

                Label { text: "年"; color: homeDarkMode ? "#475569" : "#64748b" }
                SpinBox { id: detailDateYear; from: 2020; to: 2100; editable: true; Layout.fillWidth: true }

                Label { text: "月"; color: homeDarkMode ? "#475569" : "#64748b" }
                SpinBox { id: detailDateMonth; from: 1; to: 12; editable: true; Layout.fillWidth: true }

                Label { text: "日"; color: homeDarkMode ? "#475569" : "#64748b" }
                SpinBox { id: detailDateDay; from: 1; to: 31; editable: true; Layout.fillWidth: true }

                Label { text: "时"; color: homeDarkMode ? "#475569" : "#64748b" }
                SpinBox { id: detailDateHour; from: 0; to: 23; editable: true; Layout.fillWidth: true }

                Label { text: "分"; color: homeDarkMode ? "#475569" : "#64748b" }
                SpinBox { id: detailDateMinute; from: 0; to: 59; editable: true; Layout.fillWidth: true }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Item { Layout.fillWidth: true }

                Button {
                    text: "取消"
                    implicitWidth: 72
                    onClicked: detailDatePopup.close()
                }

                Button {
                    text: "应用"
                    implicitWidth: 72
                    onClicked: {
                        mainWindow.applyDetailDateTime()
                        detailDatePopup.close()
                    }
                }
            }
        }
    }

    FileDialog {
        id: detailAttachmentDialog
        title: "选择附件文件"
        fileMode: pendingAttachmentReplacePath === "" ? FileDialog.OpenFiles : FileDialog.OpenFile
        onAccepted: {
            if (pendingAttachmentReplacePath !== "") {
                const filePath = mainWindow.normalizeSelectedFile(selectedFile)
                editTaskContent = mainWindow.replaceAttachmentInContent(editTaskContent, pendingAttachmentReplacePath, filePath)
            } else {
                const files = selectedFiles || []
                for (let i = 0; i < files.length; ++i) {
                    editTaskContent = mainWindow.appendAttachmentToContent(editTaskContent, mainWindow.normalizeSelectedFile(files[i]))
                }
            }
            pendingAttachmentReplacePath = ""
            mainWindow.saveSelectedTaskEdits()
        }
        onRejected: pendingAttachmentReplacePath = ""
    }

    FileDialog {
        id: restoreBackupDialog
        title: t("选择要恢复的备份文件", "Choose backup file to restore")
        fileMode: FileDialog.OpenFile
        nameFilters: ["Database backup (*.db)", "All files (*)"]
        onAccepted: mainWindow.restoreBackupFromFile(selectedFile)
    }

    FolderDialog {
        id: backupFolderDialog
        title: t("选择备份目录", "Choose backup folder")
        currentFolder: backupDirectory === "" ? "file:///" : Qt.resolvedUrl(backupDirectory)
        onAccepted: {
            backupDirectory = mainWindow.normalizeSelectedFile(selectedFolder)
            backupStatusText = t("备份目录已更新。", "Backup folder updated.")
        }
    }

    MainSidebar {
        id: leftSidebar
        mainWindowRef: mainWindow
    }

    Rectangle {
        id: contentArea
        anchors.left: leftSidebar.right
        anchors.top: parent.top
        width: mainWindow.width - leftSidebar.width
        height: mainWindow.height
        color: pageBaseColor

        readonly property bool ganttMode: currentPageType === pageGantt
        readonly property bool showWidePanel: ganttMode || settingsVisible
        readonly property bool splitMode: !showWidePanel && (detailVisible || newTaskVisible || newCategoryVisible)
        property real detailBackPeekOffset: 0
        property real compactBackButtonScale: 1
        property real compactBackArrowOffset: 0
        property real compactBackHighlightOpacity: 0
        property real compactBackHoverOpacity: 0
        property real compactBackTitleOffset: 0
        readonly property real splitListMinimumWidth: 280
        readonly property real detailActionWidthEstimate: 180
        readonly property real detailMetaWidthEstimate: Math.max(180 + 220 + 8, 240 + 220 + 8)
        readonly property real detailInfoRowEstimate: 120 + 120 + 8
        readonly property real detailSummaryRowEstimate: 300
        readonly property real detailContentWidthEstimate: 84 + 72 + 8 + 220
        readonly property real detailMinimumWidth: 24 + Math.max(detailActionWidthEstimate,
                                                                 detailMetaWidthEstimate,
                                                                 detailInfoRowEstimate,
                                                                 detailSummaryRowEstimate,
                                                                 detailContentWidthEstimate) + Math.max(88, detailFontSize * 6)
        readonly property real emptyStateMinimumWidth: 340
        readonly property real activeRightMinimumWidth: (detailVisible || newTaskVisible || newCategoryVisible) ? detailMinimumWidth : emptyStateMinimumWidth
        readonly property bool compactDetailMode: false
        readonly property real targetMiddleWidth: showWidePanel ? 0 : ((detailVisible || newTaskVisible || newCategoryVisible)
                                                                       ? Math.min(Math.max(splitListMinimumWidth, Math.min(360, width * 0.31)), Math.max(splitListMinimumWidth, width - activeRightMinimumWidth))
                                                                       : Math.min(Math.max(splitListMinimumWidth, Math.min(340, width * 0.34)), Math.max(splitListMinimumWidth, width - activeRightMinimumWidth)))

        Rectangle {
            id: middlePanel
            x: 0
            width: contentArea.targetMiddleWidth
            height: parent.height
            visible: true
            color: pageBaseColor
            clip: true

            Behavior on width {
                NumberAnimation { duration: 260; easing.type: Easing.InOutQuad }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    radius: 12
                    color: homeDarkMode ? "#3a4049" : "#ffffff"
                    border.color: homeDarkMode ? "#4b5563" : "#d8dee8"
                    border.width: 1
                    visible: middlePanel.width > 0

                    readonly property bool abstractVisible: !contentArea.ganttMode && !settingsVisible

                    MouseArea {
                        anchors.fill: parent
                        enabled: false
                        cursorShape: Qt.ArrowCursor
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        Label {
                            text: pageTitleText()
                            color: homeDarkMode ? "#f3f4f6" : "#0f172a"
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Label {
                            visible: parent.parent.abstractVisible
                            text: t("可直接点击标题选择任务", "Click a title to select a task")
                            color: detailHintTextColor
                            font.pixelSize: 12
                        }

                        Item { Layout.fillWidth: true }
                    }
                }

                AbstractContents {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: !contentArea.ganttMode && !settingsVisible
                    searchKeyword: leftSidebar.searchText
                    selectedCategoryId: mainWindow.activeCategoryId
                    onItemSelected: (taskId, title, outline, content, time, startDate, author, createdAt, dueDate, priority, categoryId, categoryName, categoryColor, completed) =>
                                        mainWindow.openTaskDetail(taskId, title, outline, content, time, startDate, author, createdAt, dueDate, priority, categoryId, categoryName, categoryColor, completed)
                }
            }
        }

        Rectangle {
            id: rightPanel
            x: middlePanel.width
            width: Math.max(contentArea.activeRightMinimumWidth, parent.width - middlePanel.width)
            height: parent.height
            visible: true
            color: pageBaseColor
            clip: true

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 1
                color: homeDarkMode ? "#5b6471" : "#d2dae4"
                opacity: 1
                z: 3
            }

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 14
                color: homeDarkMode ? "#0f172a" : "#94a3b8"
                opacity: homeDarkMode ? 0.14 : 0.08
                z: 2
            }

            Image {
                anchors.fill: parent
                source: backgroundImageSource
                fillMode: Image.PreserveAspectCrop
                visible: backgroundImageSource !== ""
                opacity: homeDarkMode ? 0.18 : 0.28
            }

            Rectangle {
                anchors.fill: parent
                color: pageBaseColor
                opacity: backgroundImageSource === "" ? 1 : 0.86
            }

            Behavior on x {
                NumberAnimation { duration: 260; easing.type: Easing.InOutQuad }
            }
            Behavior on width {
                NumberAnimation { duration: 260; easing.type: Easing.InOutQuad }
            }


            StackLayout {
                anchors.fill: parent
                currentIndex: settingsVisible ? 1 : (newCategoryVisible ? 3 : (newTaskVisible ? 2 : (contentArea.ganttMode ? 4 : 0)))

                Rectangle {
                    color: pageBaseColor

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        DetailHeaderBar {
                            Layout.fillWidth: true
                            titleText: newTaskVisible ? t("新建任务", "New Task") : (newCategoryVisible ? t("新建分类", "New Category") : (detailVisible ? (editTaskTitle.trim() === "" ? t("未命名任务", "Untitled Task") : editTaskTitle) : (settingsVisible ? t("设置说明", "Settings") : t("等待选择", "Waiting for selection"))))
                            compactTitleText: titleText
                            compactDetailMode: contentArea.compactDetailMode && detailVisible && !settingsVisible
                            showActions: detailVisible && !settingsVisible
                            homeDarkMode: mainWindow.homeDarkMode
                            detailFontSize: mainWindow.detailFontSize
                            detailTextColor: mainWindow.detailTextColor
                            compactTitleColor: homeDarkMode ? "#f8fafc" : "#111827"
                            onTitleEdited: function(value) { mainWindow.editTaskTitle = value }
                            onTitleEditFinished: mainWindow.saveSelectedTaskEdits()
                            onDeleteClicked: mainWindow.deleteSelectedTask()
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 12
                            color: detailSurfaceColor
                            border.color: detailBorderColor
                            border.width: 1

                            ScrollView {
                                id: detailScrollView
                                anchors.fill: parent
                                anchors.margins: 6
                                clip: true
                                contentHeight: detailScrollContent.implicitHeight
                                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                                ScrollBar.vertical: ScrollBar {
                                    width: hovered || pressed ? 8 : 6
                                    policy: ScrollBar.AsNeeded
                                    minimumSize: 0.18

                                    Behavior on width {
                                        NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
                                    }

                                    contentItem: Rectangle {
                                        implicitWidth: parent.width
                                        radius: implicitWidth / 2
                                        color: parent.pressed
                                               ? (homeDarkMode ? "#93c5fd" : "#2563eb")
                                               : parent.hovered
                                                 ? (homeDarkMode ? "#7dd3fc" : "#3b82f6")
                                                 : (homeDarkMode ? "#64748b" : "#94a3b8")
                                        opacity: parent.pressed
                                                 ? 0.95
                                                 : parent.hovered
                                                   ? (homeDarkMode ? 0.92 : 0.9)
                                                   : (homeDarkMode ? 0.28 : 0.24)

                                        Behavior on color {
                                            ColorAnimation { duration: 140 }
                                        }
                                        Behavior on opacity {
                                            NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
                                        }
                                    }

                                    background: Rectangle {
                                        implicitWidth: parent.width
                                        radius: implicitWidth / 2
                                        color: homeDarkMode ? "#1f2937" : "#e2e8f0"
                                        opacity: parent.hovered || parent.pressed
                                                 ? (homeDarkMode ? 0.3 : 0.45)
                                                 : (homeDarkMode ? 0.12 : 0.18)

                                        Behavior on opacity {
                                            NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
                                        }
                                    }
                                }

                                Item {
                                    id: detailScrollContent
                                    width: detailScrollView.availableWidth
                                    implicitHeight: detailColumn.implicitHeight

                                    ColumnLayout {
                                        id: detailColumn
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.top: parent.top
                                        width: parent.width
                                        spacing: 6

                                        Label {
                                            visible: false
                                            text: settingsVisible ? t("界面设置已展开到主区域，可以直接调整主题、背景图和字体大小。", "Settings are expanded in the main area. You can directly adjust theme, background, and font sizes.") : t("从中间列表选择一个任务后，右侧会在这里展示完整详情。你可以直接编辑标题、概要与时间。", "Choose a task from the middle list and its full details will appear here. You can edit the title, summary, and time directly.")
                                            wrapMode: Text.WordWrap
                                            color: detailHintTextColor
                                            font.pixelSize: detailFontSize - 2
                                        }

                                        EmptyDetailState {
                                            visible: !detailVisible && !newTaskVisible
                                            homeDarkMode: mainWindow.homeDarkMode
                                            detailFontSize: mainWindow.detailFontSize
                                            detailTextColor: mainWindow.detailTextColor
                                            detailHintTextColor: mainWindow.detailHintTextColor
                                            tFunc: mainWindow.t
                                        }

                                        DetailMetaSection {
                                            visibleSection: detailVisible
                                            showTitleEditor: false
                                            homeDarkMode: mainWindow.homeDarkMode
                                            detailFontSize: mainWindow.detailFontSize
                                            editTaskTitle: mainWindow.editTaskTitle
                                            selectedTaskCategoryColor: mainWindow.selectedTaskCategoryColor
                                            selectedTaskCategoryName: mainWindow.selectedTaskCategoryName
                                            selectedTaskAuthor: mainWindow.selectedTaskAuthor
                                            selectedTaskCreatedAt: mainWindow.selectedTaskCreatedAt
                                            editTaskStartDate: mainWindow.editTaskStartDate
                                            editTaskDueDate: mainWindow.editTaskDueDate
                                            editTaskPriority: mainWindow.editTaskPriority
                                            editTaskCategoryIndex: mainWindow.editTaskCategoryIndex
                                            categoryList: mainWindow.categoryList
                                            showIdentitySection: true
                                            showScheduleSection: false
                                            showDetailAuthor: mainWindow.showDetailAuthor
                                            showDetailCreatedDate: mainWindow.showDetailCreatedDate
                                            showDetailStartDate: mainWindow.showDetailStartDate
                                            showDetailDueDate: mainWindow.showDetailDueDate
                                            showDetailPriority: mainWindow.showDetailPriority
                                            detailTextColor: mainWindow.detailTextColor
                                            detailMutedTextColor: mainWindow.detailMutedTextColor
                                            detailHintTextColor: mainWindow.detailHintTextColor
                                            detailBorderColor: mainWindow.detailBorderColor
                                            detailElevatedColor: mainWindow.detailElevatedColor
                                            detailAccentColor: mainWindow.detailAccentColor
                                            detailOnAccentColor: mainWindow.detailOnAccentColor
                                            detailTonalColor: mainWindow.detailTonalColor
                                            tFunc: mainWindow.t
                                            formatDateTimeFunc: mainWindow.formatDisplayDateTime
                                            openDateTimeEditorFunc: mainWindow.openDateTimeEditor
                                            onTitleEdited: function(value) { mainWindow.editTaskTitle = value }
                                            onTitleEditFinished: mainWindow.saveSelectedTaskEdits()
                                            onStartDateEdited: function(value) { mainWindow.editTaskStartDate = value; mainWindow.saveSelectedTaskEdits() }
                                            onDueDateEdited: function(value) { mainWindow.editTaskDueDate = value; mainWindow.saveSelectedTaskEdits() }
                                            onPriorityEdited: function(value) { mainWindow.editTaskPriority = value; mainWindow.saveSelectedTaskEdits() }
                                            onCategoryIndexEdited: function(value) { mainWindow.editTaskCategoryIndex = value; mainWindow.saveSelectedTaskEdits() }
                                        }

                                        DetailEditingSection {
                                            visibleSection: detailVisible
                                            homeDarkMode: mainWindow.homeDarkMode
                                            detailFontSize: mainWindow.detailFontSize
                                            editTaskOutline: mainWindow.editTaskOutline
                                            editTaskContent: mainWindow.editTaskContent
                                            editTaskCompleted: mainWindow.editTaskCompleted
                                            detailTextColor: mainWindow.detailTextColor
                                            detailHintTextColor: mainWindow.detailHintTextColor
                                            detailMutedTextColor: mainWindow.detailMutedTextColor
                                            detailBorderColor: mainWindow.detailBorderColor
                                            detailAccentColor: mainWindow.detailAccentColor
                                            detailOnAccentColor: mainWindow.detailOnAccentColor
                                            tFunc: mainWindow.t
                                            contentIsImageFunc: mainWindow.contentIsImage
                                            contentIsFileFunc: mainWindow.contentIsFile
                                            selectedFileNameFunc: mainWindow.selectedFileName
                                            onOutlineEdited: function(value) { mainWindow.editTaskOutline = value }
                                            onEditingFinished: mainWindow.saveSelectedTaskEdits()
                                            onContentEdited: function(value) { mainWindow.editTaskContent = value }
                                            onCompletedEdited: function(value) { mainWindow.editTaskCompleted = value; mainWindow.saveSelectedTaskEdits() }
                                            onUploadFileRequested: function(replacePath) {
                                                mainWindow.pendingAttachmentReplacePath = replacePath || ""
                                                detailAttachmentDialog.open()
                                            }
                                            onOpenFileRequested: function(path) { mainWindow.openLocalFile(path) }
                                            onRemoveAttachmentRequested: function(path) {
                                                mainWindow.editTaskContent = mainWindow.removeAttachmentFromContent(mainWindow.editTaskContent, path)
                                                mainWindow.saveSelectedTaskEdits()
                                            }
                                        }


                                        DetailMetaSection {
                                            visibleSection: detailVisible
                                            showTitleEditor: false
                                            homeDarkMode: mainWindow.homeDarkMode
                                            detailFontSize: mainWindow.detailFontSize
                                            editTaskTitle: mainWindow.editTaskTitle
                                            selectedTaskCategoryColor: mainWindow.selectedTaskCategoryColor
                                            selectedTaskCategoryName: mainWindow.selectedTaskCategoryName
                                            selectedTaskAuthor: mainWindow.selectedTaskAuthor
                                            selectedTaskCreatedAt: mainWindow.selectedTaskCreatedAt
                                            editTaskStartDate: mainWindow.editTaskStartDate
                                            editTaskDueDate: mainWindow.editTaskDueDate
                                            editTaskPriority: mainWindow.editTaskPriority
                                            editTaskCategoryIndex: mainWindow.editTaskCategoryIndex
                                            categoryList: mainWindow.categoryList
                                            showIdentitySection: false
                                            showScheduleSection: true
                                            showDetailAuthor: mainWindow.showDetailAuthor
                                            showDetailCreatedDate: mainWindow.showDetailCreatedDate
                                            showDetailStartDate: mainWindow.showDetailStartDate
                                            showDetailDueDate: mainWindow.showDetailDueDate
                                            showDetailPriority: mainWindow.showDetailPriority
                                            detailTextColor: mainWindow.detailTextColor
                                            detailMutedTextColor: mainWindow.detailMutedTextColor
                                            detailHintTextColor: mainWindow.detailHintTextColor
                                            detailBorderColor: mainWindow.detailBorderColor
                                            detailElevatedColor: mainWindow.detailElevatedColor
                                            detailAccentColor: mainWindow.detailAccentColor
                                            detailOnAccentColor: mainWindow.detailOnAccentColor
                                            detailTonalColor: mainWindow.detailTonalColor
                                            tFunc: mainWindow.t
                                            formatDateTimeFunc: mainWindow.formatDisplayDateTime
                                            openDateTimeEditorFunc: mainWindow.openDateTimeEditor
                                            onTitleEdited: function(value) { mainWindow.editTaskTitle = value }
                                            onTitleEditFinished: mainWindow.saveSelectedTaskEdits()
                                            onStartDateEdited: function(value) { mainWindow.editTaskStartDate = value; mainWindow.saveSelectedTaskEdits() }
                                            onDueDateEdited: function(value) { mainWindow.editTaskDueDate = value; mainWindow.saveSelectedTaskEdits() }
                                            onPriorityEdited: function(value) { mainWindow.editTaskPriority = value; mainWindow.saveSelectedTaskEdits() }
                                            onCategoryIndexEdited: function(value) { mainWindow.editTaskCategoryIndex = value; mainWindow.saveSelectedTaskEdits() }
                                        }

                                        Label {
                                            visible: false
                                            text: selectedTaskTime === "" ? "" : "时间标签：" + mainWindow.formatDisplayDateTime(selectedTaskTime)
                                            color: homeDarkMode ? "#64748b" : "#8b6b42"
                                            font.pixelSize: Math.max(12, detailFontSize - 7)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                SettingsPanel {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: settingsVisible
                    homeDarkMode: false
                    uiLanguage: mainWindow.uiLanguage
                    backgroundImageSource: mainWindow.backgroundImageSource
                    navFontSize: mainWindow.navFontSize
                    middleCardFontSize: mainWindow.middleCardFontSize
                    detailFontSize: mainWindow.detailFontSize
                    timeDisplayFormat: mainWindow.timeDisplayFormat
                    showDetailAuthor: mainWindow.showDetailAuthor
                    showDetailCreatedDate: mainWindow.showDetailCreatedDate
                    showDetailStartDate: mainWindow.showDetailStartDate
                    showDetailDueDate: mainWindow.showDetailDueDate
                    showDetailPriority: mainWindow.showDetailPriority
                    ganttBlueTheme: mainWindow.ganttBlueTheme
                    backupDirectory: mainWindow.backupDirectory
                    backupStatusText: mainWindow.backupStatusText
                    currentUserName: AuthManager.currentUserNickname
                    onBackgroundImageSourceChanged: {
                        mainWindow.backgroundImageSource = backgroundImageSource
                        mainWindow.persistUserSettings()
                    }
                    onNavFontSizeChanged: {
                        mainWindow.navFontSize = navFontSize
                        mainWindow.persistUserSettings()
                    }
                    onMiddleCardFontSizeChanged: {
                        mainWindow.middleCardFontSize = middleCardFontSize
                        mainWindow.persistUserSettings()
                    }
                    onDetailFontSizeChanged: {
                        mainWindow.detailFontSize = detailFontSize
                        mainWindow.persistUserSettings()
                    }
                    onTimeDisplayFormatChanged: {
                        mainWindow.timeDisplayFormat = timeDisplayFormat
                        mainWindow.persistUserSettings()
                    }
                    onShowDetailAuthorChanged: {
                        mainWindow.showDetailAuthor = showDetailAuthor
                        mainWindow.persistUserSettings()
                    }
                    onShowDetailCreatedDateChanged: {
                        mainWindow.showDetailCreatedDate = showDetailCreatedDate
                        mainWindow.persistUserSettings()
                    }
                    onShowDetailStartDateChanged: {
                        mainWindow.showDetailStartDate = showDetailStartDate
                        mainWindow.persistUserSettings()
                    }
                    onShowDetailDueDateChanged: {
                        mainWindow.showDetailDueDate = showDetailDueDate
                        mainWindow.persistUserSettings()
                    }
                    onShowDetailPriorityChanged: {
                        mainWindow.showDetailPriority = showDetailPriority
                        mainWindow.persistUserSettings()
                    }
                    onGanttBlueThemeChanged: {
                        mainWindow.ganttBlueTheme = ganttBlueTheme
                        mainWindow.persistUserSettings()
                    }
                    onChooseBackupDirectoryRequested: backupFolderDialog.open()
                    onBackupNowRequested: mainWindow.runBackupExport()
                    onRestoreBackupRequested: restoreBackupDialog.open()
                    onDisplayNameEdited: function(value) {
                        if (AuthManager.isLoggedIn) {
                            AuthManager.updateCurrentUserNickname(value)
                        }
                    }
                }

                NewTaskDialog {
                    id: newTaskDialog
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: newTaskVisible
                    active: newTaskVisible
                    homeDarkMode: mainWindow.homeDarkMode
                    uiLanguage: mainWindow.uiLanguage
                    categories: mainWindow.categoryList

                    onSubmitRequested: (title, description, content, startDate, endDate, priority, categoryId, completed) => {
                        if (AuthManager.isLoggedIn) {
                            const createdTaskId = DatabaseManager.createTask(
                                AuthManager.currentUserId,
                                title,
                                description,
                                content,
                                startDate,
                                endDate,
                                priority,
                                categoryId,
                                completed
                            )

                            if (createdTaskId > 0) {
                                refreshCurrentView()
                                AbstractContentsModel.loadAllFromDatabase(databasePath, currentPageType === pageToday)
                                if (AbstractContentsModel.rowCount() > 0) {
                                    const createdTask = AbstractContentsModel.get(0)
                                    openTaskDetail(
                                        createdTask.index_num,
                                        createdTask.title,
                                        createdTask.outline,
                                        createdTask.content,
                                        createdTask.time,
                                        createdTask.startDate,
                                        createdTask.author,
                                        createdTask.created_at,
                                        createdTask.dueDate,
                                        createdTask.priority,
                                        createdTask.categoryId,
                                        createdTask.categoryName,
                                        createdTask.categoryColor,
                                        createdTask.completed
                                    )
                                }
                            }
                        }
                    }
                }

                NewCategoryDialog {
                    id: newCategoryDialog
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: newCategoryVisible
                    active: newCategoryVisible
                    homeDarkMode: mainWindow.homeDarkMode
                    editMode: mainWindow.editingCategoryId > 0
                    categoryName: mainWindow.editingCategoryName
                    selectedCategoryColor: mainWindow.editingCategoryColor

                    onCreateCategoryRequested: (name, color) => {
                        if (AuthManager.isLoggedIn) {
                            const categoryId = DatabaseManager.createCategory(AuthManager.currentUserId, name, color, "")
                            if (categoryId > 0) {
                                loadCategories()
                                editingCategoryId = categoryId
                                editingCategoryName = name
                                editingCategoryColor = color
                                AbstractContentsModel.loadAllFromDatabase(databasePath, false, false)
                                newCategoryDialog.loadCategory(name, color)
                            }
                        }
                    }

                    onUpdateCategoryRequested: (name, color) => {
                        if (editingCategoryId > 0 && DatabaseManager.updateCategory(editingCategoryId, name, color)) {
                            editingCategoryName = name
                            editingCategoryColor = color
                            loadCategories()
                            AbstractContentsModel.loadAllFromDatabase(databasePath, false, false)
                            newCategoryDialog.loadCategory(name, color)
                        }
                    }

                    onDeleteCategoryRequested: {
                        if (editingCategoryId > 0 && DatabaseManager.deleteCategory(editingCategoryId)) {
                            const deletedCategoryId = editingCategoryId
                            editingCategoryId = -1
                            editingCategoryName = ""
                            editingCategoryColor = "#3b82f6"
                            if (activeCategoryId === deletedCategoryId) {
                                activeCategoryId = -1
                                activeCategoryName = ""
                            }
                            loadCategories()
                            AbstractContentsModel.loadAllFromDatabase(databasePath, false, false)
                            newCategoryDialog.resetForm()
                        }
                    }
                }
                Rectangle {
                    color: pageBaseColor
                    clip: true

                    GanttChart {
                        anchors.fill: parent
                        blueTaskBarsEnabled: mainWindow.ganttBlueTaskBars
                        blueTodayColumnEnabled: mainWindow.ganttBlueTodayColumn
                        blueGridLinesEnabled: mainWindow.ganttBlueGridLines
                        onTaskClicked: (taskId) => {
                            refreshCurrentView()
                            for (let i = 0; i < AbstractContentsModel.rowCount(); ++i) {
                                const task = AbstractContentsModel.get(i)
                                if (task.index_num === taskId) {
                                    openTaskDetail(
                                        task.index_num,
                                        task.title,
                                        task.outline,
                                        task.content,
                                        task.time,
                                        task.startDate,
                                        task.author,
                                        task.created_at,
                                        task.dueDate,
                                        task.priority,
                                        task.categoryId,
                                        task.categoryName,
                                        task.categoryColor,
                                        task.completed
                                    )
                                    break
                                }
                            }
                        }
                        onTaskDatesChanged: () => refreshCurrentView()
                        onTaskProgressChanged: () => refreshCurrentView()
                    }
                }
            }
        }
    }
}

