/****************************************************************************
** Meta object code from reading C++ file 'ganttmodel.h'
**
** Created by: The Qt Meta Object Compiler version 68 (Qt 6.8.3)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../ganttmodel.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'ganttmodel.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 68
#error "This file was generated using the moc from 6.8.3. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

#ifndef Q_CONSTINIT
#define Q_CONSTINIT
#endif

QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
QT_WARNING_DISABLE_GCC("-Wuseless-cast")
namespace {
struct qt_meta_tag_ZN10GanttModelE_t {};
} // unnamed namespace


#ifdef QT_MOC_HAS_STRINGDATA
static constexpr auto qt_meta_stringdata_ZN10GanttModelE = QtMocHelpers::stringData(
    "GanttModel",
    "viewDateChanged",
    "",
    "userIdChanged",
    "tasksLoaded",
    "count",
    "loadTasks",
    "setDateRange",
    "start",
    "end",
    "moveToPreviousWeek",
    "moveToNextWeek",
    "moveToToday",
    "updateTaskDates",
    "taskId",
    "startDate",
    "endDate",
    "updateTaskProgress",
    "progress",
    "viewStartDate",
    "viewEndDate",
    "userId",
    "totalDays"
);
#else  // !QT_MOC_HAS_STRINGDATA
#error "qtmochelpers.h not found or too old."
#endif // !QT_MOC_HAS_STRINGDATA

Q_CONSTINIT static const uint qt_meta_data_ZN10GanttModelE[] = {

 // content:
      12,       // revision
       0,       // classname
       0,    0, // classinfo
      10,   14, // methods
       4,  100, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       3,       // signalCount

 // signals: name, argc, parameters, tag, flags, initial metatype offsets
       1,    0,   74,    2, 0x06,    5 /* Public */,
       3,    0,   75,    2, 0x06,    6 /* Public */,
       4,    1,   76,    2, 0x06,    7 /* Public */,

 // methods: name, argc, parameters, tag, flags, initial metatype offsets
       6,    0,   79,    2, 0x02,    9 /* Public */,
       7,    2,   80,    2, 0x02,   10 /* Public */,
      10,    0,   85,    2, 0x02,   13 /* Public */,
      11,    0,   86,    2, 0x02,   14 /* Public */,
      12,    0,   87,    2, 0x02,   15 /* Public */,
      13,    3,   88,    2, 0x02,   16 /* Public */,
      17,    2,   95,    2, 0x02,   20 /* Public */,

 // signals: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::Int,    5,

 // methods: parameters
    QMetaType::Void,
    QMetaType::Void, QMetaType::QDate, QMetaType::QDate,    8,    9,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Bool, QMetaType::Int, QMetaType::QDate, QMetaType::QDate,   14,   15,   16,
    QMetaType::Bool, QMetaType::Int, QMetaType::Int,   14,   18,

 // properties: name, type, flags, notifyId, revision
      19, QMetaType::QDate, 0x00015103, uint(0), 0,
      20, QMetaType::QDate, 0x00015103, uint(0), 0,
      21, QMetaType::Int, 0x00015103, uint(1), 0,
      22, QMetaType::Int, 0x00015001, uint(0), 0,

       0        // eod
};

Q_CONSTINIT const QMetaObject GanttModel::staticMetaObject = { {
    QMetaObject::SuperData::link<QAbstractListModel::staticMetaObject>(),
    qt_meta_stringdata_ZN10GanttModelE.offsetsAndSizes,
    qt_meta_data_ZN10GanttModelE,
    qt_static_metacall,
    nullptr,
    qt_incomplete_metaTypeArray<qt_meta_tag_ZN10GanttModelE_t,
        // property 'viewStartDate'
        QtPrivate::TypeAndForceComplete<QDate, std::true_type>,
        // property 'viewEndDate'
        QtPrivate::TypeAndForceComplete<QDate, std::true_type>,
        // property 'userId'
        QtPrivate::TypeAndForceComplete<int, std::true_type>,
        // property 'totalDays'
        QtPrivate::TypeAndForceComplete<int, std::true_type>,
        // Q_OBJECT / Q_GADGET
        QtPrivate::TypeAndForceComplete<GanttModel, std::true_type>,
        // method 'viewDateChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'userIdChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'tasksLoaded'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'loadTasks'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'setDateRange'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QDate &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QDate &, std::false_type>,
        // method 'moveToPreviousWeek'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'moveToNextWeek'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'moveToToday'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'updateTaskDates'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QDate &, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QDate &, std::false_type>,
        // method 'updateTaskProgress'
        QtPrivate::TypeAndForceComplete<bool, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>
    >,
    nullptr
} };

