#include "oneDriveManager.h"
#include "oneDriveAppConfig.h"

#include <QDateTime>
#include <QDesktopServices>
#include <QEventLoop>
#include <QFile>
#include <QFileInfo>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QSettings>
#include <QUrl>
#include <QUrlQuery>

OneDriveManager *OneDriveManager::s_instance = nullptr;

namespace {
const char *kSettingsOrg = "EverydayPlan";
const char *kSettingsApp = "OneDrive";
const char *kDeviceCodeUrl = "https://login.microsoftonline.com/consumers/oauth2/v2.0/devicecode";
const char *kTokenUrl = "https://login.microsoftonline.com/consumers/oauth2/v2.0/token";
const char *kScope = "offline_access Files.ReadWrite.AppFolder User.Read";
}

OneDriveManager::OneDriveManager(QObject *parent)
    : QObject(parent)
{
    restoreSettings();
    m_pollTimer.setSingleShot(false);
    connect(&m_pollTimer, &QTimer::timeout, this, &OneDriveManager::pollDeviceToken);
}

OneDriveManager *OneDriveManager::instance()
{
    if (!s_instance) {
        s_instance = new OneDriveManager();
    }
    return s_instance;
}

bool OneDriveManager::connected() const { return m_connected; }
bool OneDriveManager::busy() const { return m_busy; }
QString OneDriveManager::clientId() const { return m_clientId; }
QString OneDriveManager::statusText() const { return m_statusText; }
QString OneDriveManager::userCode() const { return m_userCode; }
QString OneDriveManager::verificationUrl() const { return m_verificationUrl; }
bool OneDriveManager::usesBuiltInClientId() const { return OneDriveAppConfig::hasBuiltInClientId(); }

void OneDriveManager::restoreSettings()
{
    QSettings settings(kSettingsOrg, kSettingsApp);
    const QString builtInClientId = OneDriveAppConfig::defaultClientId().trimmed();
    m_clientId = builtInClientId.isEmpty() ? settings.value("clientId").toString() : builtInClientId;
    m_accessToken = settings.value("accessToken").toString();
    m_refreshToken = settings.value("refreshToken").toString();
    m_expiresAt = settings.value("expiresAt", 0).toLongLong();
    m_connected = !m_refreshToken.isEmpty() || (!m_accessToken.isEmpty() && m_expiresAt > QDateTime::currentSecsSinceEpoch());
    m_statusText = m_connected ? QStringLiteral("OneDrive 已连接") : QStringLiteral("尚未连接 OneDrive");
}

void OneDriveManager::persistSettings() const
{
    QSettings settings(kSettingsOrg, kSettingsApp);
    if (OneDriveAppConfig::hasBuiltInClientId()) {
        settings.remove("clientId");
    } else {
        settings.setValue("clientId", m_clientId);
    }
    settings.setValue("accessToken", m_accessToken);
    settings.setValue("refreshToken", m_refreshToken);
    settings.setValue("expiresAt", m_expiresAt);
}

void OneDriveManager::setBusy(bool value)
{
    if (m_busy == value) {
        return;
    }
    m_busy = value;
    emit busyChanged();
}

void OneDriveManager::setStatusText(const QString &value)
{
    if (m_statusText == value) {
        return;
    }
    m_statusText = value;
    emit statusTextChanged();
}

void OneDriveManager::clearAuthInfo()
{
    m_userCode.clear();
    m_verificationUrl.clear();
    m_deviceCode.clear();
    emit authInfoChanged();
}

void OneDriveManager::setClientId(const QString &clientId)
{
    if (OneDriveAppConfig::hasBuiltInClientId()) {
        return;
    }

    const QString trimmed = clientId.trimmed();
    if (m_clientId == trimmed) {
        return;
    }
    m_clientId = trimmed;
    persistSettings();
    emit clientIdChanged();
}

void OneDriveManager::startDeviceLogin()
{
    if (m_clientId.trimmed().isEmpty()) {
        setStatusText(QStringLiteral("当前版本未内置 OneDrive Client ID。请先在 oneDriveAppConfig.cpp 中填入作者的正式 Application (client) ID。"));
        return;
    }

    setBusy(true);
    clearAuthInfo();
    setStatusText(QStringLiteral("正在请求 OneDrive 登录验证码..."));

    QNetworkRequest request(QUrl(QString::fromUtf8(kDeviceCodeUrl)));
    request.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/x-www-form-urlencoded"));

    QUrlQuery query;
    query.addQueryItem(QStringLiteral("client_id"), m_clientId);
    query.addQueryItem(QStringLiteral("scope"), QString::fromUtf8(kScope));

    QNetworkReply *reply = m_network.post(request, query.toString(QUrl::FullyEncoded).toUtf8());
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        finishDeviceCodeReply(reply);
    });
}

