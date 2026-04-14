/****************************************************************************
** Meta object code from reading C++ file 'abstractContentsItem.h'
**
** Created by: The Qt Meta Object Compiler version 68 (Qt 6.8.3)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../abstractContentsItem.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'abstractContentsItem.h' doesn't include <QObject>."
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
struct qt_meta_tag_ZN20AbstractContentsItemE_t {};
} // unnamed namespace


#ifdef QT_MOC_HAS_STRINGDATA
static constexpr auto qt_meta_stringdata_ZN20AbstractContentsItemE = QtMocHelpers::stringData(
    "AbstractContentsItem",
    "index_numChanged",
    "",
    "titleChanged",
    "authorChanged",
    "contentChanged",
    "timeChanged",
    "outlineChanged",
    "createdAtChanged",
    "startDateChanged",
    "dueDateChanged",
    "priorityChanged",
    "categoryIdChanged",
    "categoryNameChanged",
    "categoryColorChanged",
    "completedChanged",
    "index_num",
    "title",
    "author",
    "content",
    "time",
    "outline",
    "createdAt",
    "startDate",
    "dueDate",
    "priority",
    "categoryId",
    "categoryName",
    "categoryColor",
    "completed"
);
#else  // !QT_MOC_HAS_STRINGDATA
#error "qtmochelpers.h not found or too old."
#endif // !QT_MOC_HAS_STRINGDATA

Q_CONSTINIT static const uint qt_meta_data_ZN20AbstractContentsItemE[] = {

 // content:
      12,       // revision
       0,       // classname
       0,    0, // classinfo
      14,   14, // methods
      14,  112, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
      14,       // signalCount

 // signals: name, argc, parameters, tag, flags, initial metatype offsets
       1,    0,   98,    2, 0x06,   15 /* Public */,
       3,    0,   99,    2, 0x06,   16 /* Public */,
       4,    0,  100,    2, 0x06,   17 /* Public */,
       5,    0,  101,    2, 0x06,   18 /* Public */,
       6,    0,  102,    2, 0x06,   19 /* Public */,
       7,    0,  103,    2, 0x06,   20 /* Public */,
       8,    0,  104,    2, 0x06,   21 /* Public */,
       9,    0,  105,    2, 0x06,   22 /* Public */,
      10,    0,  106,    2, 0x06,   23 /* Public */,
      11,    0,  107,    2, 0x06,   24 /* Public */,
      12,    0,  108,    2, 0x06,   25 /* Public */,
      13,    0,  109,    2, 0x06,   26 /* Public */,
      14,    0,  110,    2, 0x06,   27 /* Public */,
      15,    0,  111,    2, 0x06,   28 /* Public */,

 // signals: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,

 // properties: name, type, flags, notifyId, revision
      16, QMetaType::Int, 0x00015103, uint(0), 0,
      17, QMetaType::QString, 0x00015103, uint(1), 0,
      18, QMetaType::QString, 0x00015103, uint(2), 0,
      19, QMetaType::QString, 0x00015103, uint(3), 0,
      20, QMetaType::QDateTime, 0x00015103, uint(4), 0,
      21, QMetaType::QString, 0x00015103, uint(5), 0,
      22, QMetaType::QString, 0x00015103, uint(6), 0,
      23, QMetaType::QString, 0x00015103, uint(7), 0,
      24, QMetaType::QString, 0x00015103, uint(8), 0,
      25, QMetaType::Int, 0x00015103, uint(9), 0,
      26, QMetaType::Int, 0x00015103, uint(10), 0,
      27, QMetaType::QString, 0x00015103, uint(11), 0,
      28, QMetaType::QString, 0x00015103, uint(12), 0,
      29, QMetaType::Bool, 0x00015103, uint(13), 0,

       0        // eod
};

