#ifndef ONEDRIVEMANAGER_H
#define ONEDRIVEMANAGER_H

#include <QObject>
#include <QString>
#include <QNetworkAccessManager>
#include <QTimer>

class QNetworkReply;

class OneDriveManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(QString clientId READ clientId WRITE setClientId NOTIFY clientIdChanged)
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusTextChanged)
    Q_PROPERTY(QString userCode READ userCode NOTIFY authInfoChanged)
    Q_PROPERTY(QString verificationUrl READ verificationUrl NOTIFY authInfoChanged)
    Q_PROPERTY(bool usesBuiltInClientId READ usesBuiltInClientId CONSTANT)

public:
    explicit OneDriveManager(QObject *parent = nullptr);
    static OneDriveManager *instance();

    bool connected() const;
    bool busy() const;
    QString clientId() const;
    QString statusText() const;
    QString userCode() const;
    QString verificationUrl() const;
    bool usesBuiltInClientId() const;

    Q_INVOKABLE void setClientId(const QString &clientId);
    Q_INVOKABLE void startDeviceLogin();
    Q_INVOKABLE void disconnectAccount();
    Q_INVOKABLE void uploadFile(const QString &localFilePath);
    Q_INVOKABLE void openVerificationPage();

signals:
    void connectedChanged();
    void busyChanged();
    void clientIdChanged();
    void statusTextChanged();
    void authInfoChanged();
    void uploadFinished(bool success, const QString &message);

private slots:
    void pollDeviceToken();

private:
    void restoreSettings();
    void persistSettings() const;
    void setBusy(bool value);
    void setStatusText(const QString &value);
    void clearAuthInfo();
    bool ensureAccessToken();
    void finishDeviceCodeReply(QNetworkReply *reply);
    void finishTokenReply(QNetworkReply *reply);
    QString appFolderUploadUrl(const QString &fileName) const;

    QNetworkAccessManager m_network;
    QTimer m_pollTimer;
    QString m_clientId;
    QString m_accessToken;
    QString m_refreshToken;
    qint64 m_expiresAt = 0;
    QString m_statusText;
    QString m_userCode;
    QString m_verificationUrl;
    QString m_deviceCode;
    bool m_connected = false;
    bool m_busy = false;
    int m_pollIntervalSeconds = 5;

    static OneDriveManager *s_instance;
};

#endif
