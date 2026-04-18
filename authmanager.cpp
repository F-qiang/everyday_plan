#include "authmanager.h"
#include "databasemanager.h"
#include <QRandomGenerator>
#include <QDebug>
#include <QSettings>
#include <QRegularExpression>
#include <QTcpSocket>
#include <QSslSocket>
#include <QTextStream>
#include <QByteArray>

// 如果需要发送邮件，可以引入以下头文件
// #include <QSmtpClient> 或使用第三方库

AuthManager* AuthManager::m_instance = nullptr;

AuthManager::AuthManager(QObject *parent)
    : QObject(parent)
    , m_currentUserId(-1)
    , m_isLoggedIn(false)
{
    // 尝试从本地存储恢复登录状态
    QSettings settings("EverydayPlan", "Auth");
    m_currentUserId = settings.value("currentUserId", -1).toInt();
    
    if (m_currentUserId > 0) {
        // 验证用户是否仍然存在
        QVariantMap userInfo = DatabaseManager::instance()->getUserInfo(m_currentUserId);
        if (!userInfo.isEmpty()) {
            m_currentEmail = userInfo["email"].toString();
            m_currentNickname = userInfo["nickname"].toString();
            m_isLoggedIn = true;
            emit loginStateChanged();
        }
    }
}

AuthManager::~AuthManager()
{
}

void AuthManager::setMailError(const QString &message)
{
    m_lastMailError = message;
    qDebug() << "[AuthManager]" << message;
}

AuthManager* AuthManager::instance()
{
    if (!m_instance) {
        m_instance = new AuthManager();
    }
    return m_instance;
}

bool AuthManager::isLoggedIn() const
{
    return m_isLoggedIn;
}

int AuthManager::currentUserId() const
{
    return m_currentUserId;
}

QString AuthManager::currentUserEmail() const
{
    return m_currentEmail;
}

QString AuthManager::currentUserNickname() const
{
    return m_currentNickname;
}

QString AuthManager::generateVerificationCode()
{
    // 生成6位数字验证码
    QString code;
    for (int i = 0; i < 6; ++i) {
        code.append(QString::number(QRandomGenerator::global()->bounded(10)));
    }
    return code;
}

void AuthManager::requestVerificationCode(const QString &email)
{
    QRegularExpression emailRegex(R"(^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$)");
    if (!emailRegex.match(email).hasMatch()) {
        emit verificationCodeSent(false, "邮箱格式不正确");
        return;
    }

    int remainingSeconds = 0;
    if (!DatabaseManager::instance()->canRequestVerificationCode(email, 60, &remainingSeconds)) {
        emit verificationCodeSent(false, QString("请求过于频繁，请 %1 秒后再试").arg(remainingSeconds));
        return;
    }

    QString code = generateVerificationCode();

    if (!DatabaseManager::instance()->saveVerificationCode(email, code)) {
        emit verificationCodeSent(false, "验证码保存失败，请重试");
        return;
    }

    QString subject = "Everyday Plan - 您的登录验证码";
    QString body = QString(R"(
        <html>
        <body style="font-family: Arial, sans-serif;">
            <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
                <h2 style="color: #3498db;">Everyday Plan</h2>
                <p>您好！</p>
                <p>您正在使用邮箱登录 Everyday Plan，您的验证码是：</p>
                <div style="background-color: #f5f5f5; padding: 15px; text-align: center; font-size: 24px; font-weight: bold; letter-spacing: 5px; margin: 20px 0;">
                    %1
                </div>
                <p style="color: #666;">验证码有效期为 5 分钟，请尽快使用。</p>
                <p style="color: #999; font-size: 12px;">如果您没有请求此验证码，请忽略此邮件。</p>
            </div>
        </body>
        </html>
    )").arg(code);

    if (sendEmail(email, subject, body)) {
        emit verificationCodeSent(true, "验证码已发送，请查收邮件");
    } else {
        emit verificationCodeSent(false, m_lastMailError.isEmpty() ? "验证码发送失败，请检查邮箱配置" : m_lastMailError);
    }
}

