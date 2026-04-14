#include <QtQml/qqmlprivate.h>
#include <QtCore/qdir.h>
#include <QtCore/qurl.h>
#include <QtCore/qhash.h>
#include <QtCore/qstring.h>

namespace QmlCacheGeneratedCode {
namespace _qt_qml_everyday_day_Main_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_everyday_day_AbstractContents_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_everyday_day_ContensElement_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_everyday_day_LoginWindow_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_everyday_day_GanttChart_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_everyday_day_GanttHeader_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_everyday_day_GanttTaskBar_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_everyday_day_SettingsPanel_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_everyday_day_NewTaskDialog_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_everyday_day_NewCategoryDialog_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_everyday_day_CategoryListPanel_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}

}
namespace {
struct Registry {
    Registry();
    ~Registry();
    QHash<QString, const QQmlPrivate::CachedQmlUnit*> resourcePathToCachedUnit;
    static const QQmlPrivate::CachedQmlUnit *lookupCachedUnit(const QUrl &url);
};

Q_GLOBAL_STATIC(Registry, unitRegistry)


Registry::Registry() {
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/everyday_day/Main.qml"), &QmlCacheGeneratedCode::_qt_qml_everyday_day_Main_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/everyday_day/AbstractContents.qml"), &QmlCacheGeneratedCode::_qt_qml_everyday_day_AbstractContents_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/everyday_day/ContensElement.qml"), &QmlCacheGeneratedCode::_qt_qml_everyday_day_ContensElement_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/everyday_day/LoginWindow.qml"), &QmlCacheGeneratedCode::_qt_qml_everyday_day_LoginWindow_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/everyday_day/GanttChart.qml"), &QmlCacheGeneratedCode::_qt_qml_everyday_day_GanttChart_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/everyday_day/GanttHeader.qml"), &QmlCacheGeneratedCode::_qt_qml_everyday_day_GanttHeader_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/everyday_day/GanttTaskBar.qml"), &QmlCacheGeneratedCode::_qt_qml_everyday_day_GanttTaskBar_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/everyday_day/SettingsPanel.qml"), &QmlCacheGeneratedCode::_qt_qml_everyday_day_SettingsPanel_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/everyday_day/NewTaskDialog.qml"), &QmlCacheGeneratedCode::_qt_qml_everyday_day_NewTaskDialog_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/everyday_day/NewCategoryDialog.qml"), &QmlCacheGeneratedCode::_qt_qml_everyday_day_NewCategoryDialog_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/everyday_day/CategoryListPanel.qml"), &QmlCacheGeneratedCode::_qt_qml_everyday_day_CategoryListPanel_qml::unit);
    QQmlPrivate::RegisterQmlUnitCacheHook registration;
    registration.structVersion = 0;
    registration.lookupCachedQmlUnit = &lookupCachedUnit;
    QQmlPrivate::qmlregister(QQmlPrivate::QmlUnitCacheHookRegistration, &registration);
}

Registry::~Registry() {
    QQmlPrivate::qmlunregister(QQmlPrivate::QmlUnitCacheHookRegistration, quintptr(&lookupCachedUnit));
}

const QQmlPrivate::CachedQmlUnit *Registry::lookupCachedUnit(const QUrl &url) {
    if (url.scheme() != QLatin1String("qrc"))
        return nullptr;
    QString resourcePath = QDir::cleanPath(url.path());
    if (resourcePath.isEmpty())
        return nullptr;
    if (!resourcePath.startsWith(QLatin1Char('/')))
        resourcePath.prepend(QLatin1Char('/'));
    return unitRegistry()->resourcePathToCachedUnit.value(resourcePath, nullptr);
}
}
int QT_MANGLE_NAMESPACE(qInitResources_qmlcache_appeveryday_day)() {
    ::unitRegistry();
    return 1;
}
Q_CONSTRUCTOR_FUNCTION(QT_MANGLE_NAMESPACE(qInitResources_qmlcache_appeveryday_day))
int QT_MANGLE_NAMESPACE(qCleanupResources_qmlcache_appeveryday_day)() {
    return 1;
}
