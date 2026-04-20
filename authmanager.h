#ifndef AUTHMANAGER_H
#define AUTHMANAGER_H

#include <QObject>
#include <QString>
#include <QVariantMap>

class QNetworkAccessManager;
class QNetworkReply;
class QJsonObject;

class AuthManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isLoggedIn READ isLoggedIn NOTIFY loginStateChanged)
    Q_PROPERTY(int currentUserId READ currentUserId NOTIFY loginStateChanged)
    Q_PROPERTY(QString currentUserEmail READ currentUserEmail NOTIFY loginStateChanged)
    Q_PROPERTY(QString currentUserNickname READ currentUserNickname NOTIFY loginStateChanged)
    Q_PROPERTY(QString verificationApiBaseUrl READ verificationApiBaseUrl WRITE setVerificationApiBaseUrl NOTIFY verificationApiBaseUrlChanged)

public:
    explicit AuthManager(QObject *parent = nullptr);
    ~AuthManager();

    static AuthManager* instance();

    bool isLoggedIn() const;
    int currentUserId() const;
    QString currentUserEmail() const;
    QString currentUserNickname() const;
    QString verificationApiBaseUrl() const;

    Q_INVOKABLE void requestVerificationCode(const QString &email);
    Q_INVOKABLE void loginWithCode(const QString &email, const QString &code);
    Q_INVOKABLE void logout();
    Q_INVOKABLE void reloadSessionFromStorage();
    Q_INVOKABLE void updateNickname(const QString &nickname);
    Q_INVOKABLE void setVerificationApiBaseUrl(const QString &baseUrl);

signals:
    void loginStateChanged();
    void verificationCodeSent(bool success, const QString &message);
    void loginResult(bool success, const QString &message);
    void errorOccurred(const QString &error);
    void verificationApiBaseUrlChanged();

private:
    QString normalizedApiBaseUrl() const;
    QString buildEndpointUrl(const QString &path) const;
    QString extractReplyMessage(QNetworkReply *reply, const QJsonObject &json) const;
    void setMailError(const QString &message);
    void handleVerifiedLogin(const QString &email);

    int m_currentUserId;
    QString m_currentEmail;
    QString m_currentNickname;
    QString m_lastMailError;
    QString m_verificationApiBaseUrl;
    bool m_isLoggedIn;
    QNetworkAccessManager *m_networkManager;

    static AuthManager* m_instance;
};

#endif // AUTHMANAGER_H
