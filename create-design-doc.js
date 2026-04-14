const { Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell, HeadingLevel, AlignmentType, BorderStyle, WidthType, ShadingType, VerticalAlign, PageBreak, Header, Footer, PageNumber, LevelFormat } = require('docx');
const fs = require('fs');

// 定义颜色方案 - 学术风格
const colors = {
    primary: "#1A365D",      // 深蓝色 - 标题
    body: "#2D3748",         // 深灰色 - 正文
    secondary: "#4A5568",    // 中灰色 - 副标题
    accent: "#3182CE",       // 亮蓝色 - 强调
    tableBg: "#F7FAFC",      // 浅灰色 - 表格背景
    tableBorder: "#CBD5E0"   // 边框颜色
};

const tableBorder = { style: BorderStyle.SINGLE, size: 1, color: colors.tableBorder };
const cellBorders = { top: tableBorder, bottom: tableBorder, left: tableBorder, right: tableBorder };

const doc = new Document({
    styles: {
        default: { document: { run: { font: "SimSun", size: 24 } } },
        paragraphStyles: [
            { id: "Title", name: "Title", basedOn: "Normal",
                run: { size: 56, bold: true, color: colors.primary, font: "SimHei" },
                paragraph: { spacing: { before: 240, after: 120 }, alignment: AlignmentType.CENTER } },
            { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal", quickFormat: true,
                run: { size: 36, bold: true, color: colors.primary, font: "SimHei" },
                paragraph: { spacing: { before: 400, after: 200 }, outlineLevel: 0 } },
            { id: "Heading2", name: "Heading 2", basedOn: "Normal", next: "Normal", quickFormat: true,
                run: { size: 28, bold: true, color: colors.secondary, font: "SimHei" },
                paragraph: { spacing: { before: 300, after: 150 }, outlineLevel: 1 } },
            { id: "Heading3", name: "Heading 3", basedOn: "Normal", next: "Normal", quickFormat: true,
                run: { size: 24, bold: true, color: colors.accent, font: "SimHei" },
                paragraph: { spacing: { before: 200, after: 100 }, outlineLevel: 2 } }
        ]
    },
    numbering: {
        config: [
            { reference: "bullet-list",
                levels: [{ level: 0, format: LevelFormat.BULLET, text: "•", alignment: AlignmentType.LEFT,
                    style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
            { reference: "numbered-list-1",
                levels: [{ level: 0, format: LevelFormat.DECIMAL, text: "%1.", alignment: AlignmentType.LEFT,
                    style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
            { reference: "numbered-list-2",
                levels: [{ level: 0, format: LevelFormat.DECIMAL, text: "%1.", alignment: AlignmentType.LEFT,
                    style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
            { reference: "numbered-list-3",
                levels: [{ level: 0, format: LevelFormat.DECIMAL, text: "%1.", alignment: AlignmentType.LEFT,
                    style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] }
        ]
    },
    sections: [{
        properties: {
            page: { margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 } }
        },
        headers: {
            default: new Header({ children: [new Paragraph({
                alignment: AlignmentType.RIGHT,
                children: [new TextRun({ text: "待办清单系统改进方案", font: "SimHei", size: 20, color: colors.secondary })]
            })] })
        },
        footers: {
            default: new Footer({ children: [new Paragraph({
                alignment: AlignmentType.CENTER,
                children: [
                    new TextRun({ text: "第 ", font: "SimSun", size: 20 }),
                    new TextRun({ children: [PageNumber.CURRENT], font: "SimSun", size: 20 }),
                    new TextRun({ text: " 页 / 共 ", font: "SimSun", size: 20 }),
                    new TextRun({ children: [PageNumber.TOTAL_PAGES], font: "SimSun", size: 20 }),
                    new TextRun({ text: " 页", font: "SimSun", size: 20 })
                ]
            })] })
        },
        children: [
            // 封面标题
            new Paragraph({ heading: HeadingLevel.TITLE, children: [new TextRun("待办清单系统改进方案")] }),
            new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 200 },
                children: [new TextRun({ text: "——甘特图可视化与用户认证系统设计", font: "SimHei", size: 28, color: colors.secondary })] }),
            new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 400 },
                children: [new TextRun({ text: "毕业设计项目改进文档", font: "SimSun", size: 24, color: colors.body })] }),
            new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 200 },
                children: [new TextRun({ text: "2025年3月", font: "SimSun", size: 22, color: colors.secondary })] }),
            
            new Paragraph({ children: [new PageBreak()] }),
            
            // 第一章：项目概述
            new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun("一、项目概述")] }),
            
            new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("1.1 现有项目分析")] }),
            new Paragraph({ indent: { firstLine: 480 }, spacing: { line: 360 },
                children: [new TextRun({ text: "当前项目是一个基于 Qt/QML + C++ + SQLite 的桌面待办清单应用程序，采用经典的 Model-View 架构设计。项目使用 Qt 6 框架开发，前端界面采用 QML 声明式语言构建，后端数据管理使用 C++ 实现，数据持久化采用 SQLite 嵌入式数据库。整体架构清晰，代码结构合理，具备良好的扩展基础。", font: "SimSun" })] }),
            new Paragraph({ indent: { firstLine: 480 }, spacing: { line: 360 },
                children: [new TextRun({ text: "现有系统已经实现了基本的任务管理功能，包括任务的创建、查看、编辑和列表展示。数据模型采用 AbstractContentsItem 类封装单条任务数据，AbstractContentsModel 类继承自 QAbstractListModel 实现数据与视图的绑定。界面布局采用左侧导航栏 + 右侧内容区的经典设计模式，用户体验良好。", font: "SimSun" })] }),
            
            new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("1.2 改进需求分析")] }),
            new Paragraph({ indent: { firstLine: 480 }, spacing: { line: 360 },
                children: [new TextRun({ text: "根据用户需求，本次改进主要包含三个核心功能模块：甘特图可视化、数据库结构完善、用户认证系统。甘特图可视化功能将帮助用户直观地查看任务的时间安排和进度状态，提升任务管理效率。数据库结构完善将为系统增加更多维度的数据支持，包括任务优先级、分类标签、进度百分比等字段。用户认证系统将支持邮箱验证码登录方式，保障用户数据安全和个性化体验。", font: "SimSun" })] }),
            
            // 第二章：数据库设计
            new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun("二、数据库设计改进")] }),
            
            new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("2.1 现有数据库结构")] }),
            new Paragraph({ indent: { firstLine: 480 }, spacing: { line: 360 },
                children: [new TextRun({ text: "当前数据库仅包含一张 AbstractContents 表，字段设计较为简单，主要存储任务的基本信息。现有字段包括：index_num（主键）、title（标题）、author（作者）、content（内容）、time（创建时间）、outline（概要）、die_time（截止时间）。这种设计虽然满足了基本需求，但缺乏对任务进度、优先级、分类等维度的支持，无法满足甘特图可视化和用户认证的功能需求。", font: "SimSun" })] }),
            
            new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("2.2 改进后的数据库结构")] }),
            new Paragraph({ indent: { firstLine: 480 }, spacing: { line: 360 },
                children: [new TextRun({ text: "改进后的数据库将包含四张核心数据表：用户表（Users）、任务表（Tasks）、分类表（Categories）、验证码表（VerificationCodes）。这种设计遵循数据库范式原则，通过外键关联实现数据完整性约束，同时支持多用户独立使用和数据隔离。以下是各表的详细设计说明：", font: "SimSun" })] }),
            
            new Paragraph({ heading: HeadingLevel.HEADING_3, children: [new TextRun("2.2.1 用户表（Users）")] }),
            new Table({
                columnWidths: [2000, 1500, 1500, 4360],
                margins: { top: 100, bottom: 100, left: 180, right: 180 },
                rows: [
                    new TableRow({
                        tableHeader: true,
                        children: [
                            new TableCell({ borders: cellBorders, width: { size: 2000, type: WidthType.DXA },
                                shading: { fill: colors.tableBg, type: ShadingType.CLEAR }, verticalAlign: VerticalAlign.CENTER,
                                children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "字段名", bold: true, font: "SimHei", size: 22 })] })] }),
                            new TableCell({ borders: cellBorders, width: { size: 1500, type: WidthType.DXA },
                                shading: { fill: colors.tableBg, type: ShadingType.CLEAR }, verticalAlign: VerticalAlign.CENTER,
                                children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "类型", bold: true, font: "SimHei", size: 22 })] })] }),
                            new TableCell({ borders: cellBorders, width: { size: 1500, type: WidthType.DXA },
                                shading: { fill: colors.tableBg, type: ShadingType.CLEAR }, verticalAlign: VerticalAlign.CENTER,
                                children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "约束", bold: true, font: "SimHei", size: 22 })] })] }),
                            new TableCell({ borders: cellBorders, width: { size: 4360, type: WidthType.DXA },
                                shading: { fill: colors.tableBg, type: ShadingType.CLEAR }, verticalAlign: VerticalAlign.CENTER,
                                children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "说明", bold: true, font: "SimHei", size: 22 })] })] })
                        ]
                    }),
                    new TableRow({ children: [
                        new TableCell({ borders: cellBorders, width: { size: 2000, type: WidthType.DXA }, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "user_id", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, width: { size: 1500, type: WidthType.DXA }, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "INTEGER", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, width: { size: 1500, type: WidthType.DXA }, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "PK, AI", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, width: { size: 4360, type: WidthType.DXA }, children: [new Paragraph({ children: [new TextRun({ text: "用户唯一标识，自增主键", font: "SimSun", size: 22 })] })] })
                    ]}),
                    new TableRow({ children: [
                        new TableCell({ borders: cellBorders, width: { size: 2000, type: WidthType.DXA }, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "email", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, width: { size: 1500, type: WidthType.DXA }, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "TEXT", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, width: { size: 1500, type: WidthType.DXA }, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "UNIQUE, NN", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, width: { size: 4360, type: WidthType.DXA }, children: [new Paragraph({ children: [new TextRun({ text: "用户邮箱，用于登录验证", font: "SimSun", size: 22 })] })] })
                    ]}),
                    new TableRow({ children: [
                        new TableCell({ borders: cellBorders, width: { size: 2000, type: WidthType.DXA }, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "nickname", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, width: { size: 1500, type: WidthType.DXA }, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "TEXT", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, width: { size: 1500, type: WidthType.DXA }, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "-", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, width: { size: 4360, type: WidthType.DXA }, children: [new Paragraph({ children: [new TextRun({ text: "用户昵称，显示名称", font: "SimSun", size: 22 })] })] })
                    ]}),
                    new TableRow({ children: [
                        new TableCell({ borders: cellBorders, width: { size: 2000, type: WidthType.DXA }, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "avatar", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, width: { size: 1500, type: WidthType.DXA }, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "BLOB", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, width: { size: 1500, type: WidthType.DXA }, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "-", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, width: { size: 4360, type: WidthType.DXA }, children: [new Paragraph({ children: [new TextRun({ text: "用户头像，二进制存储", font: "SimSun", size: 22 })] })] })
                    ]}),
                    new TableRow({ children: [
                        new TableCell({ borders: cellBorders, width: { size: 2000, type: WidthType.DXA }, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "created_at", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, width: { size: 1500, type: WidthType.DXA }, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "TEXT", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, width: { size: 1500, type: WidthType.DXA }, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "DEFAULT", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, width: { size: 4360, type: WidthType.DXA }, children: [new Paragraph({ children: [new TextRun({ text: "账号创建时间", font: "SimSun", size: 22 })] })] })
                    ]})
                ]
            }),
            new Paragraph({ spacing: { before: 100 }, alignment: AlignmentType.CENTER, children: [new TextRun({ text: "表2-1 用户表结构设计", font: "SimSun", size: 20, color: colors.secondary })] }),
            
            new Paragraph({ heading: HeadingLevel.HEADING_3, children: [new TextRun("2.2.2 任务表（Tasks）")] }),
            new Paragraph({ indent: { firstLine: 480 }, spacing: { line: 360 },
                children: [new TextRun({ text: "任务表是系统的核心数据表，存储所有待办任务的详细信息。改进后的任务表增加了多个关键字段，以支持甘特图可视化和更丰富的任务管理功能。新增字段包括：start_date（开始日期）、end_date（结束日期）、progress（进度百分比）、priority（优先级）、category_id（分类外键）、user_id（用户外键）、status（任务状态）等。", font: "SimSun" })] }),
            
            new Table({
                columnWidths: [2000, 1500, 1500, 4360],
                margins: { top: 100, bottom: 100, left: 180, right: 180 },
                rows: [
                    new TableRow({
                        tableHeader: true,
                        children: [
                            new TableCell({ borders: cellBorders, width: { size: 2000, type: WidthType.DXA },
                                shading: { fill: colors.tableBg, type: ShadingType.CLEAR }, verticalAlign: VerticalAlign.CENTER,
                                children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "字段名", bold: true, font: "SimHei", size: 22 })] })] }),
                            new TableCell({ borders: cellBorders, width: { size: 1500, type: WidthType.DXA },
                                shading: { fill: colors.tableBg, type: ShadingType.CLEAR }, verticalAlign: VerticalAlign.CENTER,
                                children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "类型", bold: true, font: "SimHei", size: 22 })] })] }),
                            new TableCell({ borders: cellBorders, width: { size: 1500, type: WidthType.DXA },
                                shading: { fill: colors.tableBg, type: ShadingType.CLEAR }, verticalAlign: VerticalAlign.CENTER,
                                children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "约束", bold: true, font: "SimHei", size: 22 })] })] }),
                            new TableCell({ borders: cellBorders, width: { size: 4360, type: WidthType.DXA },
                                shading: { fill: colors.tableBg, type: ShadingType.CLEAR }, verticalAlign: VerticalAlign.CENTER,
                                children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "说明", bold: true, font: "SimHei", size: 22 })] })] })
                        ]
                    }),
                    new TableRow({ children: [
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "task_id", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "INTEGER", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "PK, AI", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ children: [new TextRun({ text: "任务唯一标识", font: "SimSun", size: 22 })] })] })
                    ]}),
                    new TableRow({ children: [
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "user_id", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "INTEGER", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "FK", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ children: [new TextRun({ text: "关联用户表，实现数据隔离", font: "SimSun", size: 22 })] })] })
                    ]}),
                    new TableRow({ children: [
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "title", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "TEXT", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "NN", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ children: [new TextRun({ text: "任务标题", font: "SimSun", size: 22 })] })] })
                    ]}),
                    new TableRow({ children: [
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "description", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "TEXT", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "-", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ children: [new TextRun({ text: "任务详细描述", font: "SimSun", size: 22 })] })] })
                    ]}),
                    new TableRow({ children: [
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "start_date", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "TEXT", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "NN", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ children: [new TextRun({ text: "任务开始日期（甘特图用）", font: "SimSun", size: 22 })] })] })
                    ]}),
                    new TableRow({ children: [
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "end_date", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "TEXT", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "-", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ children: [new TextRun({ text: "任务截止日期（甘特图用）", font: "SimSun", size: 22 })] })] })
                    ]}),
                    new TableRow({ children: [
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "progress", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "INTEGER", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "DEFAULT 0", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ children: [new TextRun({ text: "任务进度（0-100）", font: "SimSun", size: 22 })] })] })
                    ]}),
                    new TableRow({ children: [
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "priority", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "INTEGER", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "DEFAULT 1", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ children: [new TextRun({ text: "优先级（1低/2中/3高/4紧急）", font: "SimSun", size: 22 })] })] })
                    ]}),
                    new TableRow({ children: [
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "status", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "INTEGER", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "DEFAULT 0", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ children: [new TextRun({ text: "状态（0待办/1进行中/2已完成）", font: "SimSun", size: 22 })] })] })
                    ]}),
                    new TableRow({ children: [
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "category_id", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "INTEGER", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "FK", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ children: [new TextRun({ text: "关联分类表", font: "SimSun", size: 22 })] })] })
                    ]}),
                    new TableRow({ children: [
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "created_at", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "TEXT", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "DEFAULT", font: "SimSun", size: 22 })] })] }),
                        new TableCell({ borders: cellBorders, children: [new Paragraph({ children: [new TextRun({ text: "任务创建时间", font: "SimSun", size: 22 })] })] })
                    ]})
                ]
            }),
            new Paragraph({ spacing: { before: 100 }, alignment: AlignmentType.CENTER, children: [new TextRun({ text: "表2-2 任务表结构设计", font: "SimSun", size: 20, color: colors.secondary })] }),
            
            new Paragraph({ heading: HeadingLevel.HEADING_3, children: [new TextRun("2.2.3 分类表（Categories）")] }),
            new Paragraph({ indent: { firstLine: 480 }, spacing: { line: 360 },
                children: [new TextRun({ text: "分类表用于管理任务的分类标签，支持用户自定义分类。每个分类包含名称、颜色标识和图标等属性，便于用户对任务进行归类管理。分类表与任务表通过外键关联，支持一个任务属于一个分类的设计模式。", font: "SimSun" })] }),
            
            new Paragraph({ heading: HeadingLevel.HEADING_3, children: [new TextRun("2.2.4 验证码表（VerificationCodes）")] }),
            new Paragraph({ indent: { firstLine: 480 }, spacing: { line: 360 },
                children: [new TextRun({ text: "验证码表用于存储邮箱验证码登录所需的验证信息。包含邮箱地址、验证码、过期时间等字段。系统在发送验证码时生成记录，用户验证成功后删除对应记录，确保安全性。验证码默认有效期为5分钟，过期后自动失效。", font: "SimSun" })] }),
            
            // 第三章：甘特图设计
            new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun("三、甘特图可视化设计")] }),
            
            new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("3.1 功能需求分析")] }),
            new Paragraph({ indent: { firstLine: 480 }, spacing: { line: 360 },
                children: [new TextRun({ text: "甘特图是一种常用的项目管理工具，通过横向条形图展示任务的时间安排和进度。在本系统中，甘特图需要实现以下核心功能：任务时间轴展示、进度百分比显示、任务拖拽调整、时间范围缩放、任务筛选过滤等。甘特图界面应与现有系统风格保持一致，提供流畅的用户交互体验。", font: "SimSun" })] }),
            
            new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("3.2 技术实现方案")] }),
            new Paragraph({ indent: { firstLine: 480 }, spacing: { line: 360 },
                children: [new TextRun({ text: "甘特图组件采用纯 QML + JavaScript 实现，充分利用 Qt Quick 的声明式特性和动画系统。主要技术要点包括：使用 Canvas 或 Rectangle 组件绘制时间轴和任务条、使用 ListView 实现任务列表的滚动展示、使用 PropertyAnimation 实现进度动画效果、使用 MouseArea 实现拖拽交互功能。", font: "SimSun" })] }),
            
            new Paragraph({ heading: HeadingLevel.HEADING_3, children: [new TextRun("3.2.1 核心组件架构")] }),
            new Paragraph({ indent: { firstLine: 480 }, spacing: { line: 360 },
                children: [new TextRun({ text: "甘特图模块包含以下核心组件：GanttChart.qml（主容器组件）、GanttHeader.qml（时间轴头部）、GanttTaskBar.qml（任务条组件）、GanttTimeScale.qml（时间刻度）、GanttModel（C++数据模型）。各组件职责明确，通过属性绑定和信号槽机制实现数据同步和交互响应。", font: "SimSun" })] }),
            
            new Paragraph({ heading: HeadingLevel.HEADING_3, children: [new TextRun("3.2.2 数据模型设计")] }),
            new Paragraph({ indent: { firstLine: 480 }, spacing: { line: 360 },
                children: [new TextRun({ text: "甘特图数据模型 GanttModel 继承自 QAbstractListModel，负责从数据库加载任务数据并提供给 QML 视图。模型需要暴露以下角色：taskId（任务ID）、taskTitle（任务标题）、startDate（开始日期）、endDate（结束日期）、progress（进度）、priority（优先级）、color（显示颜色）。模型还需支持按时间范围筛选和按分类过滤功能。", font: "SimSun" })] }),
            
            new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("3.3 界面交互设计")] }),
            new Paragraph({ indent: { firstLine: 480 }, spacing: { line: 360 },
                children: [new TextRun({ text: "甘特图界面采用左右分栏布局：左侧显示任务名称列表，右侧显示时间轴和任务条。用户可以通过鼠标滚轮缩放时间轴，通过拖拽任务条边缘调整任务时间，通过双击任务条打开详情编辑面板。任务条颜色根据优先级自动设置，进度通过填充比例直观展示。", font: "SimSun" })] }),
            
            // 第四章：用户认证系统
            new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun("四、用户认证系统设计")] }),
            
            new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("4.1 登录方式选择")] }),
            new Paragraph({ indent: { firstLine: 480 }, spacing: { line: 360 },
                children: [new TextRun({ text: "根据用户需求，系统支持邮箱验证码登录方式。邮箱验证码登录无需用户记忆密码，只需输入邮箱地址并获取验证码即可完成登录，安全性高且使用便捷。系统通过 SMTP 协议发送验证码邮件，验证码有效期为5分钟，支持重新发送功能。", font: "SimSun" })] }),
            
            new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("4.2 邮箱验证码登录流程")] }),
            new Paragraph({ indent: { firstLine: 480 }, spacing: { line: 360 },
                children: [new TextRun({ text: "邮箱验证码登录流程分为四个步骤：第一步，用户输入邮箱地址并点击获取验证码；第二步，系统生成6位随机验证码，通过SMTP发送至用户邮箱，同时在数据库中存储验证码记录；第三步，用户输入收到的验证码；第四步，系统验证验证码的正确性和有效性，验证通过后创建用户会话并跳转至主界面。", font: "SimSun" })] }),
            
            new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("4.3 技术实现要点")] }),
            new Paragraph({ heading: HeadingLevel.HEADING_3, children: [new TextRun("4.3.1 SMTP邮件发送")] }),
            new Paragraph({ indent: { firstLine: 480 }, spacing: { line: 360 },
                children: [new TextRun({ text: "邮件发送功能使用 Qt 的 QSmtpClient 类或第三方库如 VMime 实现。需要配置SMTP服务器地址、端口、发件人邮箱和授权码。为提高可靠性，建议使用企业邮箱服务或第三方邮件API服务（如SendGrid、阿里云邮件推送）。邮件内容采用HTML格式，包含验证码和有效期提示。", font: "SimSun" })] }),
            
            new Paragraph({ heading: HeadingLevel.HEADING_3, children: [new TextRun("4.3.2 会话管理")] }),
            new Paragraph({ indent: { firstLine: 480 }, spacing: { line: 360 },
                children: [new TextRun({ text: "用户登录成功后，系统创建会话对象保存用户信息。会话信息包括用户ID、邮箱、昵称等基本信息，以及登录时间、最后活跃时间等状态信息。会话数据可存储在内存中或使用 QSettings 持久化到本地配置文件，支持自动登录功能。用户退出登录时清除会话数据。", font: "SimSun" })] }),
            
            new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("4.4 登录界面设计")] }),
            new Paragraph({ indent: { firstLine: 480 }, spacing: { line: 360 },
                children: [new TextRun({ text: "登录界面采用简洁现代的设计风格，与主界面保持视觉一致性。界面元素包括：应用Logo和名称、邮箱输入框、验证码输入框、获取验证码按钮、登录按钮。界面支持响应式布局，适配不同屏幕尺寸。登录成功后自动跳转至主界面，登录失败时显示友好的错误提示。", font: "SimSun" })] }),
            
            // 第五章：代码实现
            new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun("五、核心代码实现")] }),
            
            new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("5.1 数据库初始化代码")] }),
            new Paragraph({ indent: { firstLine: 480 }, spacing: { line: 360 },
                children: [new TextRun({ text: "以下是数据库初始化的C++代码实现，包含所有数据表的创建语句。代码使用 QSqlQuery 执行DDL语句，支持数据库版本检查和自动升级。初始化时首先检查表是否存在，不存在则创建，确保数据库结构完整。", font: "SimSun" })] }),
            
            new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("5.2 甘特图QML组件")] }),
            new Paragraph({ indent: { firstLine: 480 }, spacing: { line: 360 },
                children: [new TextRun({ text: "甘特图组件采用模块化设计，主组件 GanttChart.qml 负责整体布局和协调子组件。时间轴组件使用 Canvas 绘制刻度线，任务条组件使用 Rectangle 配合渐变填充展示进度。所有组件支持属性绑定，数据变化时自动更新显示。", font: "SimSun" })] }),
            
            new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("5.3 用户认证管理器")] }),
            new Paragraph({ indent: { firstLine: 480 }, spacing: { line: 360 },
                children: [new TextRun({ text: "用户认证管理器 AuthManager 类封装了所有认证相关功能，包括验证码生成与发送、验证码校验、用户会话管理等。该类使用 Q_INVOKABLE 宏暴露方法给QML调用，使用信号机制通知QML认证状态变化。", font: "SimSun" })] }),
            
            // 第六章：总结
            new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun("六、实施建议")] }),
            
            new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("6.1 开发步骤建议")] }),
            new Paragraph({ numbering: { reference: "numbered-list-1", level: 0 }, children: [new TextRun({ text: "首先完成数据库结构升级，创建新的数据表并迁移现有数据", font: "SimSun" })] }),
            new Paragraph({ numbering: { reference: "numbered-list-1", level: 0 }, children: [new TextRun({ text: "实现用户认证系统，包括登录界面和认证管理器", font: "SimSun" })] }),
            new Paragraph({ numbering: { reference: "numbered-list-1", level: 0 }, children: [new TextRun({ text: "开发甘特图数据模型，支持任务数据的加载和筛选", font: "SimSun" })] }),
            new Paragraph({ numbering: { reference: "numbered-list-1", level: 0 }, children: [new TextRun({ text: "实现甘特图QML组件，完成可视化界面", font: "SimSun" })] }),
            new Paragraph({ numbering: { reference: "numbered-list-1", level: 0 }, children: [new TextRun({ text: "集成测试并优化用户体验", font: "SimSun" })] }),
            
            new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun("6.2 注意事项")] }),
            new Paragraph({ numbering: { reference: "bullet-list", level: 0 }, children: [new TextRun({ text: "邮件发送功能需要配置有效的SMTP服务器，建议使用企业邮箱或第三方服务", font: "SimSun" })] }),
            new Paragraph({ numbering: { reference: "bullet-list", level: 0 }, children: [new TextRun({ text: "甘特图组件在大量任务时需注意性能优化，建议实现虚拟滚动", font: "SimSun" })] }),
            new Paragraph({ numbering: { reference: "bullet-list", level: 0 }, children: [new TextRun({ text: "用户数据安全需重视，验证码应设置合理的有效期和发送频率限制", font: "SimSun" })] }),
            new Paragraph({ numbering: { reference: "bullet-list", level: 0 }, children: [new TextRun({ text: "建议添加数据备份功能，防止用户数据丢失", font: "SimSun" })] })
        ]
    }]
});

Packer.toBuffer(doc).then(buffer => {
    fs.writeFileSync('/home/z/my-project/download/todo-project-enhanced/待办清单系统改进方案.docx', buffer);
    console.log('设计文档已生成');
});