bool AuthManager::sendSmtpCommand(QTcpSocket *socket, const QByteArray &command, const QList<int> &expectedCodes, QByteArray *response)
{
    if (!command.isEmpty()) {
        if (socket->write(command) == -1 || !socket->waitForBytesWritten(5000)) {
            setMailError(QString("SMTP 写入失败：%1").arg(socket->errorString()));
            return false;
        }
    }

    if (!socket->waitForReadyRead(5000)) {
        setMailError(QString("SMTP 无响应：%1").arg(socket->errorString()));
        return false;
    }

    QByteArray data;
    do {
        data += socket->readAll();
    } while (socket->waitForReadyRead(150));

    if (response) {
        *response = data;
    }

    const QList<QByteArray> lines = data.split('\n');
    int code = -1;
    for (const QByteArray &rawLine : lines) {
        const QByteArray line = rawLine.trimmed();
        if (line.size() >= 3) {
            bool ok = false;
            const int parsed = line.left(3).toInt(&ok);
            if (ok) {
                code = parsed;
            }
        }
    }

    if (code < 0 || !expectedCodes.contains(code)) {
        setMailError(QString("SMTP 返回异常：%1").arg(QString::fromUtf8(data).trimmed()));
        return false;
    }

    return true;
}

bool AuthManager::sendSmtpCommand(QSslSocket *socket, const QByteArray &command, const QList<int> &expectedCodes, QByteArray *response)
{
    if (!command.isEmpty()) {
        if (socket->write(command) == -1 || !socket->waitForBytesWritten(5000)) {
            setMailError(QString("SMTPS 写入失败：%1").arg(socket->errorString()));
            return false;
        }
    }

    if (!socket->waitForReadyRead(5000)) {
        setMailError(QString("SMTPS 无响应：%1").arg(socket->errorString()));
        return false;
    }

    QByteArray data;
    do {
        data += socket->readAll();
    } while (socket->waitForReadyRead(150));

    if (response) {
        *response = data;
    }

    const QList<QByteArray> lines = data.split('\n');
    int code = -1;
    for (const QByteArray &rawLine : lines) {
        const QByteArray line = rawLine.trimmed();
        if (line.size() >= 3) {
            bool ok = false;
            const int parsed = line.left(3).toInt(&ok);
            if (ok) {
                code = parsed;
            }
        }
    }

    if (code < 0 || !expectedCodes.contains(code)) {
        setMailError(QString("SMTPS 返回异常：%1").arg(QString::fromUtf8(data).trimmed()));
        return false;
    }

    return true;
}

bool AuthManager::sendEmail(const QString &to, const QString &subject, const QString &body)
{
    m_lastMailError.clear();

    QSettings settings("EverydayPlan", "Mail");
    const QString host = settings.value("smtpHost").toString();
    const int port = settings.value("smtpPort", 465).toInt();
    const QString username = settings.value("smtpUsername").toString();
    const QString password = settings.value("smtpPassword").toString();
    const QString from = settings.value("smtpFrom", username).toString();
    const bool useSsl = settings.value("smtpUseSsl", true).toBool();

    if (host.isEmpty() || username.isEmpty() || password.isEmpty() || from.isEmpty()) {
        setMailError("缺少 SMTP 配置，请检查 smtpHost、smtpPort、smtpUsername、smtpPassword、smtpFrom");
        return false;
    }

    const QByteArray authUser = username.toUtf8().toBase64();
    const QByteArray authPass = password.toUtf8().toBase64();
    const QByteArray message = QString(
        "From: Everyday Plan <%1>\r\n"
        "To: <%2>\r\n"
        "Subject: %3\r\n"
        "MIME-Version: 1.0\r\n"
        "Content-Type: text/html; charset=UTF-8\r\n"
        "Content-Transfer-Encoding: 8bit\r\n"
        "\r\n"
        "%4\r\n")
        .arg(from, to, subject, body)
        .toUtf8();

    if (useSsl) {
        QSslSocket socket;
        socket.connectToHostEncrypted(host, quint16(port));
        if (!socket.waitForEncrypted(10000)) {
            setMailError(QString("SMTPS 连接失败：%1").arg(socket.errorString()));
            return false;
        }

        if (!sendSmtpCommand(&socket, QByteArray(), {220})) return false;
        if (!sendSmtpCommand(&socket, "EHLO localhost\r\n", {250})) return false;
        if (!sendSmtpCommand(&socket, "AUTH LOGIN\r\n", {334})) return false;
        if (!sendSmtpCommand(&socket, authUser + "\r\n", {334})) return false;
        if (!sendSmtpCommand(&socket, authPass + "\r\n", {235})) return false;
        if (!sendSmtpCommand(&socket, "MAIL FROM:<" + from.toUtf8() + ">\r\n", {250})) return false;
        if (!sendSmtpCommand(&socket, "RCPT TO:<" + to.toUtf8() + ">\r\n", {250, 251})) return false;
        if (!sendSmtpCommand(&socket, "DATA\r\n", {354})) return false;
        if (!sendSmtpCommand(&socket, message + "\r\n.\r\n", {250})) return false;
        sendSmtpCommand(&socket, "QUIT\r\n", {221});
        return true;
    }

    QTcpSocket socket;
    socket.connectToHost(host, quint16(port));
    if (!socket.waitForConnected(10000)) {
        setMailError(QString("SMTP 连接失败：%1").arg(socket.errorString()));
        return false;
    }

    if (!sendSmtpCommand(&socket, QByteArray(), {220})) return false;
    if (!sendSmtpCommand(&socket, "EHLO localhost\r\n", {250})) return false;
    if (!sendSmtpCommand(&socket, "AUTH LOGIN\r\n", {334})) return false;
    if (!sendSmtpCommand(&socket, authUser + "\r\n", {334})) return false;
    if (!sendSmtpCommand(&socket, authPass + "\r\n", {235})) return false;
    if (!sendSmtpCommand(&socket, "MAIL FROM:<" + from.toUtf8() + ">\r\n", {250})) return false;
    if (!sendSmtpCommand(&socket, "RCPT TO:<" + to.toUtf8() + ">\r\n", {250, 251})) return false;
    if (!sendSmtpCommand(&socket, "DATA\r\n", {354})) return false;
    if (!sendSmtpCommand(&socket, message + "\r\n.\r\n", {250})) return false;
    sendSmtpCommand(&socket, "QUIT\r\n", {221});
    return true;
}

