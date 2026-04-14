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
    property string detailDateTimeField: "start"
    property var defaultUserSettings: DatabaseManager.defaultUserSettings()
    property bool showDetailAuthor: defaultUserSettings.showDetailAuthor
    property bool showDetailCreatedDate: defaultUserSettings.showDetailCreatedDate
    property bool showDetailStartDate: defaultUserSettings.showDetailStartDate
    property bool showDetailDueDate: defaultUserSettings.showDetailDueDate
    property bool showDetailPriority: defaultUserSettings.showDetailPriority
    property bool ganttBlueTaskBars: defaultUserSettings.ganttBlueTaskBars
    property bool ganttBlueTodayColumn: defaultUserSettings.ganttBlueTodayColumn
    property bool ganttBlueGridLines: defaultUserSettings.ganttBlueGridLines
    property bool homeDarkMode: defaultUserSettings.homeDarkMode
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

    onHomeDarkModeChanged: persistUserSettings()
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

    width: self_width * 0.6
    height: self_height * 0.6
    title: qsTr("Everyday Plan")

    component NavToolButton: ToolButton {
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
            color: parent.checked ? "#dbeafe" : (parent.pressed ? "#e5eefc" : "transparent")
            border.color: parent.checked ? "#60a5fa" : "#d6deea"
            border.width: parent.checked ? 2 : 1
        }

        contentItem: Text {
            text: parent.text
            color: parent.checked ? "#1d4ed8" : "#1f2937"
            font.pointSize: navFontSize
            font.bold: parent.checked
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            elide: Text.ElideRight
        }
    }

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
            color: parent.down ? Qt.darker(detailTonalColor, 1.12) : (homeDarkMode ? "#364152" : "#edf3fb")
            border.color: parent.hovered ? (homeDarkMode ? "#7c8aa0" : "#c7d6ea") : detailBorderColor
            border.width: 1
        }

        contentItem: Text {
            text: parent.text
            color: homeDarkMode ? "#dbeafe" : "#33527f"
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
            "ganttBlueGridLines": ganttBlueGridLines
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
    }

    function loadUserSettings() {
        if (!AuthManager.isLoggedIn) {
            return
        }
        applyUserSettings(DatabaseManager.getUserSettings(AuthManager.currentUserId))
    }

    function persistUserSettings() {
        if (!AuthManager.isLoggedIn) {
            return
        }
        DatabaseManager.saveUserSettings(AuthManager.currentUserId, collectUserSettings())
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
        settingsVisible = false
        detailVisible = false
        newCategoryVisible = false
        ensureListPageForEditor()
        newTaskVisible = true
        middleCollapsed = false
        loadCategories()
        newTaskDialog.resetForm()
    }

    function showNewCategoryForm() {
        settingsVisible = false
        detailVisible = false
        newTaskVisible = false
        ensureListPageForEditor()
        newCategoryVisible = true
        middleCollapsed = false
        loadCategories()
        newCategoryDialog.resetForm()
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
            color: homeDarkMode ? "#ffffff" : "#fffaf0"
            border.color: homeDarkMode ? "#dbe4f0" : "#e6d9bf"
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
                color: homeDarkMode ? "#111827" : "#3f3120"
            }

            GridLayout {
                columns: 2
                columnSpacing: 12
                rowSpacing: 10
                Layout.fillWidth: true

                Label { text: "年"; color: homeDarkMode ? "#475569" : "#7a6240" }
                SpinBox { id: detailDateYear; from: 2020; to: 2100; editable: true; Layout.fillWidth: true }

                Label { text: "月"; color: homeDarkMode ? "#475569" : "#7a6240" }
                SpinBox { id: detailDateMonth; from: 1; to: 12; editable: true; Layout.fillWidth: true }

                Label { text: "日"; color: homeDarkMode ? "#475569" : "#7a6240" }
                SpinBox { id: detailDateDay; from: 1; to: 31; editable: true; Layout.fillWidth: true }

                Label { text: "时"; color: homeDarkMode ? "#475569" : "#7a6240" }
                SpinBox { id: detailDateHour; from: 0; to: 23; editable: true; Layout.fillWidth: true }

                Label { text: "分"; color: homeDarkMode ? "#475569" : "#7a6240" }
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
        fileMode: FileDialog.OpenFile
        onAccepted: editTaskContent = mainWindow.normalizeSelectedFile(selectedFile)
    }

    Rectangle {
        id: leftRectangle
        x: 0
        y: 0
        width: leftRectangle.left_rectangle_width
        height: mainWindow.height
        visible: true
        color: homeDarkMode ? "#2f343c" : "#ffffff"
        z: 3
        property int left_rectangle_width: 244
        property int hight_tooiBar: 156
        property int hight_account_tangle: 78
        property int hight_searchinput: 30
        property int topBargin: 12
        property int sidebarSectionGap: 12

        // 用户信息区域
        Rectangle {
            id: accountTangle
            visible: true
            readonly property bool loginPrompt: !AuthManager.isLoggedIn
            readonly property bool settingsActive: settingsVisible && AuthManager.isLoggedIn
            color: settingsActive ? "#1e3a5f" : (loginPrompt ? (loginHoverArea.containsMouse ? "#e0efff" : "#eff6ff") : "#eff6ff")
            width: leftRectangle.width
            height: leftRectangle.hight_account_tangle
            border.color: settingsActive ? "#60a5fa" : (loginPrompt ? (loginHoverArea.containsMouse ? "#60a5fa" : "#93c5fd") : "#d7e7fb")
            border.width: settingsActive || loginPrompt ? 2 : 1

            Behavior on color {
                ColorAnimation { duration: 140 }
            }

            Behavior on border.color {
                ColorAnimation { duration: 140 }
            }

            Rectangle {
                id: loginPulse
                anchors.fill: parent
                visible: loginPrompt
                radius: 0
                color: "#93c5fd"
                opacity: 0.08
                z: 0

                SequentialAnimation on opacity {
                    running: accountTangle.loginPrompt && !loginHoverArea.containsMouse
                    loops: Animation.Infinite
                    NumberAnimation { from: 0.05; to: 0.14; duration: 1150; easing.type: Easing.InOutQuad }
                    NumberAnimation { from: 0.14; to: 0.05; duration: 1150; easing.type: Easing.InOutQuad }
                }
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: loginPrompt ? 1 : 0
                radius: 0
                color: "transparent"
                visible: loginPrompt
                border.color: "transparent"

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 10
                    height: 42
                    radius: 14
                    color: loginHoverArea.containsMouse ? "#f8fbff" : "#ffffff"
                    border.color: loginHoverArea.containsMouse ? "#93c5fd" : "#bfdbfe"
                    border.width: 1
                    opacity: 0.96

                    Behavior on color {
                        ColorAnimation { duration: 140 }
                    }

                    Behavior on border.color {
                        ColorAnimation { duration: 140 }
                    }
                }
            }

            MouseArea {
                id: loginHoverArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: showSettings()
                cursorShape: Qt.PointingHandCursor
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                // 用户头像
                Rectangle {
                    width: 38
                    height: 32
                    radius: 18
                    color: accountTangle.settingsActive ? "#f8fafc" : (accountTangle.loginPrompt ? (loginHoverArea.containsMouse ? "#eff6ff" : "#ffffff") : "#dbeafe")
                    border.color: accountTangle.loginPrompt ? (loginHoverArea.containsMouse ? "#60a5fa" : "#93c5fd") : "transparent"
                    border.width: accountTangle.loginPrompt ? 1 : 0

                    Behavior on color {
                        ColorAnimation { duration: 140 }
                    }

                    Behavior on border.color {
                        ColorAnimation { duration: 140 }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: AuthManager.isLoggedIn ? 
                              AuthManager.currentUserNickname.charAt(0).toUpperCase() : "登"
                        font.pixelSize: 18
                        font.bold: true
                        color: accountTangle.settingsActive ? "#1d4ed8" : "#2563eb"
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: AuthManager.isLoggedIn ? 
                              AuthManager.currentUserNickname : "未登录账号"
                        font.pixelSize: 14
                        font.bold: true
                        color: accountTangle.settingsActive ? "#f8fafc" : "#0f172a"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: AuthManager.isLoggedIn ? 
                              AuthManager.currentUserEmail : "点击登录后同步任务与分类"
                        font.pixelSize: 10
                        color: accountTangle.settingsActive ? "#cbd5e1" : (accountTangle.loginPrompt ? (loginHoverArea.containsMouse ? "#1d4ed8" : "#2563eb") : "#64748b")
                        font.bold: accountTangle.loginPrompt
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                Rectangle {
                    visible: accountTangle.loginPrompt
                    Layout.alignment: Qt.AlignVCenter
                    implicitWidth: loginPillRow.implicitWidth + 18
                    implicitHeight: 24
                    radius: 999
                    color: loginHoverArea.containsMouse ? "#2563eb" : "#dbeafe"
                    border.color: loginHoverArea.containsMouse ? "#1d4ed8" : "#93c5fd"
                    border.width: 1

                    Behavior on color {
                        ColorAnimation { duration: 140 }
                    }

                    Behavior on border.color {
                        ColorAnimation { duration: 140 }
                    }

                    RowLayout {
                        id: loginPillRow
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            text: "登录"
                            font.pixelSize: 10
                            font.bold: true
                            color: loginHoverArea.containsMouse ? "#ffffff" : "#1d4ed8"
                        }

                        Text {
                            text: "→"
                            font.pixelSize: 12
                            font.bold: true
                            color: loginHoverArea.containsMouse ? "#ffffff" : "#1d4ed8"
                        }
                    }
                }

                Button {
                    visible: AuthManager.isLoggedIn
                    text: "退出"
                    font.pixelSize: 11
                    enabled: !settingsVisible
                    opacity: settingsVisible ? 0.55 : 1
                    implicitHeight: 28
                    implicitWidth: 52
                    
                    background: Rectangle {
                        color: parent.pressed ? (accountTangle.settingsActive ? "#334155" : "#dbeafe") : "transparent"
                        border.color: accountTangle.settingsActive ? "#cbd5e1" : "#93c5fd"
                        border.width: 1
                        radius: 4
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 12
                        color: accountTangle.settingsActive ? "#f8fafc" : "#1d4ed8"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: AuthManager.logout()
                }
            }
        }

        TextField {
            id: searchInput
            x: 0
            y: 147
            width: accountTangle.width
            height: leftRectangle.hight_searchinput + 4
            visible: true
            text: ""
            placeholderText: t("搜索任务标题或概要", "Search titles or summaries")
            anchors.top: accountTangle.bottom
            anchors.topMargin: leftRectangle.topBargin
            font.pixelSize: 15
            leftPadding: 10
            rightPadding: 10
            color: "#0f172a"
            selectedTextColor: "#eff6ff"
            selectionColor: "#3b82f6"

            background: Rectangle {
                radius: 12
                color: "#f8fafc"
                border.color: "#cbd5e1"
                border.width: 1
            }
        }

        ToolBar {
            id: toolBar
            x: 0
            width: accountTangle.width
            height: toolBarColumn.implicitHeight
            anchors.top: searchInput.bottom
            anchors.topMargin: leftRectangle.sidebarSectionGap
            transformOrigin: Item.Center

            background: Rectangle {
                color: "transparent"
                border.width: 0
            }

            ColumnLayout {
                id: toolBarColumn
                property int sizeW: 0
                anchors.fill: parent
                spacing: 6

                NavToolButton {
                    id: todayButton
                    text: t("今日任务", "Today")
                    height: 32
                    checked: !settingsVisible && !newTaskVisible && !newCategoryVisible && currentPageType === pageToday
                    Layout.fillHeight: false
                    display: AbstractButton.TextBesideIcon
                    onClicked: showTodayTasks()
                }
                
                NavToolButton {
                    id: toolButton1
                    text: t("全部任务", "All Tasks")
                    height: 32
                    checked: !settingsVisible && !newTaskVisible && !newCategoryVisible && currentPageType === pageAllTasks
                    icon.height: 17
                    icon.width: 17
                    icon.color: "#00000000"
                    onClicked: showAllTasks()
                }

                NavToolButton {
                    id: completedButton
                    text: t("已完成", "Completed")
                    height: 32
                    checked: !settingsVisible && !newTaskVisible && !newCategoryVisible && currentPageType === pageCompleted
                    icon.height: 17
                    icon.width: 17
                    icon.color: "#00000000"
                    onClicked: showCompletedTasks()
                }
                
                NavToolButton {
                    id: ganttButton
                    text: t("甘特图", "Gantt")
                    height: 32
                    checked: !settingsVisible && !newTaskVisible && !newCategoryVisible && currentPageType === pageGantt
                    icon.height: 17
                    icon.width: 17
                    onClicked: showGanttChart()
                }
            }
        }

        CategoryListPanel {
            id: leftCategoryPanel
            width: searchInput.width
            anchors.top: toolBar.bottom
            anchors.topMargin: leftRectangle.sidebarSectionGap
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.bottom: toolBar1.top
            anchors.bottomMargin: leftRectangle.sidebarSectionGap
            visible: true
            homeDarkMode: mainWindow.homeDarkMode
            categories: mainWindow.categoryList
            selectedCategoryId: settingsVisible ? -1 : mainWindow.activeCategoryId
            titleText: currentPageType === pageGantt ? t("甘特图分类", "Gantt Categories") : t("已有分类", "Categories")
            onCategorySelected: (categoryId, categoryName) => mainWindow.showCategoryTasks(categoryId, categoryName)
            onCreateCategoryRequested: showNewCategoryForm()
        }

        ToolBar {
            id: toolBar1
            x: 0
            width: accountTangle.width
            height: 38
            anchors.bottom: parent.bottom
            anchors.bottomMargin: leftRectangle.sidebarSectionGap + 2

            background: Rectangle {
                color: "transparent"
                border.width: 0
            }

            ColumnLayout {
                id: columnLayout
                anchors.fill: parent
                spacing: 0

                NavToolButton {
                    text: t("新建任务", "New Task")
                    checked: newTaskVisible
                    implicitHeight: 30
                    Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                    onClicked: showNewTaskForm()
                }
            }
        }
    }

    Rectangle {
        id: contentArea
        anchors.left: leftRectangle.right
        anchors.top: parent.top
        width: mainWindow.width - leftRectangle.width
        height: mainWindow.height
        color: pageBaseColor

        readonly property bool ganttMode: currentPageType === pageGantt
        readonly property bool showWidePanel: ganttMode || settingsVisible || newCategoryVisible
        readonly property bool splitMode: !showWidePanel && (detailVisible || newTaskVisible)
        property real detailBackPeekOffset: 0
        property real compactBackButtonScale: 1
        property real compactBackArrowOffset: 0
        property real compactBackHighlightOpacity: 0
        property real compactBackHoverOpacity: 0
        property real compactBackTitleOffset: 0
        readonly property real splitListMinimumWidth: 320
        readonly property real detailActionWidthEstimate: 220
        readonly property real detailMetaWidthEstimate: Math.max(220 + 260 + 12, 300 + 300 + 12)
        readonly property real detailInfoRowEstimate: 140 + 140 + 10
        readonly property real detailSummaryRowEstimate: 360
        readonly property real detailContentWidthEstimate: 110 + 90 + 10 + 320
        readonly property real detailMinimumWidth: 40 + Math.max(detailActionWidthEstimate,
                                                                 detailMetaWidthEstimate,
                                                                 detailInfoRowEstimate,
                                                                 detailSummaryRowEstimate,
                                                                 detailContentWidthEstimate) + Math.max(120, detailFontSize * 8)
        readonly property bool compactDetailMode: false
        readonly property real targetMiddleWidth: showWidePanel ? 0 : ((detailVisible || newTaskVisible)
                                                                       ? Math.min(Math.max(splitListMinimumWidth, Math.min(440, width * 0.38)), Math.max(splitListMinimumWidth, width - detailMinimumWidth))
                                                                       : Math.max(splitListMinimumWidth, Math.min(480, width * 0.52)))

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
                    color: homeDarkMode ? "#3a4049" : "#fbf6ec"
                    border.color: homeDarkMode ? "#4b5563" : "#e6d9bf"
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
                            color: homeDarkMode ? "#f3f4f6" : "#3f3120"
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
                    searchKeyword: searchInput.text
                    selectedCategoryId: mainWindow.activeCategoryId
                    onItemSelected: (taskId, title, outline, content, time, startDate, author, createdAt, dueDate, priority, categoryId, categoryName, categoryColor, completed) =>
                                        mainWindow.openTaskDetail(taskId, title, outline, content, time, startDate, author, createdAt, dueDate, priority, categoryId, categoryName, categoryColor, completed)
                }
            }
        }

        Rectangle {
            id: rightPanel
            x: middlePanel.width
            width: Math.max(contentArea.detailMinimumWidth, parent.width - middlePanel.width)
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
                        anchors.margins: 16
                        spacing: 16

                        Item {
                            Layout.fillWidth: true
                            implicitHeight: 48

                            Rectangle {
                                anchors.fill: parent
                                visible: false
                                radius: 0
                                color: homeDarkMode ? "#303841" : "#f8fafc"
                                opacity: 1
                                border.width: 0
                            }

                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: 1
                                visible: false
                                color: homeDarkMode ? "#4b5563" : "#d7dee8"
                                opacity: 1
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 0
                                anchors.rightMargin: 0
                                anchors.topMargin: 0
                                anchors.bottomMargin: 0
                                spacing: 12

                                Label {
                                    visible: !contentArea.compactDetailMode
                                    text: newTaskVisible ? t("新建任务", "New Task") : (newCategoryVisible ? t("新建分类", "New Category") : (detailVisible ? t("任务详情", "Task Details") : (settingsVisible ? t("设置说明", "Settings") : t("等待选择", "Waiting for selection"))))
                                    font.pixelSize: detailFontSize
                                    font.bold: true
                                    color: detailTextColor
                                }

                                Item { Layout.fillWidth: true }

                                ToolButton {
                                    visible: false
                                    text: contentArea.compactDetailMode ? t("窗口过窄，已切到详情", "Window too narrow, detail only") : t("展开目录", "Open list")
                                    enabled: !contentArea.compactDetailMode
                                    onClicked: middleCollapsed = false
                                }

                                Item {
                                    visible: detailVisible && !settingsVisible
                                    implicitWidth: Math.min(rightPanel.width * 0.34, detailActionFlow.implicitWidth)
                                    implicitHeight: detailActionFlow.implicitHeight

                                    Flow {
                                        id: detailActionFlow
                                        anchors.right: parent.right
                                        width: parent.width
                                        spacing: 10
                                        layoutDirection: Qt.RightToLeft

                                        DetailPrimaryButton {
                                            text: t("保存", "Save")
                                            implicitWidth: 92
                                            onClicked: mainWindow.saveSelectedTaskEdits()
                                        }

                                        DetailActionButton {
                                            text: t("删除", "Delete")
                                            implicitWidth: 84
                                            onClicked: mainWindow.deleteSelectedTask()
                                        }
                                    }
                                }
                            }

                            Label {
                                visible: contentArea.compactDetailMode && detailVisible && !settingsVisible
                                anchors.centerIn: parent
                                text: newTaskVisible ? t("新建任务", "New Task") : (newCategoryVisible ? t("新建分类", "New Category") : (detailVisible ? t("任务详情", "Task Details") : (settingsVisible ? t("设置说明", "Settings") : t("等待选择", "Waiting for selection"))))
                                font.pixelSize: detailFontSize - 2
                                font.bold: false
                                color: homeDarkMode ? "#f8fafc" : "#111827"
                                x: contentArea.compactBackTitleOffset
                                z: 1

                                Behavior on x {
                                    NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 12
                            color: detailSurfaceColor
                            border.color: detailBorderColor
                            border.width: 1

                            ScrollView {
                                anchors.fill: parent
                                anchors.margins: 16
                                clip: true
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

                                ColumnLayout {
                                    width: availableWidth
                                    spacing: 12

                                Label {
                                    visible: !detailVisible && !newTaskVisible
                                    text: settingsVisible ? t("界面设置已展开到主区域，可以直接调整主题、背景图和字体大小。", "Settings are expanded in the main area. You can directly adjust theme, background, and font sizes.") : t("从中间列表选择一个任务后，右侧会在这里展示完整详情。你可以直接编辑标题、概要、分类与时间。", "Choose a task from the middle list and its full details will appear here. You can edit the title, summary, category, and time directly.")
                                    wrapMode: Text.WordWrap
                                    color: detailHintTextColor
                                    font.pixelSize: detailFontSize - 2
                                }

                                Item {
                                    visible: !detailVisible && !newTaskVisible
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        width: Math.min(parent.width * 0.74, 420)
                                        spacing: 16

                                        Rectangle {
                                            Layout.alignment: Qt.AlignHCenter
                                            width: 72
                                            height: 72
                                            radius: 24
                                            color: homeDarkMode ? "#334155" : "#eef4ff"
                                            border.color: homeDarkMode ? "#475569" : "#c7d2fe"
                                            border.width: 1

                                            Text {
                                                anchors.centerIn: parent
                                                text: "◫"
                                                color: homeDarkMode ? "#bfdbfe" : "#2563eb"
                                                font.pixelSize: 30
                                            }
                                        }

                                        Label {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: t("选择一个任务开始查看详情", "Select a task to view details")
                                            color: detailTextColor
                                            font.pixelSize: detailFontSize + 2
                                            font.bold: true
                                            horizontalAlignment: Text.AlignHCenter
                                        }

                                        Label {
                                            Layout.fillWidth: true
                                            text: t("中间列表会一直保留在左侧，你可以随时切换任务；右侧区域专门用于展示和编辑当前任务内容。", "The middle list stays visible so you can switch tasks anytime, while the right panel is dedicated to viewing and editing the current task.")
                                            color: detailHintTextColor
                                            font.pixelSize: Math.max(12, detailFontSize - 6)
                                            wrapMode: Text.WordWrap
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                    }
                                }

                                ColumnLayout {
                                    visible: detailVisible
                                    Layout.fillWidth: true
                                    spacing: 12

                                    DetailEditorField {
                                        Layout.fillWidth: true
                                        implicitHeight: 46
                                        text: editTaskTitle
                                        font.pixelSize: detailFontSize + 2
                                        font.bold: true
                                        placeholderText: "请输入任务标题"
                                        onTextChanged: editTaskTitle = text
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 8

                                        Rectangle {
                                            width: 12
                                            height: 12
                                            radius: 6
                                            color: selectedTaskCategoryColor
                                        }

                                        Label {
                                            text: selectedTaskCategoryName
                                            color: detailMutedTextColor
                                            font.pixelSize: Math.max(12, detailFontSize - 6)
                                        }

                                        Item { Layout.fillWidth: true }
                                    }
                                }

                                ColumnLayout {
                                    visible: detailVisible && (showDetailAuthor || showDetailCreatedDate || showDetailStartDate || showDetailDueDate)
                                    Layout.fillWidth: true
                                    spacing: 12

                                    DetailCard {
                                        visible: showDetailAuthor
                                        Layout.fillWidth: true
                                        implicitHeight: 68

                                        Label {
                                            id: authorLabel
                                            anchors.fill: parent
                                            anchors.margins: 12
                                            text: t("作者：", "Author: ") + selectedTaskAuthor
                                            color: detailHintTextColor
                                            wrapMode: Text.WordWrap
                                            verticalAlignment: Text.AlignVCenter
                                            font.pixelSize: Math.max(12, detailFontSize - 7)
                                        }
                                    }

                                    DetailCard {
                                        visible: showDetailCreatedDate
                                        Layout.fillWidth: true
                                        implicitHeight: 68

                                        Label {
                                            id: createdLabel
                                            anchors.fill: parent
                                            anchors.margins: 12
                                            text: t("创建日期：", "Created: ") + mainWindow.formatDisplayDateTime(selectedTaskCreatedAt)
                                            color: detailHintTextColor
                                            wrapMode: Text.WordWrap
                                            verticalAlignment: Text.AlignVCenter
                                            font.pixelSize: Math.max(12, detailFontSize - 7)
                                        }
                                    }

                                    DetailCard {
                                        visible: showDetailStartDate
                                        Layout.fillWidth: true
                                        implicitHeight: 68

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 12
                                            spacing: 10

                                            Label {
                                                text: t("开始时间", "Start time")
                                                color: detailHintTextColor
                                                font.pixelSize: Math.max(12, detailFontSize - 7)
                                                Layout.preferredWidth: 72
                                                Layout.alignment: Qt.AlignVCenter
                                            }

                                            DetailEditorField {
                                                Layout.fillWidth: true
                                                Layout.alignment: Qt.AlignVCenter
                                                text: editTaskStartDate === "" ? t("未设置", "Not set") : editTaskStartDate
                                                readOnly: true
                                            }

                                            DetailActionButton {
                                                text: t("选择", "Pick")
                                                implicitWidth: 64
                                                Layout.alignment: Qt.AlignVCenter
                                                onClicked: mainWindow.openDateTimeEditor("start")
                                            }

                                            DetailActionButton {
                                                visible: editTaskStartDate !== ""
                                                text: t("清空", "Clear")
                                                implicitWidth: 64
                                                Layout.alignment: Qt.AlignVCenter
                                                onClicked: editTaskStartDate = ""
                                            }
                                        }
                                    }

                                    DetailCard {
                                        visible: showDetailDueDate
                                        Layout.fillWidth: true
                                        implicitHeight: 68

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 12
                                            spacing: 10

                                            Label {
                                                text: t("结束时间", "Due time")
                                                color: detailHintTextColor
                                                font.pixelSize: Math.max(12, detailFontSize - 7)
                                                Layout.preferredWidth: 72
                                                Layout.alignment: Qt.AlignVCenter
                                            }

                                            DetailEditorField {
                                                Layout.fillWidth: true
                                                Layout.alignment: Qt.AlignVCenter
                                                text: editTaskDueDate === "" ? t("未设置", "Not set") : editTaskDueDate
                                                readOnly: true
                                            }

                                            DetailActionButton {
                                                text: t("选择", "Pick")
                                                implicitWidth: 64
                                                Layout.alignment: Qt.AlignVCenter
                                                onClicked: mainWindow.openDateTimeEditor("due")
                                            }

                                            DetailActionButton {
                                                visible: editTaskDueDate !== ""
                                                text: t("清空", "Clear")
                                                implicitWidth: 64
                                                Layout.alignment: Qt.AlignVCenter
                                                onClicked: editTaskDueDate = ""
                                            }
                                        }
                                    }
                                }

                                DetailCard {
                                    visible: detailVisible && showDetailPriority
                                    Layout.fillWidth: true
                                    implicitHeight: 68

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 10

                                        Label {
                                            text: t("优先级", "Priority")
                                            color: detailHintTextColor
                                            font.pixelSize: Math.max(12, detailFontSize - 7)
                                            Layout.preferredWidth: 72
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        DetailComboBox {
                                            id: detailPriorityCombo
                                            Layout.alignment: Qt.AlignVCenter
                                            model: ["低", "中", "高", "紧急"]
                                            currentIndex: Math.max(0, editTaskPriority - 1)
                                            implicitWidth: 156
                                            onActivated: editTaskPriority = currentIndex + 1
                                        }

                                        Item { Layout.fillWidth: true }
                                    }
                                }

                                DetailCard {
                                    visible: detailVisible
                                    Layout.fillWidth: true
                                    implicitHeight: 68

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 10

                                        Label {
                                            text: t("分类", "Category")
                                            color: detailHintTextColor
                                            font.pixelSize: Math.max(12, detailFontSize - 7)
                                            Layout.preferredWidth: 72
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        DetailComboBox {
                                            id: detailCategoryCombo
                                            Layout.alignment: Qt.AlignVCenter
                                            model: {
                                                const items = ["未分类"]
                                                for (let i = 0; i < categoryList.length; ++i) {
                                                    items.push(categoryList[i].name)
                                                }
                                                return items
                                            }
                                            implicitWidth: 180
                                            currentIndex: editTaskCategoryIndex
                                            onActivated: editTaskCategoryIndex = currentIndex
                                        }

                                        Item { Layout.fillWidth: true }
                                    }
                                }

                                DetailCard {
                                    visible: detailVisible
                                    Layout.fillWidth: true
                                    implicitHeight: 56
                                    color: homeDarkMode ? "#283445" : "#f4efe4"
                                    border.color: homeDarkMode ? "#4b6078" : "#e5d5b6"
                                    border.width: 1

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 14
                                        spacing: 10

                                        Rectangle {
                                            width: 3
                                            height: 26
                                            radius: 1.5
                                            color: detailAccentColor
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        Label {
                                            text: t("编辑区", "Editing")
                                            color: detailTextColor
                                            font.pixelSize: Math.max(12, detailFontSize - 6)
                                            font.bold: true
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        Label {
                                            Layout.fillWidth: true
                                            text: t("在这里调整概要、正文与当前状态。", "Use this section to edit the summary, body, and current task state.")
                                            color: detailHintTextColor
                                            font.pixelSize: Math.max(11, detailFontSize - 8)
                                            wrapMode: Text.WordWrap
                                            Layout.alignment: Qt.AlignVCenter
                                        }
                                    }
                                }

                                DetailCard {
                                    visible: detailVisible
                                    Layout.fillWidth: true
                                    implicitHeight: 152
                                    color: homeDarkMode ? "#323945" : "#fcfaf5"
                                    border.color: detailBorderColor
                                    border.width: 1

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 14
                                        spacing: 10

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 10

                                            Rectangle {
                                                width: 3
                                                height: 24
                                                radius: 1.5
                                                color: detailAccentColor
                                                Layout.alignment: Qt.AlignVCenter
                                            }

                                            Label {
                                                text: "概要"
                                                color: detailTextColor
                                                font.pixelSize: Math.max(13, detailFontSize - 5)
                                                font.bold: true
                                                Layout.alignment: Qt.AlignVCenter
                                            }

                                            Label {
                                                text: "支持修改摘要说明，正文为空时会自动复用概要"
                                                color: detailHintTextColor
                                                font.pixelSize: Math.max(11, detailFontSize - 8)
                                                Layout.alignment: Qt.AlignVCenter
                                            }
                                        }

                                        TextArea {
                                            id: detailOutlineText
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            wrapMode: TextEdit.Wrap
                                            text: editTaskOutline
                                            onTextChanged: editTaskOutline = text
                                            color: detailTextColor
                                            placeholderText: t("请输入概要说明", "Enter summary")
                                            selectedTextColor: detailOnAccentColor
                                            selectionColor: detailAccentColor
                                            topPadding: 14
                                            bottomPadding: 14
                                            leftPadding: 14
                                            rightPadding: 14
                                            background: Rectangle {
                                                color: homeDarkMode ? "#313b47" : "#fbfdff"
                                                radius: 12
                                                border.color: detailOutlineText.activeFocus
                                                              ? (homeDarkMode ? "#6d8299" : "#c9d9e8")
                                                              : detailBorderColor
                                                border.width: 1

                                                Rectangle {
                                                    anchors.fill: parent
                                                    radius: 12
                                                    color: detailAccentColor
                                                    opacity: detailOutlineText.activeFocus ? (homeDarkMode ? 0.045 : 0.028) : 0
                                                }
                                            }
                                        }
                                    }
                                }

                                DetailCard {
                                    visible: detailVisible
                                    Layout.fillWidth: true
                                    implicitHeight: 56
                                    color: homeDarkMode ? "#263240" : "#eef4fb"
                                    border.color: homeDarkMode ? "#44607e" : "#c9d9ee"
                                    border.width: 1

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 14
                                        spacing: 10

                                        Rectangle {
                                            width: 3
                                            height: 26
                                            radius: 1.5
                                            color: detailAccentColor
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        Label {
                                            text: t("附件区", "Attachments")
                                            color: detailTextColor
                                            font.pixelSize: Math.max(12, detailFontSize - 6)
                                            font.bold: true
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        Label {
                                            Layout.fillWidth: true
                                            text: t("下方区域用于选择、预览和管理附件内容。", "Use the section below to choose, preview, and manage attachments.")
                                            color: detailHintTextColor
                                            font.pixelSize: Math.max(11, detailFontSize - 8)
                                            wrapMode: Text.WordWrap
                                            Layout.alignment: Qt.AlignVCenter
                                        }
                                    }
                                }

                                Label {
                                    visible: false
                                    text: selectedTaskTime === "" ? "" : "时间标签：" + mainWindow.formatDisplayDateTime(selectedTaskTime)
                                    color: homeDarkMode ? "#64748b" : "#8b6b42"
                                    font.pixelSize: Math.max(12, detailFontSize - 7)
                                }

                                ColumnLayout {
                                    visible: detailVisible
                                    Layout.fillWidth: true
                                    spacing: 14

                                        ColumnLayout {
                                            width: parent.width
                                            spacing: 14

                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 12

                                                Label {
                                                    text: t("附件", "Attachment")
                                                    color: detailTextColor
                                                    font.pixelSize: Math.max(13, detailFontSize - 5)
                                                    font.bold: true
                                                }

                                                Label {
                                                    text: mainWindow.contentIsFile(editTaskContent) || mainWindow.contentIsImage(editTaskContent) ? t("已选择文件", "File selected") : t("可附加文件或图片", "Attach a file or image")
                                                    color: detailHintTextColor
                                                    font.pixelSize: Math.max(11, detailFontSize - 8)
                                                }

                                                Item { Layout.fillWidth: true }
                                            }

                                            Flow {
                                                width: parent.width
                                                spacing: 10

                                                DetailActionButton {
                                                    text: "选择附件文件"
                                                    implicitWidth: 116
                                                    onClicked: detailAttachmentDialog.open()
                                                }

                                                DetailActionButton {
                                                    text: "清空附件"
                                                    implicitWidth: 92
                                                    enabled: editTaskContent.trim() !== ""
                                                    onClicked: editTaskContent = ""
                                                }
                                            }

                                            Item {
                                                width: 1
                                                height: 4
                                            }

                                            DetailCard {
                                                id: detailAttachmentSummaryCard
                                                width: parent.width
                                                implicitHeight: editTaskContent.trim() === "" ? 72 : 52
                                                radius: 12
                                                color: editTaskContent.trim() === "" ? (detailAttachmentPressed
                                                         ? (homeDarkMode ? "#293443" : "#eef4fa")
                                                         : (detailAttachmentHoverArea.containsMouse
                                                            ? (homeDarkMode ? "#324050" : "#f2f7fc")
                                                            : (homeDarkMode ? "#2d3643" : "#f7f9fc"))) : (homeDarkMode ? "#313d4b" : "#f8fbff")
                                                border.color: editTaskContent.trim() === "" ? "transparent" : detailBorderColor
                                                border.width: 1

                                                HoverHandler {
                                                    id: detailAttachmentHoverArea
                                                }

                                                TapHandler {
                                                    id: detailAttachmentTapHandler
                                                    enabled: editTaskContent.trim() === ""
                                                    onTapped: detailAttachmentDialog.open()
                                                }

                                                property bool detailAttachmentPressed: detailAttachmentTapHandler.pressed && editTaskContent.trim() === ""

                                                Behavior on color {
                                                    ColorAnimation { duration: 120 }
                                                }

                                                Rectangle {
                                                    anchors.fill: parent
                                                    radius: 12
                                                    visible: editTaskContent.trim() === "" && detailAttachmentHoverArea.containsMouse
                                                    color: homeDarkMode ? "#9ec5ff" : "#2563eb"
                                                    opacity: detailAttachmentPressed ? (homeDarkMode ? 0.03 : 0.022) : (homeDarkMode ? 0.045 : 0.032)

                                                    Behavior on opacity {
                                                        NumberAnimation { duration: 120 }
                                                    }
                                                }

                                                Rectangle {
                                                    anchors.fill: parent
                                                    radius: 12
                                                    color: "transparent"
                                                    visible: editTaskContent.trim() === ""
                                                    border.color: detailAttachmentPressed
                                                                  ? (homeDarkMode ? "#73869a" : "#bfcedc")
                                                                  : (detailAttachmentHoverArea.containsMouse
                                                                     ? (homeDarkMode ? "#7a8ca0" : "#c8d6e2")
                                                                     : (homeDarkMode ? "#63758a" : "#d3dde8"))
                                                    border.width: 1
                                                    opacity: detailAttachmentHoverArea.containsMouse ? 0.95 : 1

                                                    Behavior on border.color {
                                                        ColorAnimation { duration: 120 }
                                                    }
                                                }

                                                Canvas {
                                                    anchors.fill: parent
                                                    anchors.margins: 1
                                                    visible: editTaskContent.trim() === ""

                                                    Connections {
                                                        target: detailAttachmentHoverArea

                                                        function onContainsMouseChanged() {
                                                            parent.requestPaint()
                                                        }
                                                    }

                                                    onPaint: {
                                                        const ctx = getContext("2d")
                                                        ctx.reset()
                                                        ctx.strokeStyle = detailAttachmentPressed
                                                                ? (homeDarkMode ? "#8598ab" : "#c7d4df")
                                                                : (detailAttachmentHoverArea.containsMouse
                                                                   ? (homeDarkMode ? "#7f91a5" : "#cedae5")
                                                                   : (homeDarkMode ? "#6b7c90" : "#d7e0ea"))
                                                        ctx.globalAlpha = detailAttachmentPressed
                                                                ? (homeDarkMode ? 0.58 : 0.84)
                                                                : (detailAttachmentHoverArea.containsMouse
                                                                   ? (homeDarkMode ? 0.72 : 0.92)
                                                                   : (homeDarkMode ? 0.6 : 0.85))
                                                        ctx.lineWidth = 1
                                                        if (ctx.setLineDash) {
                                                            ctx.setLineDash([4, 4])
                                                        }
                                                        const r = 11
                                                        ctx.beginPath()
                                                        ctx.moveTo(r, 0)
                                                        ctx.lineTo(width - r, 0)
                                                        ctx.quadraticCurveTo(width, 0, width, r)
                                                        ctx.lineTo(width, height - r)
                                                        ctx.quadraticCurveTo(width, height, width - r, height)
                                                        ctx.lineTo(r, height)
                                                        ctx.quadraticCurveTo(0, height, 0, height - r)
                                                        ctx.lineTo(0, r)
                                                        ctx.quadraticCurveTo(0, 0, r, 0)
                                                        ctx.stroke()
                                                    }
                                                }

                                                RowLayout {
                                                    anchors.fill: parent
                                                    anchors.leftMargin: 16
                                                    anchors.rightMargin: 16
                                                    spacing: 12

                                                    Rectangle {
                                                        width: editTaskContent.trim() === "" ? 24 : 8
                                                        height: editTaskContent.trim() === "" ? 24 : 8
                                                        radius: editTaskContent.trim() === "" ? 8 : 4
                                                        color: "transparent"
                                                        border.color: editTaskContent.trim() === "" ? (homeDarkMode ? "#708397" : "#cbd8e4") : "transparent"
                                                        border.width: editTaskContent.trim() === "" ? 1 : 0
                                                        opacity: editTaskContent.trim() === "" ? (homeDarkMode ? 0.78 : 0.9) : 1
                                                        Layout.alignment: Qt.AlignVCenter

                                                        Canvas {
                                                            anchors.centerIn: parent
                                                            width: 10
                                                            height: 10
                                                            visible: editTaskContent.trim() === ""

                                                            onPaint: {
                                                                const ctx = getContext("2d")
                                                                ctx.reset()
                                                                ctx.strokeStyle = homeDarkMode ? "#93a4b8" : "#94a3b8"
                                                                ctx.globalAlpha = homeDarkMode ? 0.78 : 0.9
                                                                ctx.lineWidth = 1
                                                                ctx.beginPath()
                                                                ctx.moveTo(width / 2, 1)
                                                                ctx.lineTo(width / 2, height - 1)
                                                                ctx.moveTo(1, height / 2)
                                                                ctx.lineTo(width - 1, height / 2)
                                                                ctx.stroke()
                                                            }
                                                        }
                                                    }

                                                    Label {
                                                        Layout.fillWidth: true
                                                        verticalAlignment: Text.AlignVCenter
                                                        elide: Text.ElideMiddle
                                                        color: editTaskContent.trim() === "" ? detailMutedTextColor : detailHintTextColor
                                                        text: editTaskContent.trim() === "" ? t("未选择附件，可添加文件或图片", "No attachment selected. Add a file or image") : mainWindow.selectedFileName(editTaskContent)
                                                    }
                                                }
                                            }
                                        }

                                        DetailCard {
                                            width: parent.width
                                            radius: 12
                                            color: editTaskCompleted ? (homeDarkMode ? "#173a2d" : "#edf9f1") : (homeDarkMode ? "#423225" : "#fff6ea")
                                            border.color: editTaskCompleted ? (homeDarkMode ? "#3fbf89" : "#9adbb8") : (homeDarkMode ? "#f2a365" : "#f6c48a")
                                            visible: detailVisible

                                            ColumnLayout {
                                                anchors.fill: parent
                                                anchors.margins: 14
                                                spacing: 10

                                                RowLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 12

                                                    Rectangle {
                                                        width: 22
                                                        height: 22
                                                        radius: 11
                                                        color: editTaskCompleted ? (homeDarkMode ? "#1f5a42" : "#dcfce7") : (homeDarkMode ? "#5a4026" : "#ffedd5")
                                                        border.color: editTaskCompleted ? (homeDarkMode ? "#4ade80" : "#86efac") : (homeDarkMode ? "#fdba74" : "#fdba74")
                                                        border.width: 1
                                                        Layout.alignment: Qt.AlignVCenter

                                                        Text {
                                                            anchors.centerIn: parent
                                                            text: editTaskCompleted ? "✓" : "·"
                                                            color: editTaskCompleted ? (homeDarkMode ? "#bbf7d0" : "#15803d") : (homeDarkMode ? "#fed7aa" : "#c2410c")
                                                            font.pixelSize: editTaskCompleted ? 12 : 18
                                                            font.bold: editTaskCompleted
                                                        }
                                                    }

                                                    Label {
                                                        text: editTaskCompleted ? t("当前状态：已完成", "Status: Completed") : t("当前状态：未完成", "Status: Incomplete")
                                                        color: editTaskCompleted ? (homeDarkMode ? "#bbf7d0" : "#166534") : (homeDarkMode ? "#fed7aa" : "#9a3412")
                                                        font.pixelSize: Math.max(12, detailFontSize - 6)
                                                        font.bold: true
                                                    }

                                                    Item { Layout.fillWidth: true }
                                                }

                                                Label {
                                                    Layout.fillWidth: true
                                                    text: editTaskCompleted ? t("任务已完成，可随时切回未完成状态。", "This task is completed. You can switch it back anytime.") : t("任务仍在进行中，完成后可切换状态。", "This task is still in progress. Mark it complete when finished.")
                                                    color: detailHintTextColor
                                                    wrapMode: Text.WordWrap
                                                    font.pixelSize: Math.max(11, detailFontSize - 8)
                                                    bottomPadding: 6
                                                }

                                                Item {
                                                    Layout.fillWidth: true
                                                    implicitHeight: 6
                                                }

                                                RowLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 10

                                                    Item { Layout.fillWidth: true }

                                                    DetailPrimaryButton {
                                                        text: editTaskCompleted ? t("设为未完成", "Mark incomplete") : t("设为完成", "Mark complete")
                                                        implicitWidth: 126
                                                        onClicked: editTaskCompleted = !editTaskCompleted
                                                    }
                                                }
                                            }
                                        }

                                        TextArea {
                                            id: detailTextContent
                                            width: parent.width
                                            Layout.minimumHeight: 156
                                            wrapMode: TextEdit.Wrap
                                            visible: !mainWindow.contentIsImage(editTaskContent) && !mainWindow.contentIsFile(editTaskContent)
                                            text: editTaskContent
                                            onTextChanged: editTaskContent = text
                                            color: detailTextColor
                                            selectedTextColor: detailOnAccentColor
                                            selectionColor: detailAccentColor
                                            placeholderText: t("请输入正文或附件路径", "Enter content or attachment path")
                                            topPadding: 14
                                            bottomPadding: 14
                                            leftPadding: 14
                                            rightPadding: 14
                                            background: Rectangle {
                                                color: homeDarkMode ? "#313b47" : "#fbfdff"
                                                radius: 12
                                                border.color: detailTextContent.activeFocus
                                                              ? (homeDarkMode ? "#6d8299" : "#c9d9e8")
                                                              : detailBorderColor
                                                border.width: 1

                                                Rectangle {
                                                    anchors.fill: parent
                                                    radius: 12
                                                    color: detailAccentColor
                                                    opacity: detailTextContent.activeFocus ? (homeDarkMode ? 0.045 : 0.028) : 0
                                                }
                                            }
                                        }

                                        DetailCard {
                                            width: parent.width
                                            height: detailImage.status === Image.Ready ? Math.min(416, Math.max(192, detailImage.paintedHeight)) : 224
                                            visible: mainWindow.contentIsImage(editTaskContent)

                                            Image {
                                                id: detailImage
                                                anchors.fill: parent
                                                anchors.margins: 12
                                                source: parent.visible ? editTaskContent : ""
                                                fillMode: Image.PreserveAspectFit
                                                asynchronous: true
                                                cache: false
                                            }
                                        }

                                        DetailCard {
                                            width: parent.width
                                            visible: mainWindow.contentIsFile(editTaskContent)

                                            ColumnLayout {
                                                anchors.fill: parent
                                                anchors.margins: 16
                                                spacing: 12

                                                RowLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 12

                                                    Label {
                                                        text: "文件内容"
                                                        color: detailTextColor
                                                        font.pixelSize: Math.max(13, detailFontSize - 5)
                                                        font.bold: true
                                                    }

                                                    Item { Layout.fillWidth: true }

                                                    DetailActionButton {
                                                        text: "打开文件"
                                                        implicitWidth: 88
                                                        onClicked: {
                                                            const filePath = editTaskContent
                                                            Qt.openUrlExternally(filePath.startsWith("file:/") ? filePath : "file:///" + filePath.replace(/\\/g, "/"))
                                                        }
                                                    }
                                                }

                                                Label {
                                                    Layout.fillWidth: true
                                                    text: editTaskContent
                                                    wrapMode: Text.WordWrap
                                                    color: detailMutedTextColor
                                                    font.pixelSize: Math.max(12, detailFontSize - 7)
                                                }
                                            }
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
                    homeDarkMode: mainWindow.homeDarkMode
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
                    ganttBlueTaskBars: mainWindow.ganttBlueTaskBars
                    ganttBlueTodayColumn: mainWindow.ganttBlueTodayColumn
                    ganttBlueGridLines: mainWindow.ganttBlueGridLines
                    onHomeDarkModeChanged: {
                        mainWindow.homeDarkMode = homeDarkMode
                        mainWindow.persistUserSettings()
                    }
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
                    onGanttBlueTaskBarsChanged: {
                        mainWindow.ganttBlueTaskBars = ganttBlueTaskBars
                        mainWindow.persistUserSettings()
                    }
                    onGanttBlueTodayColumnChanged: {
                        mainWindow.ganttBlueTodayColumn = ganttBlueTodayColumn
                        mainWindow.persistUserSettings()
                    }
                    onGanttBlueGridLinesChanged: {
                        mainWindow.ganttBlueGridLines = ganttBlueGridLines
                        mainWindow.persistUserSettings()
                    }
                    onLogoutRequested: AuthManager.logout()
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

                    onCreateCategoryRequested: (name, color) => {
                        if (AuthManager.isLoggedIn) {
                            const categoryId = DatabaseManager.createCategory(AuthManager.currentUserId, name, color, "")
                            if (categoryId > 0) {
                                loadCategories()
                                newCategoryDialog.resetForm()
                            }
                        }
                    }
                }

                GanttChart {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
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
                                    task.categoryColor
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