void OneDriveManager::finishDeviceCodeReply(QNetworkReply *reply)
{
    const QByteArray payload = reply->readAll();
    const QJsonDocument doc = QJsonDocument::fromJson(payload);
    reply->deleteLater();

    if (reply->error() != QNetworkReply::NoError || !doc.isObject()) {
        setBusy(false);
        setStatusText(QStringLiteral("请求 OneDrive 登录失败，请检查网络，或确认内置 Client ID 是否有效。"));
        return;
    }

    const QJsonObject obj = doc.object();
    m_deviceCode = obj.value(QStringLiteral("device_code")).toString();
    m_userCode = obj.value(QStringLiteral("user_code")).toString();
    m_verificationUrl = obj.value(QStringLiteral("verification_uri")).toString();
    m_pollIntervalSeconds = obj.value(QStringLiteral("interval")).toInt(5);
    emit authInfoChanged();

    setStatusText(obj.value(QStringLiteral("message")).toString());
    openVerificationPage();
    m_pollTimer.start(m_pollIntervalSeconds * 1000);
}

void OneDriveManager::openVerificationPage()
{
    if (!m_verificationUrl.isEmpty()) {
        QDesktopServices::openUrl(QUrl(m_verificationUrl));
    }
}

void OneDriveManager::pollDeviceToken()
{
    if (m_deviceCode.isEmpty()) {
        m_pollTimer.stop();
        setBusy(false);
        return;
    }

    QNetworkRequest request(QUrl(QString::fromUtf8(kTokenUrl)));
    request.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/x-www-form-urlencoded"));

    QUrlQuery query;
    query.addQueryItem(QStringLiteral("grant_type"), QStringLiteral("urn:ietf:params:oauth:grant-type:device_code"));
    query.addQueryItem(QStringLiteral("client_id"), m_clientId);
    query.addQueryItem(QStringLiteral("device_code"), m_deviceCode);

    QNetworkReply *reply = m_network.post(request, query.toString(QUrl::FullyEncoded).toUtf8());
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        finishTokenReply(reply);
    });
}

void OneDriveManager::finishTokenReply(QNetworkReply *reply)
{
    const QByteArray payload = reply->readAll();
    const QJsonDocument doc = QJsonDocument::fromJson(payload);
    const QJsonObject obj = doc.object();
    reply->deleteLater();

    if (reply->error() == QNetworkReply::NoError && obj.contains(QStringLiteral("access_token"))) {
        m_pollTimer.stop();
        m_accessToken = obj.value(QStringLiteral("access_token")).toString();
        m_refreshToken = obj.value(QStringLiteral("refresh_token")).toString();
        m_expiresAt = QDateTime::currentSecsSinceEpoch() + obj.value(QStringLiteral("expires_in")).toInt(3600) - 60;
        m_connected = true;
        persistSettings();
        clearAuthInfo();
        setBusy(false);
        setStatusText(QStringLiteral("OneDrive 连接成功"));
        emit connectedChanged();
        return;
    }

    const QString errorCode = obj.value(QStringLiteral("error")).toString();
    if (errorCode == QStringLiteral("authorization_pending")) {
        setStatusText(QStringLiteral("等待你在浏览器中完成 OneDrive 授权..."));
        return;
    }
    if (errorCode == QStringLiteral("slow_down")) {
        m_pollIntervalSeconds += 5;
        m_pollTimer.start(m_pollIntervalSeconds * 1000);
        setStatusText(QStringLiteral("授权轮询减速中，请继续完成浏览器操作..."));
        return;
    }

    m_pollTimer.stop();
    setBusy(false);
    setStatusText(QStringLiteral("OneDrive 授权失败：") + (errorCode.isEmpty() ? QStringLiteral("未知错误") : errorCode));
}

