from pathlib import Path

path = Path(r'd:\Data\Code\cpp\todo-project-enhanced\everyday_day\DetailEditingSection.qml')
text = path.read_text(encoding='utf-8')

text = text.replace(
'''    function checklistContentFromItems(items) {
        const lines = []
        for (let i = 0; i < items.length; ++i) {
            const text = (items[i].text || "").trim()
            if (text !== "") lines.push((items[i].completed ? "[x] " : "[ ] ") + text)
        }
        return lines.join("\n")
    }
''',
'''    function checklistContentFromItems(items, keepEmptyIndex) {
        const lines = []
        for (let i = 0; i < items.length; ++i) {
            const text = (items[i].text || "").trim()
            if (text !== "" || i === keepEmptyIndex) {
                lines.push((items[i].completed ? "[x] " : "[ ] ") + text)
            }
        }
        return lines.join("\n")
    }
''',
1)

text = text.replace(
'''    function appendChecklistItem() {
        const source = ((editTaskContent || "") + "").replace(/\r/g, "")
        pendingFocusIndex = checklistItemsFromContent(editTaskContent).length
        contentEdited(source === "" ? "[ ] " : source + "\n[ ] ")
    }
''',
'''    function appendChecklistItem() {
        const items = checklistItemsFromContent(editTaskContent)
        pendingFocusIndex = items.length
        items.push({ completed: false, text: "" })
        contentEdited(checklistContentFromItems(items, pendingFocusIndex))
    }
    function createChecklistItemAfter(index, value) {
        const items = checklistItemsFromContent(editTaskContent)
        if (index < 0 || index >= items.length) return
        items[index].text = value
        pendingFocusIndex = index + 1
        items.splice(index + 1, 0, { completed: false, text: "" })
        contentEdited(checklistContentFromItems(items, pendingFocusIndex))
    }
''',
1)

text = text.replace(
'''                                onEditingFinished: root.updateChecklistItemText(index, text)
''',
'''                                onAccepted: root.createChecklistItemAfter(index, text)
                                onEditingFinished: root.updateChecklistItemText(index, text)
''',
1)

path.write_text(text, encoding='utf-8')
print('updated')
