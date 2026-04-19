// 登录界面 - 支持邮箱验证码登录
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs
import QtQuick.Effects

import AuthManager 1.0

Window {
    id: loginWindow
    visible: true
    width: 400
    height: 500
    title: qsTr("Everyday Plan - 登录")
    color: "#f5f5f5"
    flags: Qt.Window
    
    // 登录成功信号
    signal loginSuccessful()
    
    // 连接认证管理器信号
    Connections {
        target: AuthManager
        
        function onVerificationCodeSent(success, message) {
            if (success) {
                statusText.text = message
                statusText.color = "#27ae60"
                countdownTimer.start()
                codeSentAnimation.start()
            } else {
                statusText.text = message
                statusText.color = "#e74c3c"
            }
        }
        
        function onLoginResult(success, message) {
            if (success) {
                statusText.text = "登录成功！"
                statusText.color = "#27ae60"
                loginSuccessAnimation.start()
            } else {
                statusText.text = message
                statusText.color = "#e74c3c"
                loginButton.enabled = true
            }
        }
    }
    
    // 主容器
    Rectangle {
        anchors.fill: parent
        color: "#ffffff"
        
        ColumnLayout {
            anchors.centerIn: parent
            width: parent.width - 60
            spacing: 20
            
            // Logo 和标题
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 10
                
                // Logo 图标
                Image {
                    width: 80
                    height: 80
                    source: "qrc:/qt/qml/everyday_plan/assets/ep_app_icon.svg"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    sourceSize.width: 160
                    sourceSize.height: 160
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Text {
                    text: "Everyday Plan"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#2c3e50"
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Text {
                    text: "邮箱验证码登录"
                    font.pixelSize: 14
                    color: "#7f8c8d"
                    Layout.alignment: Qt.AlignHCenter
                }
            }
            
            // 邮箱输入
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Text {
                    text: "邮箱地址"
                    font.pixelSize: 14
                    color: "#34495e"
                }
                
                TextField {
                    id: emailInput
                    Layout.fillWidth: true
                    placeholderText: "请输入您的邮箱"
                    font.pixelSize: 16
                    
                    background: Rectangle {
                        color: "#f8f9fa"
                        border.color: emailInput.activeFocus ? "#3498db" : "#dee2e6"
                        border.width: emailInput.activeFocus ? 2 : 1
                        radius: 8
                    }
                    
                    // 邮箱格式验证
                    onTextChanged: {
                        var emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
                        emailValidIndicator.visible = text.length > 0
                        emailValidIndicator.valid = emailRegex.test(text)
                    }
                }
                
                // 邮箱格式指示器
                RowLayout {
                    id: emailValidIndicator
                    visible: false
                    property bool valid: false
                    spacing: 4
                    
                    Text {
                        text: emailValidIndicator.valid ? "✓" : "✗"
                        color: emailValidIndicator.valid ? "#27ae60" : "#e74c3c"
                        font.pixelSize: 12
                    }
                    
                    Text {
                        text: emailValidIndicator.valid ? "邮箱格式正确" : "请输入正确的邮箱格式"
                        color: emailValidIndicator.valid ? "#27ae60" : "#e74c3c"
                        font.pixelSize: 12
                    }
                }
            }
            
            // 验证码输入
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    
                    Text {
                        text: "验证码"
                        font.pixelSize: 14
                        color: "#34495e"
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Text {
                        id: countdownText
                        visible: false
                        text: ""
                        font.pixelSize: 12
                        color: "#7f8c8d"
                    }
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    TextField {
                        id: codeInput
                        Layout.fillWidth: true
                        placeholderText: "请输入6位验证码"
                        font.pixelSize: 16
                        maximumLength: 6
                        validator: RegularExpressionValidator { regularExpression: /[0-9]{6}/ }
                        
                        background: Rectangle {
                            color: "#f8f9fa"
                            border.color: codeInput.activeFocus ? "#3498db" : "#dee2e6"
                            border.width: codeInput.activeFocus ? 2 : 1
                            radius: 8
                        }
                    }
                    
                    Button {
                        id: sendCodeButton
                        text: "获取验证码"
                        enabled: emailValidIndicator.valid && !countdownTimer.running
                        
                        background: Rectangle {
                            color: sendCodeButton.enabled ? 
                                   (sendCodeButton.pressed ? "#2980b9" : "#3498db") : "#bdc3c7"
                            radius: 8
                        }
                        
                        contentItem: Text {
                            text: sendCodeButton.text
                            font.pixelSize: 14
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onClicked: {
                            AuthManager.requestVerificationCode(emailInput.text)
                        }
                    }
                }
            }
            
            // 登录按钮
            Button {
                id: loginButton
                text: "登录"
                Layout.fillWidth: true
                Layout.topMargin: 10
                enabled: emailValidIndicator.valid && codeInput.length === 6
                
                background: Rectangle {
                    color: loginButton.enabled ? 
                           (loginButton.pressed ? "#27ae60" : "#2ecc71") : "#bdc3c7"
                    radius: 8
                    implicitHeight: 48
                }
                
                contentItem: Text {
                    text: loginButton.text
                    font.pixelSize: 16
                    font.bold: true
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    loginButton.enabled = false
                    AuthManager.loginWithCode(emailInput.text, codeInput.text)
                }
            }
            
            // 状态提示
            Text {
                id: statusText
                Layout.alignment: Qt.AlignHCenter
                text: ""
                font.pixelSize: 14
                color: "#7f8c8d"
            }
            
            // 底部提示
            Text {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 20
                text: "首次登录将自动创建账号"
                font.pixelSize: 12
                color: "#95a5a6"
            }
        }
    }
    
    // 倒计时计时器
    Timer {
        id: countdownTimer
        interval: 1000
        repeat: true
        property int remaining: 60
        
        onTriggered: {
            remaining--
            if (remaining <= 0) {
                stop()
                remaining = 60
                countdownText.visible = false
                sendCodeButton.text = "重新获取"
            } else {
                countdownText.text = remaining + "秒后可重新获取"
            }
        }
        
        function start() {
            remaining = 60
            countdownText.visible = true
            countdownText.text = remaining + "秒后可重新获取"
            sendCodeButton.text = "已发送"
            restart()
        }
    }
    
    // 动画效果
    SequentialAnimation {
        id: codeSentAnimation
        NumberAnimation { target: sendCodeButton; property: "scale"; to: 0.95; duration: 100 }
        NumberAnimation { target: sendCodeButton; property: "scale"; to: 1.0; duration: 100 }
    }
    
    SequentialAnimation {
        id: loginSuccessAnimation
        NumberAnimation { target: loginButton; property: "scale"; to: 0.95; duration: 100 }
        NumberAnimation { target: loginButton; property: "scale"; to: 1.0; duration: 100 }
        ScriptAction { script: loginWindow.loginSuccessful() }
    }
}
