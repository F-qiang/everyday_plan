-- 数据库初始化脚本
-- 用于创建待办清单系统的数据库结构

-- 用户表
CREATE TABLE IF NOT EXISTS Users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE NOT NULL,
    nickname TEXT,
    avatar BLOB,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- 用户设置表
CREATE TABLE IF NOT EXISTS UserSettings (
    user_id INTEGER PRIMARY KEY,
    settings_json TEXT NOT NULL DEFAULT '{}',
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- 分类表
CREATE TABLE IF NOT EXISTS Categories (
    category_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    color TEXT DEFAULT '#3498db',
    icon TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- 任务表（改进版）
CREATE TABLE IF NOT EXISTS Tasks (
    task_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    content TEXT,
    start_date TEXT NOT NULL,
    end_date TEXT,
    today_until TEXT,
    progress INTEGER DEFAULT 0,
    priority INTEGER DEFAULT 1,
    status INTEGER DEFAULT 0,
    category_id INTEGER,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE SET NULL
);

-- 验证码表
CREATE TABLE IF NOT EXISTS VerificationCodes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT NOT NULL,
    code TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    expires_at TEXT NOT NULL
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_tasks_user_id ON Tasks(user_id);
CREATE INDEX IF NOT EXISTS idx_tasks_dates ON Tasks(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_tasks_status ON Tasks(status);
CREATE INDEX IF NOT EXISTS idx_verification_email ON VerificationCodes(email);

-- 首先创建一个默认用户
INSERT OR IGNORE INTO Users (user_id, email, nickname) VALUES (1, 'default@example.com', '默认用户');

-- 插入默认用户设置示例
INSERT OR IGNORE INTO UserSettings (user_id, settings_json) VALUES (
    1,
    '{}'
);

-- 插入默认分类
INSERT INTO Categories (user_id, name, color) VALUES 
    (1, '工作', '#e74c3c'),
    (1, '学习', '#3498db'),
    (1, '生活', '#2ecc71'),
    (1, '其他', '#9b59b6');

-- 数据迁移：从旧表 AbstractContents 迁移数据到 Tasks 表
-- 如果存在旧表，执行以下迁移

-- 迁移旧数据
INSERT INTO Tasks (user_id, title, description, content, start_date, end_date, progress, priority, status)
SELECT 
    1 as user_id,
    title,
    content as description,
    content,
    COALESCE(time, date('now')) as start_date,
    die_time as end_date,
    0 as progress,
    1 as priority,
    0 as status
FROM AbstractContents
WHERE NOT EXISTS (
    SELECT 1 FROM Tasks WHERE Tasks.title = AbstractContents.title
);