bool OneDriveManager::ensureAccessToken()
{
    if (!m_accessToken.isEmpty() && m_expiresAt > QDateTime::currentSecsSinceEpoch()) {
        return true;
    }
    if (m_refreshToken.isEmpty() || m_clientId.isEmpty()) {
        return false;
    }

    QNetworkRequest request(QUrl(QString::fromUtf8(kTokenUrl)));
    request.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/x-www-form-urlencoded"));

    QUrlQuery query;
    query.addQueryItem(QStringLiteral("grant_type"), QStringLiteral("refresh_token"));
    query.addQueryItem(QStringLiteral("client_id"), m_clientId);
    query.addQueryItem(QStringLiteral("refresh_token"), m_refreshToken);
    query.addQueryItem(QStringLiteral("scope"), QString::fromUtf8(kScope));

    QNetworkReply *reply = m_network.post(request, query.toString(QUrl::FullyEncoded).toUtf8());
    QObject::connect(reply, &QNetworkReply::finished, &m_network, [&]() {
        const QByteArray payload = reply->readAll();
        const QJsonDocument doc = QJsonDocument::fromJson(payload);
        const QJsonObject obj = doc.object();
        if (reply->error() == QNetworkReply::NoError && obj.contains(QStringLiteral("access_token"))) {
            m_accessToken = obj.value(QStringLiteral("access_token")).toString();
            m_refreshToken = obj.value(QStringLiteral("refresh_token")).toString();
            m_expiresAt = QDateTime::currentSecsSinceEpoch() + obj.value(QStringLiteral("expires_in")).toInt(3600) - 60;
            m_connected = true;
            persistSettings();
        }
        reply->deleteLater();
    });

    QEventLoop loop;
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();
    return !m_accessToken.isEmpty() && m_expiresAt > QDateTime::currentSecsSinceEpoch();
}

QString OneDriveManager::appFolderUploadUrl(const QString &fileName) const
{
    return QStringLiteral("https://graph.microsoft.com/v1.0/me/drive/special/approot:/EverydayPlanBackup/%1:/content")
        .arg(QString::fromUtf8(QUrl::toPercentEncoding(fileName)));
}

void OneDriveManager::uploadFile(const QString &localFilePath)
{
    const QString path = localFilePath.trimmed();
    if (path.isEmpty()) {
        setStatusText(QStringLiteral("没有可上传的备份文件，请先在备份中心执行一次本地备份。"));
        emit uploadFinished(false, QStringLiteral("没有可上传的备份文件，请先在备份中心执行一次本地备份。"));
        return;
    }
    if (!QFileInfo::exists(path)) {
        setStatusText(QStringLiteral("最近备份文件不存在，请先重新执行一次本地备份。"));
        emit uploadFinished(false, QStringLiteral("最近备份文件不存在，请先重新执行一次本地备份。"));
        return;
    }
    if (!ensureAccessToken()) {
        setStatusText(QStringLiteral("尚未完成 OneDrive 连接。请点击“连接 OneDrive”，并在浏览器中完成授权。"));
        emit uploadFinished(false, QStringLiteral("尚未完成 OneDrive 连接。请点击“连接 OneDrive”，并在浏览器中完成授权。"));
        return;
    }

    QFile *file = new QFile(path);
    if (!file->open(QIODevice::ReadOnly)) {
        file->deleteLater();
        setStatusText(QStringLiteral("无法读取备份文件，请检查文件是否被占用。"));
        emit uploadFinished(false, QStringLiteral("无法读取备份文件，请检查文件是否被占用。"));
        return;
    }

    setBusy(true);
    setStatusText(QStringLiteral("正在上传最近备份到 OneDrive..."));

    QNetworkRequest request(QUrl(appFolderUploadUrl(QFileInfo(path).fileName())));
    request.setRawHeader("Authorization", QByteArray("Bearer ") + m_accessToken.toUtf8());
    request.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/octet-stream"));

    QNetworkReply *reply = m_network.put(request, file);
    file->setParent(reply);

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        const bool ok = reply->error() == QNetworkReply::NoError;
        const QString message = ok
            ? QStringLiteral("最近备份已上传到 OneDrive")
            : QStringLiteral("上传失败：") + reply->errorString();
        setBusy(false);
        setStatusText(message);
        emit uploadFinished(ok, message);
        reply->deleteLater();
    });
}

void OneDriveManager::disconnectAccount()
{
    m_pollTimer.stop();
    m_accessToken.clear();
    m_refreshToken.clear();
    m_expiresAt = 0;
    m_connected = false;
    clearAuthInfo();
    persistSettings();
    setBusy(false);
    setStatusText(QStringLiteral("已断开 OneDrive 连接"));
    emit connectedChanged();
}
