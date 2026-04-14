import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import AbstractContentsModel 1.0
import DatabaseManager 1.0

Item {
    id: root
    property string searchKeyword: ""
    property int selectedCategoryId: -1
    property bool completionAnimating: false
    property int pendingCompletedTaskId: -1
    signal itemSelected(int taskId, string title, string outline, string content, string time, string startDate, string author, string createdAt, string dueDate, int priority, int categoryId, string categoryName, string categoryColor, bool completed)

    function openTaskById(taskId) {
        for (let i = 0; i < AbstractContentsModel.rowCount(); ++i) {
            const task = AbstractContentsModel.get(i)
            if (task.index_num === taskId) {
                root.itemSelected(
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

    function saveTaskOutline(taskId, newOutline) {
        if (taskId < 0) {
            return
        }

        const ok = DatabaseManager.updateTask(taskId, {
            "description": newOutline
        })

        if (ok) {
            mainWindow.refreshCurrentView()
            AbstractContentsModel.loadAllFromDatabase(mainWindow.databasePath, mainWindow.currentPageType === mainWindow.pageToday, mainWindow.currentPageType === mainWindow.pageCompleted)
            if (mainWindow.selectedTaskId === taskId) {
                mainWindow.selectedTaskOutline = newOutline
                mainWindow.selectedTaskContent = newOutline
                mainWindow.refreshCurrentView()
                openTaskById(taskId)
            }
        }
    }

    function markTaskForToday(taskId) {
        if (taskId < 0) {
            return
        }

        const ok = DatabaseManager.markTaskForToday(taskId)
        if (ok) {
            mainWindow.showTodayTasks()
            openTaskById(taskId)
        }
    }

    function finishTaskCompletion(taskId, completed) {
        const ok = DatabaseManager.updateTask(taskId, {
            "completed": completed
        })
        if (!ok) {
            completionAnimating = false
            pendingCompletedTaskId = -1
            return
        }

        mainWindow.refreshCurrentView()
        AbstractContentsModel.loadAllFromDatabase(mainWindow.databasePath, mainWindow.currentPageType === mainWindow.pageToday, mainWindow.currentPageType === mainWindow.pageCompleted)
        completionAnimating = false
        pendingCompletedTaskId = -1

        if (!completed) {
            openTaskById(taskId)
        }
    }

    function toggleTaskCompleted(taskId, completed) {
        if (taskId < 0) {
            return
        }

        if (completed && mainWindow.currentPageType === mainWindow.pageToday) {
            pendingCompletedTaskId = taskId
            completionAnimating = true
            return
        }

        finishTaskCompletion(taskId, completed)
    }

    Rectangle {
        anchors.fill: parent
        color: mainWindow.homeDarkMode ? "#343943" : "#f4f1e8"
    }

    ListView {
        id: listView
        anchors.fill: parent
        anchors.margins: 0
        visible: true
        spacing: 8
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        model: AbstractContentsModel
        delegate: ContensElement {
            property bool matchesSearch: {
                const keyword = root.searchKeyword.trim().toLowerCase()
                if (keyword === "") {
                    return true
                }

                const taskTitle = (model.title || "").toLowerCase()
                const taskOutline = (model.outline || "").toLowerCase()
                const taskCategory = (model.categoryName || "").toLowerCase()
                return taskTitle.indexOf(keyword) !== -1 || taskOutline.indexOf(keyword) !== -1 || taskCategory.indexOf(keyword) !== -1
            }
            property bool matchesCategory: root.selectedCategoryId < 0 || (model.categoryId || 0) === root.selectedCategoryId
            property bool isPendingComplete: root.completionAnimating && root.pendingCompletedTaskId === model.index_num
            property bool shouldShow: matchesSearch && matchesCategory && !isPendingComplete

            width: ListView.view.width
            height: (shouldShow || isPendingComplete) ? 112 : 0
            visible: shouldShow || isPendingComplete
            enabled: shouldShow
            opacity: isPendingComplete ? 0 : 1

            Behavior on opacity {
                NumberAnimation { duration: 220; easing.type: Easing.InOutQuad }
            }

            Behavior on height {
                NumberAnimation { duration: 220; easing.type: Easing.InOutQuad }
            }

            taskId: model.index_num
            title: model.title
            outline: model.outline
            time: model.time
            displayTime: mainWindow.formatDisplayDateTime(model.time)
            dueDate: model.dueDate
            fontScale: mainWindow.middleCardFontSize
            categoryName: model.categoryName
            categoryColor: model.categoryColor
            todaySelected: mainWindow.currentPageType === mainWindow.pageToday

            onDetailedRequested: {
                root.itemSelected(
                    model.index_num,
                    model.title,
                    model.outline,
                    model.content,
                    model.time,
                    model.startDate,
                    model.author,
                    model.created_at,
                    model.dueDate,
                    model.priority,
                    model.categoryId,
                    model.categoryName,
                    model.categoryColor,
                    model.completed
                )
            }

            onOutlineEdited: (newOutline) => {
                root.saveTaskOutline(model.index_num, newOutline)
            }

            onMarkTodayRequested: {
                root.markTaskForToday(model.index_num)
            }

            onCompletedToggled: (completed) => {
                root.toggleTaskCompleted(model.index_num, completed)
            }

            onOpacityChanged: {
                if (isPendingComplete && opacity === 0) {
                    root.finishTaskCompletion(model.index_num, true)
                }
            }
        }
    }
}