void GanttModel::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<GanttModel *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->viewDateChanged(); break;
        case 1: _t->userIdChanged(); break;
        case 2: _t->tasksLoaded((*reinterpret_cast< std::add_pointer_t<int>>(_a[1]))); break;
        case 3: _t->loadTasks(); break;
        case 4: _t->setDateRange((*reinterpret_cast< std::add_pointer_t<QDate>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QDate>>(_a[2]))); break;
        case 5: _t->moveToPreviousWeek(); break;
        case 6: _t->moveToNextWeek(); break;
        case 7: _t->moveToToday(); break;
        case 8: { bool _r = _t->updateTaskDates((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QDate>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<QDate>>(_a[3])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 9: { bool _r = _t->updateTaskProgress((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<int>>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        default: ;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _q_method_type = void (GanttModel::*)();
            if (_q_method_type _q_method = &GanttModel::viewDateChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 0;
                return;
            }
        }
        {
            using _q_method_type = void (GanttModel::*)();
            if (_q_method_type _q_method = &GanttModel::userIdChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 1;
                return;
            }
        }
        {
            using _q_method_type = void (GanttModel::*)(int );
            if (_q_method_type _q_method = &GanttModel::tasksLoaded; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 2;
                return;
            }
        }
    }
    if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< QDate*>(_v) = _t->viewStartDate(); break;
        case 1: *reinterpret_cast< QDate*>(_v) = _t->viewEndDate(); break;
        case 2: *reinterpret_cast< int*>(_v) = _t->userId(); break;
        case 3: *reinterpret_cast< int*>(_v) = _t->totalDays(); break;
        default: break;
        }
    }
    if (_c == QMetaObject::WriteProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: _t->setViewStartDate(*reinterpret_cast< QDate*>(_v)); break;
        case 1: _t->setViewEndDate(*reinterpret_cast< QDate*>(_v)); break;
        case 2: _t->setUserId(*reinterpret_cast< int*>(_v)); break;
        default: break;
        }
    }
}

const QMetaObject *GanttModel::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *GanttModel::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_ZN10GanttModelE.stringdata0))
        return static_cast<void*>(this);
    return QAbstractListModel::qt_metacast(_clname);
}

int GanttModel::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QAbstractListModel::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 10)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 10;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 10)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 10;
    }
    if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 4;
    }
    return _id;
}

// SIGNAL 0
void GanttModel::viewDateChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void GanttModel::userIdChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void GanttModel::tasksLoaded(int _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 2, _a);
}
namespace {
struct qt_meta_tag_ZN13GanttTaskItemE_t {};
} // unnamed namespace


#ifdef QT_MOC_HAS_STRINGDATA
static constexpr auto qt_meta_stringdata_ZN13GanttTaskItemE = QtMocHelpers::stringData(
    "GanttTaskItem"
);
#else  // !QT_MOC_HAS_STRINGDATA
#error "qtmochelpers.h not found or too old."
#endif // !QT_MOC_HAS_STRINGDATA

Q_CONSTINIT static const uint qt_meta_data_ZN13GanttTaskItemE[] = {

 // content:
      12,       // revision
       0,       // classname
       0,    0, // classinfo
       0,    0, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

       0        // eod
};

Q_CONSTINIT const QMetaObject GanttTaskItem::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_ZN13GanttTaskItemE.offsetsAndSizes,
    qt_meta_data_ZN13GanttTaskItemE,
    qt_static_metacall,
    nullptr,
    qt_incomplete_metaTypeArray<qt_meta_tag_ZN13GanttTaskItemE_t,
        // Q_OBJECT / Q_GADGET
        QtPrivate::TypeAndForceComplete<GanttTaskItem, std::true_type>
    >,
    nullptr
} };

void GanttTaskItem::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<GanttTaskItem *>(_o);
    (void)_t;
    (void)_c;
    (void)_id;
    (void)_a;
}

const QMetaObject *GanttTaskItem::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *GanttTaskItem::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_ZN13GanttTaskItemE.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int GanttTaskItem::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    return _id;
}
QT_WARNING_POP