void AuthManager::loginWithCode(const QString &email, const QString &code)
{
    // 验证验证码
    if (!DatabaseManager::instance()->verifyCode(email, code)) {
        emit loginResult(false, "验证码错误或已过期");
        return;
    }
    
    // 查找或创建用户
    int userId = DatabaseManager::instance()->findUserByEmail(email);
    if (userId < 0) {
        // 新用户，自动注册
        userId = DatabaseManager::instance()->createUser(email);
        if (userId < 0) {
            emit loginResult(false, "用户创建失败");
            return;
        }
    }
    
    // 获取用户信息
    QVariantMap userInfo = DatabaseManager::instance()->getUserInfo(userId);
    if (userInfo.isEmpty()) {
        emit loginResult(false, "获取用户信息失败");
        return;
    }
    
    // 设置登录状态
    m_currentUserId = userId;
    m_currentEmail = email;
    m_currentNickname = userInfo["nickname"].toString();
    m_isLoggedIn = true;
    
    // 保存登录状态到本地
    QSettings settings("EverydayPlan", "Auth");
    settings.setValue("currentUserId", m_currentUserId);
    settings.sync();
    
    emit loginStateChanged();
    emit loginResult(true, "登录成功");
    
}

void AuthManager::logout()
{
    m_currentUserId = -1;
    m_currentEmail.clear();
    m_currentNickname.clear();
    m_isLoggedIn = false;
    
    // 清除本地存储的登录状态
    QSettings settings("EverydayPlan", "Auth");
    settings.remove("currentUserId");
    settings.sync();
    
    emit loginStateChanged();
    
    qDebug() << "用户已登出";
}

void AuthManager::reloadSessionFromStorage()
{
    QSettings settings("EverydayPlan", "Auth");
    const int storedUserId = settings.value("currentUserId", -1).toInt();

    m_currentUserId = -1;
    m_currentEmail.clear();
    m_currentNickname.clear();
    m_isLoggedIn = false;

    if (storedUserId > 0) {
        const QVariantMap userInfo = DatabaseManager::instance()->getUserInfo(storedUserId);
        if (!userInfo.isEmpty()) {
            m_currentUserId = storedUserId;
            m_currentEmail = userInfo.value("email").toString();
            m_currentNickname = userInfo.value("nickname").toString();
            m_isLoggedIn = true;
        }
    }

    emit loginStateChanged();
}

void AuthManager::updateNickname(const QString &nickname)
{
    if (m_currentUserId < 0) return;

    const QString trimmed = nickname.trimmed();
    const QString targetName = trimmed.isEmpty() ? m_currentEmail.section('@', 0, 0) : trimmed;
    if (targetName == m_currentNickname) {
        return;
    }
    
    if (DatabaseManager::instance()->updateUserInfo(m_currentUserId, targetName)) {
        m_currentNickname = targetName;
        emit loginStateChanged();
    }
}
