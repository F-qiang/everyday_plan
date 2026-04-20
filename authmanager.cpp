#include "authmanager.h"
#include "databasemanager.h"

#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QRegularExpression>
#include <QSettings>
#include <QUrl>
#include <QUrlQuery>

AuthManager* AuthManager::m_instance = nullptr;

AuthManager::AuthManager(QObject *parent)
    : QObject(parent)
    , m_currentUserId(-1)
    , m_isLoggedIn(false)
    , m_networkManager(new QNetworkAccessManager(this))
{
    QSettings settings("EverydayPlan", "Auth");
    m_currentUserId = settings.value("currentUserId", -1).toInt();
    m_verificationApiBaseUrl = settings.value("verificationApiBaseUrl", "http://127.0.0.1:3000/api/auth").toString().trimmed();

    if (m_currentUserId > 0) {
        const QVariantMap userInfo = DatabaseManager::instance()->getUserInfo(m_currentUserId);
        if (!userInfo.isEmpty()) {
            m_currentEmail = userInfo["email"].toString();
            m_currentNickname = userInfo["nickname"].toString();
            m_isLoggedIn = true;
            emit loginStateChanged();
        }
    }
}

AuthManager::~AuthManager() = default;

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

QString AuthManager::verificationApiBaseUrl() const
{
    return m_verificationApiBaseUrl;
}

QString AuthManager::normalizedApiBaseUrl() const
{
    QString baseUrl = m_verificationApiBaseUrl.trimmed();
    while (baseUrl.endsWith('/')) {
        baseUrl.chop(1);
    }
    return baseUrl;
}

QString AuthManager::buildEndpointUrl(const QString &path) const
{
    const QString baseUrl = normalizedApiBaseUrl();
    if (baseUrl.isEmpty()) {
        return QString();
    }

    QString normalizedPath = path.trimmed();
    if (!normalizedPath.startsWith('/')) {
        normalizedPath.prepend('/');
    }

    return baseUrl + normalizedPath;
}

QString AuthManager::extractReplyMessage(QNetworkReply *reply, const QJsonObject &json) const
{
    const QString jsonMessage = json.value("message").toString().trimmed();
    if (!jsonMessage.isEmpty()) {
        return jsonMessage;
    }

    const QString errorString = reply ? reply->errorString().trimmed() : QString();
    if (!errorString.isEmpty()) {
        return errorString;
    }

    return QStringLiteral("请求失败，请稍后重试");
}

void AuthManager::setVerificationApiBaseUrl(const QString &baseUrl)
{
    QString normalized = baseUrl.trimmed();
    while (normalized.endsWith('/')) {
        normalized.chop(1);
    }

    if (m_verificationApiBaseUrl == normalized) {
        return;
    }

    m_verificationApiBaseUrl = normalized;
    QSettings settings("EverydayPlan", "Auth");
    settings.setValue("verificationApiBaseUrl", m_verificationApiBaseUrl);
    settings.sync();
    emit verificationApiBaseUrlChanged();
}

void AuthManager::requestVerificationCode(const QString &email)
{
    const QRegularExpression emailRegex(R"(^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$)");
    const QString trimmedEmail = email.trimmed();
    if (!emailRegex.match(trimmedEmail).hasMatch()) {
        emit verificationCodeSent(false, "邮箱格式不正确");
        return;
    }

    int remainingSeconds = 0;
    if (!DatabaseManager::instance()->canRequestVerificationCode(trimmedEmail, 60, &remainingSeconds)) {
        emit verificationCodeSent(false, QString("请求过于频繁，请 %1 秒后再试").arg(remainingSeconds));
        return;
    }

    const QString endpoint = buildEndpointUrl("/send-code");
    if (endpoint.isEmpty()) {
        emit verificationCodeSent(false, "未配置验证码服务地址");
        return;
    }

    QUrl url(endpoint);
    if (!url.isValid()) {
        emit verificationCodeSent(false, "验证码服务地址无效");
        return;
    }

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Accept", "application/json");

    QJsonObject payload;
    payload.insert("email", trimmedEmail);

    QNetworkReply *reply = m_networkManager->post(request, QJsonDocument(payload).toJson(QJsonDocument::Compact));
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        const QByteArray raw = reply->readAll();
        const QJsonDocument jsonDoc = QJsonDocument::fromJson(raw);
        const QJsonObject json = jsonDoc.isObject() ? jsonDoc.object() : QJsonObject();
        const bool success = reply->error() == QNetworkReply::NoError && reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt() / 100 == 2;

        if (success) {
            emit verificationCodeSent(true, json.value("message").toString("验证码已发送，请查收邮件"));
        } else {
            const QString message = extractReplyMessage(reply, json);
            setMailError(message);
            emit verificationCodeSent(false, message);
        }

        reply->deleteLater();
    });
}

void AuthManager::handleVerifiedLogin(const QString &email)
{
    int userId = DatabaseManager::instance()->findUserByEmail(email);
    if (userId < 0) {
        userId = DatabaseManager::instance()->createUser(email);
        if (userId < 0) {
            emit loginResult(false, "用户创建失败");
            return;
        }
    }

    const QVariantMap userInfo = DatabaseManager::instance()->getUserInfo(userId);
    if (userInfo.isEmpty()) {
        emit loginResult(false, "获取用户信息失败");
        return;
    }

    m_currentUserId = userId;
    m_currentEmail = email;
    m_currentNickname = userInfo["nickname"].toString();
    m_isLoggedIn = true;

    QSettings settings("EverydayPlan", "Auth");
    settings.setValue("currentUserId", m_currentUserId);
    settings.sync();

    emit loginStateChanged();
    emit loginResult(true, "登录成功");
}

void AuthManager::loginWithCode(const QString &email, const QString &code)
{
    const QString trimmedEmail = email.trimmed();
    const QString trimmedCode = code.trimmed();

    if (trimmedEmail.isEmpty() || trimmedCode.length() != 6) {
        emit loginResult(false, "请输入正确的邮箱和 6 位验证码");
        return;
    }

    const QString endpoint = buildEndpointUrl("/verify-code");
    if (endpoint.isEmpty()) {
        emit loginResult(false, "未配置验证码服务地址");
        return;
    }

    QUrl url(endpoint);
    if (!url.isValid()) {
        emit loginResult(false, "验证码服务地址无效");
        return;
    }

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Accept", "application/json");

    QJsonObject payload;
    payload.insert("email", trimmedEmail);
    payload.insert("code", trimmedCode);

    QNetworkReply *reply = m_networkManager->post(request, QJsonDocument(payload).toJson(QJsonDocument::Compact));
    connect(reply, &QNetworkReply::finished, this, [this, reply, trimmedEmail]() {
        const QByteArray raw = reply->readAll();
        const QJsonDocument jsonDoc = QJsonDocument::fromJson(raw);
        const QJsonObject json = jsonDoc.isObject() ? jsonDoc.object() : QJsonObject();
        const bool success = reply->error() == QNetworkReply::NoError && reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt() / 100 == 2;

        if (!success) {
            emit loginResult(false, extractReplyMessage(reply, json));
            reply->deleteLater();
            return;
        }

        const bool verified = json.value("success").toBool(true);
        if (!verified) {
            emit loginResult(false, json.value("message").toString("验证码错误或已过期"));
            reply->deleteLater();
            return;
        }

        handleVerifiedLogin(trimmedEmail);
        reply->deleteLater();
    });
}

void AuthManager::logout()
{
    m_currentUserId = -1;
    m_currentEmail.clear();
    m_currentNickname.clear();
    m_isLoggedIn = false;

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
