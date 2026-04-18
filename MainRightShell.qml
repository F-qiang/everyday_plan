import QtQuick 2.15

Rectangle {
    id: root

    property color pageBaseColor: "#ffffff"
    property bool homeDarkMode: false
    property string backgroundImageSource: ""

    visible: true
    color: pageBaseColor
    clip: true
    default property alias shellContent: contentHost.data

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

    Item {
        id: contentHost
        anchors.fill: parent
        z: 4
    }
}
