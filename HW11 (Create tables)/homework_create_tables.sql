BEGIN TRANSACTION
-- МТР Группа
CREATE TABLE dbo.Groups
	(
	GrourID uniqueidentifier NOT NULL,
	Name nvarchar(128) NOT NULL,
	Number int NOT NULL,
	IsDeleted bit NULL
	)  ON [PRIMARY]

ALTER TABLE dbo.Groups ADD CONSTRAINT
	DF_Groups_GrourID DEFAULT (newid()) FOR GrourID

ALTER TABLE dbo.Groups ADD CONSTRAINT
	DF_Groups_Name DEFAULT N'Резерв' FOR Name

ALTER TABLE dbo.Groups ADD CONSTRAINT
	PK_Group PRIMARY KEY CLUSTERED 
	(
	GrourID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

CREATE UNIQUE NONCLUSTERED INDEX Number_Group ON dbo.Groups
	(
	Number
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

ALTER TABLE dbo.Groups SET (LOCK_ESCALATION = TABLE)

-- МТР Подгруппа
CREATE TABLE dbo.SubGroups
	(
	SubGroupID uniqueidentifier NOT NULL,
	GroupID uniqueidentifier NOT NULL,
	Name nvarchar(128) NOT NULL,
	Number int NOT NULL,
	IsDeleted bit NULL
	)  ON [PRIMARY]

ALTER TABLE dbo.SubGroups ADD CONSTRAINT
	DF_SubGroups_SubGroupID DEFAULT (newid()) FOR SubGroupID

ALTER TABLE dbo.SubGroups ADD CONSTRAINT
	DF_SubGroup_Name DEFAULT N'Резерв' FOR Name

ALTER TABLE dbo.SubGroups ADD CONSTRAINT
	PK_SubGroups PRIMARY KEY CLUSTERED 
	(
	SubGroupID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

CREATE UNIQUE NONCLUSTERED INDEX Number_SubGroups ON dbo.SubGroups
	(
	Number
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

ALTER TABLE dbo.SubGroups SET (LOCK_ESCALATION = TABLE)

-- МТР Раздел
CREATE TABLE dbo.Sections
	(
	SectionID uniqueidentifier NOT NULL,
	SubGroupID uniqueidentifier NOT NULL,
	Name nvarchar(128) NOT NULL,
	Number int NOT NULL,
	IsDeleted bit NULL
	)  ON [PRIMARY]

ALTER TABLE dbo.Sections ADD CONSTRAINT
	DF_Sections_SectionID DEFAULT (newid()) FOR SectionID

ALTER TABLE dbo.Sections ADD CONSTRAINT
	DF_Section_Name DEFAULT N'Резерв' FOR Name

ALTER TABLE dbo.Sections ADD CONSTRAINT
	PK_Sections PRIMARY KEY CLUSTERED 
	(
	SectionID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

CREATE UNIQUE NONCLUSTERED INDEX Number_Sections ON dbo.Sections
	(
	Number
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

ALTER TABLE dbo.Sections SET (LOCK_ESCALATION = TABLE)

-- МТР Подраздел
CREATE TABLE dbo.SubSections
	(
	SubSectionID uniqueidentifier NOT NULL,
	SectionID uniqueidentifier NOT NULL,
	Name nvarchar(128) NOT NULL,
	Number int NOT NULL,
	TmplDescription nvarchar(max),
	TmplShortDescription nvarchar(max),
	TmplLongDescription nvarchar(max),
	IsDeleted bit NULL
	)  ON [PRIMARY]

ALTER TABLE dbo.SubSections ADD CONSTRAINT
	DF_SubSections_SectionID DEFAULT (newid()) FOR SubSectionID

ALTER TABLE dbo.SubSections ADD CONSTRAINT
	DF_SubSection_Name DEFAULT N'Резерв' FOR Name

ALTER TABLE dbo.SubSections ADD CONSTRAINT
	PK_SubSections PRIMARY KEY CLUSTERED 
	(
	SubSectionID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

CREATE UNIQUE NONCLUSTERED INDEX Number_Sections ON dbo.SubSections
	(
	Number
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

ALTER TABLE dbo.SubSections SET (LOCK_ESCALATION = TABLE)

--МТР Продукты
CREATE TABLE dbo.Products
	(
	ProductID uniqueidentifier NOT NULL,
	SubSectionID uniqueidentifier NOT NULL,
	Description nvarchar(MAX) NOT NULL,
	ShortDescription nvarchar(128) NOT NULL,
	LongDescription nvarchar(MAX) NOT NULL,
	Number int NOT NULL,
	CodeMTR nvarchar(20) NOT NULL,
	IsDelete bit NULL
	)  ON [PRIMARY]
	 TEXTIMAGE_ON [PRIMARY]

ALTER TABLE dbo.Products ADD CONSTRAINT
	DF_Products_ProductID DEFAULT (newid()) FOR ProductID

ALTER TABLE dbo.Products ADD CONSTRAINT
	PK_Products PRIMARY KEY CLUSTERED 
	(
	ProductID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

CREATE UNIQUE NONCLUSTERED INDEX CodeMTR_Products ON dbo.Products
	(
	CodeMTR
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

CREATE NONCLUSTERED INDEX Description_Products ON dbo.Products
	(
	ShortDescription
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

ALTER TABLE dbo.Products SET (LOCK_ESCALATION = TABLE)

-- МТР Свойства продуктов
CREATE TABLE dbo.Properties
	(
	PropertyID uniqueidentifier NOT NULL,
	ProductID uniqueidentifier NOT NULL,
	DerevativeID uniqueidentifier NOT NULL,
	PropertyName nvarchar(128) NOT NULL,
	CodeListID uniqueidentifier,
	PropertyValue nvarchar(128),
	ValueTypeID uniqueidentifier,
	IsDelete bit NULL
	)  ON [PRIMARY]

ALTER TABLE dbo.Properties ADD CONSTRAINT
	DF_Properties_PropertyID DEFAULT (newid()) FOR PropertyID

ALTER TABLE dbo.Properties ADD CONSTRAINT
	PK_Properties PRIMARY KEY CLUSTERED 
	(
	PropertyID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

CREATE UNIQUE NONCLUSTERED INDEX Product_Properties ON dbo.Properties
	(
	ProductID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

CREATE NONCLUSTERED INDEX PropertyName_Properties ON dbo.Properties
	(
	PropertyName
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

ALTER TABLE dbo.Properties SET (LOCK_ESCALATION = TABLE)

-- МТР Отделы
CREATE TABLE dbo.Derevatives
	(
	DerevativeID uniqueidentifier NOT NULL,
	Name nvarchar(50) NOT NULL,
	FullName nvarchar(128) NULL,
	IsDeleted bit NULL
	)  ON [PRIMARY]

ALTER TABLE dbo.Derevatives ADD CONSTRAINT
	DF_Derevatives_DerevativeID DEFAULT (newid()) FOR DerevativeID

ALTER TABLE dbo.Derevatives ADD CONSTRAINT
	PK_Derevatives PRIMARY KEY CLUSTERED 
	(
	DerevativeID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

ALTER TABLE dbo.Derevatives SET (LOCK_ESCALATION = TABLE)

-- МТР Типы данных
CREATE TABLE dbo.ValueTypes
	(
	ValieTypeID uniqueidentifier NOT NULL ROWGUIDCOL,
	Type nvarchar(32) NOT NULL,
	IsDeleted bit NULL
	)  ON [PRIMARY]

ALTER TABLE dbo.ValueTypes ADD CONSTRAINT
	DF_ValueTypes_ValieTypeID DEFAULT (newid()) FOR ValieTypeID

ALTER TABLE dbo.ValueTypes ADD CONSTRAINT
	PK_ValueTypes PRIMARY KEY CLUSTERED 
	(
	ValieTypeID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

ALTER TABLE dbo.ValueTypes SET (LOCK_ESCALATION = TABLE)

-- МТР Справочник свойств
CREATE TABLE dbo.CodeListProperties
	(
	CodeListPropertyID uniqueidentifier NOT NULL ROWGUIDCOL,
	SubSetionID uniqueidentifier NOT NULL,
	Name nvarchar(128) NOT NULL,
	ValueTypeID uniqueidentifier NOT NULL,
	IsDeleted bit NULL
	)  ON [PRIMARY]

ALTER TABLE dbo.CodeListProperties ADD CONSTRAINT
	DF_CodeListProperties_CodeListPropertyID DEFAULT (newid()) FOR CodeListPropertyID

ALTER TABLE dbo.CodeListProperties ADD CONSTRAINT
	PK_CodeListProperties PRIMARY KEY CLUSTERED 
	(
	CodeListPropertyID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

ALTER TABLE dbo.CodeListProperties SET (LOCK_ESCALATION = TABLE)
COMMIT

-- Внешние ключи
BEGIN TRANSACTION

ALTER TABLE dbo.SubSections SET (LOCK_ESCALATION = TABLE)
ALTER TABLE dbo.Products ADD CONSTRAINT
	FK_Products_SubSections FOREIGN KEY
	(
	SubSectionID
	) REFERENCES dbo.SubSections
	(
	SubSectionID
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
ALTER TABLE dbo.Products SET (LOCK_ESCALATION = TABLE)

ALTER TABLE dbo.Sections SET (LOCK_ESCALATION = TABLE)
ALTER TABLE dbo.SubSections ADD CONSTRAINT
	FK_SubSections_Sections FOREIGN KEY
	(
	SectionID
	) REFERENCES dbo.Sections
	(
	SectionID
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
ALTER TABLE dbo.SubSections SET (LOCK_ESCALATION = TABLE)

ALTER TABLE dbo.SubGroups SET (LOCK_ESCALATION = TABLE)
ALTER TABLE dbo.Sections ADD CONSTRAINT
	FK_Sections_SubGroups FOREIGN KEY
	(
	SubGroupID
	) REFERENCES dbo.SubGroups
	(
	SubGroupID
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
ALTER TABLE dbo.Sections SET (LOCK_ESCALATION = TABLE)

ALTER TABLE dbo.Groups SET (LOCK_ESCALATION = TABLE)
ALTER TABLE dbo.SubGroups ADD CONSTRAINT
	FK_SubGroups_Groups FOREIGN KEY
	(
	GroupID
	) REFERENCES dbo.Groups
	(
	GrourID
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
ALTER TABLE dbo.SubGroups SET (LOCK_ESCALATION = TABLE)

COMMIT