Q_CONSTINIT const QMetaObject AbstractContentsItem::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_ZN20AbstractContentsItemE.offsetsAndSizes,
    qt_meta_data_ZN20AbstractContentsItemE,
    qt_static_metacall,
    nullptr,
    qt_incomplete_metaTypeArray<qt_meta_tag_ZN20AbstractContentsItemE_t,
        // property 'index_num'
        QtPrivate::TypeAndForceComplete<int, std::true_type>,
        // property 'title'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'author'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'content'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'time'
        QtPrivate::TypeAndForceComplete<QDateTime, std::true_type>,
        // property 'outline'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'createdAt'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'startDate'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'dueDate'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'priority'
        QtPrivate::TypeAndForceComplete<int, std::true_type>,
        // property 'categoryId'
        QtPrivate::TypeAndForceComplete<int, std::true_type>,
        // property 'categoryName'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'categoryColor'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'completed'
        QtPrivate::TypeAndForceComplete<bool, std::true_type>,
        // Q_OBJECT / Q_GADGET
        QtPrivate::TypeAndForceComplete<AbstractContentsItem, std::true_type>,
        // method 'index_numChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'titleChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'authorChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'contentChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'timeChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'outlineChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'createdAtChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'startDateChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'dueDateChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'priorityChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'categoryIdChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'categoryNameChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'categoryColorChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'completedChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>
    >,
    nullptr
} };

void AbstractContentsItem::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<AbstractContentsItem *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->index_numChanged(); break;
        case 1: _t->titleChanged(); break;
        case 2: _t->authorChanged(); break;
        case 3: _t->contentChanged(); break;
        case 4: _t->timeChanged(); break;
        case 5: _t->outlineChanged(); break;
        case 6: _t->createdAtChanged(); break;
        case 7: _t->startDateChanged(); break;
        case 8: _t->dueDateChanged(); break;
        case 9: _t->priorityChanged(); break;
        case 10: _t->categoryIdChanged(); break;
        case 11: _t->categoryNameChanged(); break;
        case 12: _t->categoryColorChanged(); break;
        case 13: _t->completedChanged(); break;
        default: ;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _q_method_type = void (AbstractContentsItem::*)();
            if (_q_method_type _q_method = &AbstractContentsItem::index_numChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 0;
                return;
            }
        }
        {
            using _q_method_type = void (AbstractContentsItem::*)();
            if (_q_method_type _q_method = &AbstractContentsItem::titleChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 1;
                return;
            }
        }
        {
            using _q_method_type = void (AbstractContentsItem::*)();
            if (_q_method_type _q_method = &AbstractContentsItem::authorChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 2;
                return;
            }
        }
        {
            using _q_method_type = void (AbstractContentsItem::*)();
            if (_q_method_type _q_method = &AbstractContentsItem::contentChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 3;
                return;
            }
        }
        {
            using _q_method_type = void (AbstractContentsItem::*)();
            if (_q_method_type _q_method = &AbstractContentsItem::timeChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 4;
                return;
            }
        }
        {
            using _q_method_type = void (AbstractContentsItem::*)();
            if (_q_method_type _q_method = &AbstractContentsItem::outlineChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 5;
                return;
            }
        }
        {
            using _q_method_type = void (AbstractContentsItem::*)();
            if (_q_method_type _q_method = &AbstractContentsItem::createdAtChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 6;
                return;
            }
        }
        {
            using _q_method_type = void (AbstractContentsItem::*)();
            if (_q_method_type _q_method = &AbstractContentsItem::startDateChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 7;
                return;
            }
        }
        {
            using _q_method_type = void (AbstractContentsItem::*)();
            if (_q_method_type _q_method = &AbstractContentsItem::dueDateChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 8;
                return;
            }
        }
        {
            using _q_method_type = void (AbstractContentsItem::*)();
            if (_q_method_type _q_method = &AbstractContentsItem::priorityChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 9;
                return;
            }
        }
        {
            using _q_method_type = void (AbstractContentsItem::*)();
            if (_q_method_type _q_method = &AbstractContentsItem::categoryIdChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 10;
                return;
            }
        }
        {
            using _q_method_type = void (AbstractContentsItem::*)();
            if (_q_method_type _q_method = &AbstractContentsItem::categoryNameChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 11;
                return;
            }
        }
        {
            using _q_method_type = void (AbstractContentsItem::*)();
            if (_q_method_type _q_method = &AbstractContentsItem::categoryColorChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 12;
                return;
            }
        }
        {
            using _q_method_type = void (AbstractContentsItem::*)();
            if (_q_method_type _q_method = &AbstractContentsItem::completedChanged; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 13;
                return;
            }
        }
    }
    if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< int*>(_v) = _t->index_num(); break;
        case 1: *reinterpret_cast< QString*>(_v) = _t->title(); break;
        case 2: *reinterpret_cast< QString*>(_v) = _t->author(); break;
        case 3: *reinterpret_cast< QString*>(_v) = _t->content(); break;
        case 4: *reinterpret_cast< QDateTime*>(_v) = _t->time(); break;
        case 5: *reinterpret_cast< QString*>(_v) = _t->outline(); break;
        case 6: *reinterpret_cast< QString*>(_v) = _t->createdAt(); break;
        case 7: *reinterpret_cast< QString*>(_v) = _t->startDate(); break;
        case 8: *reinterpret_cast< QString*>(_v) = _t->dueDate(); break;
        case 9: *reinterpret_cast< int*>(_v) = _t->priority(); break;
        case 10: *reinterpret_cast< int*>(_v) = _t->categoryId(); break;
        case 11: *reinterpret_cast< QString*>(_v) = _t->categoryName(); break;
        case 12: *reinterpret_cast< QString*>(_v) = _t->categoryColor(); break;
        case 13: *reinterpret_cast< bool*>(_v) = _t->completed(); break;
        default: break;
        }
    }
    if (_c == QMetaObject::WriteProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: _t->setIndex_num(*reinterpret_cast< int*>(_v)); break;
        case 1: _t->setTitle(*reinterpret_cast< QString*>(_v)); break;
        case 2: _t->setAuthor(*reinterpret_cast< QString*>(_v)); break;
        case 3: _t->setContent(*reinterpret_cast< QString*>(_v)); break;
        case 4: _t->setTime(*reinterpret_cast< QDateTime*>(_v)); break;
        case 5: _t->setOutline(*reinterpret_cast< QString*>(_v)); break;
        case 6: _t->setCreatedAt(*reinterpret_cast< QString*>(_v)); break;
        case 7: _t->setStartDate(*reinterpret_cast< QString*>(_v)); break;
        case 8: _t->setDueDate(*reinterpret_cast< QString*>(_v)); break;
        case 9: _t->setPriority(*reinterpret_cast< int*>(_v)); break;
        case 10: _t->setCategoryId(*reinterpret_cast< int*>(_v)); break;
        case 11: _t->setCategoryName(*reinterpret_cast< QString*>(_v)); break;
        case 12: _t->setCategoryColor(*reinterpret_cast< QString*>(_v)); break;
        case 13: _t->setCompleted(*reinterpret_cast< bool*>(_v)); break;
        default: break;
        }
    }
}

