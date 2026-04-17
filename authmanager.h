// 用户认证管理器 - 负责邮箱验证码登录
#ifndef AUTHMANAGER_H
#define AUTHMANAGER_H

#include <QObject>
#include <QString>
#include <QVariantMap>
#include <QByteArray>
#include <QList>

class QTcpSocket;
class QSslSocket;

class AuthManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isLoggedIn READ isLoggedIn NOTIFY loginStateChanged)
    Q_PROPERTY(int currentUserId READ currentUserId NOTIFY loginStateChanged)
    Q_PROPERTY(QString currentUserEmail READ currentUserEmail NOTIFY loginStateChanged)
    Q_PROPERTY(QString currentUserNickname READ currentUserNickname NOTIFY loginStateChanged)

public:
    explicit AuthManager(QObject *parent = nullptr);
    ~AuthManager();

    static AuthManager* instance();

    // 登录状态
    bool isLoggedIn() const;
    int currentUserId() const;
    QString currentUserEmail() const;
    QString currentUserNickname() const;

    // 邮箱验证码登录流程
    Q_INVOKABLE void requestVerificationCode(const QString &email);
    Q_INVOKABLE void loginWithCode(const QString &email, const QString &code);
    
    // 登出
    Q_INVOKABLE void logout();
    Q_INVOKABLE void reloadSessionFromStorage();
    
    // 更新用户信息
    Q_INVOKABLE void updateNickname(const QString &nickname);

signals:
    void loginStateChanged();
    void verificationCodeSent(bool success, const QString &message);
    void loginResult(bool success, const QString &message);
    void errorOccurred(const QString &error);

private:
    QString generateVerificationCode();//生成验证码
    bool sendEmail(const QString &to, const QString &subject, const QString &body);//发送邮件
    bool sendSmtpCommand(QTcpSocket *socket, const QByteArray &command, const QList<int> &expectedCodes, QByteArray *response = nullptr);
    bool sendSmtpCommand(QSslSocket *socket, const QByteArray &command, const QList<int> &expectedCodes, QByteArray *response = nullptr);
    void setMailError(const QString &message);

    int m_currentUserId;
    QString m_currentEmail;
    QString m_currentNickname;
    QString m_lastMailError;
    bool m_isLoggedIn;
    
    static AuthManager* m_instance;//单例对象指针，保证全局只有一个 AuthManager
};

#endif // AUTHMANAGER_H