const QMetaObject *AbstractContentsItem::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *AbstractContentsItem::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_ZN20AbstractContentsItemE.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int AbstractContentsItem::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 14)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 14;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 14)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 14;
    }
    if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 14;
    }
    return _id;
}

// SIGNAL 0
void AbstractContentsItem::index_numChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void AbstractContentsItem::titleChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void AbstractContentsItem::authorChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 2, nullptr);
}

// SIGNAL 3
void AbstractContentsItem::contentChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 3, nullptr);
}

// SIGNAL 4
void AbstractContentsItem::timeChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 4, nullptr);
}

// SIGNAL 5
void AbstractContentsItem::outlineChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 5, nullptr);
}

// SIGNAL 6
void AbstractContentsItem::createdAtChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 6, nullptr);
}

// SIGNAL 7
void AbstractContentsItem::startDateChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 7, nullptr);
}

// SIGNAL 8
void AbstractContentsItem::dueDateChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 8, nullptr);
}

// SIGNAL 9
void AbstractContentsItem::priorityChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 9, nullptr);
}

// SIGNAL 10
void AbstractContentsItem::categoryIdChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 10, nullptr);
}

// SIGNAL 11
void AbstractContentsItem::categoryNameChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 11, nullptr);
}

// SIGNAL 12
void AbstractContentsItem::categoryColorChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 12, nullptr);
}

// SIGNAL 13
void AbstractContentsItem::completedChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 13, nullptr);
}
QT_WARNING_POP
