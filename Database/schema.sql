/* ============================================================
   DataTracking - Database Schema (SQL Server)
   Replaces the dummy App_Data/*.json files used in the demo.
   ============================================================ */

CREATE TABLE Users (
    UserId          INT IDENTITY(1,1)   PRIMARY KEY,
    Token           NVARCHAR(100)       NOT NULL UNIQUE,
    Name            NVARCHAR(200)       NOT NULL,
    Department      NVARCHAR(100)       NULL,
    Email           NVARCHAR(200)       NULL,
    DefaultRole     NVARCHAR(50)        NULL,
    IsActive        BIT                 NOT NULL DEFAULT (1),
    CreatedOn       DATETIME2           NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE Categories (
    CategoryId      INT IDENTITY(1,1)   PRIMARY KEY,
    ParentId        INT                 NULL REFERENCES Categories(CategoryId),
    Level           TINYINT             NOT NULL CHECK (Level BETWEEN 1 AND 4),
    Name            NVARCHAR(200)       NOT NULL,
    IsActive        BIT                 NOT NULL DEFAULT (1)
);
CREATE INDEX IX_Categories_ParentId ON Categories(ParentId);

CREATE TABLE Subjects (
    SubjectId       INT IDENTITY(1,1)   PRIMARY KEY,
    SubjectText     NVARCHAR(500)       NOT NULL UNIQUE,
    CreatedOn       DATETIME2           NOT NULL DEFAULT SYSUTCDATETIME()
);
CREATE INDEX IX_Subjects_SubjectText ON Subjects(SubjectText);

CREATE TABLE Tags (
    TagId           INT IDENTITY(1,1)   PRIMARY KEY,
    TagName         NVARCHAR(100)       NOT NULL UNIQUE
);
CREATE INDEX IX_Tags_TagName ON Tags(TagName);

-- tags historically used with a subject -> powers "related tags" suggestions
CREATE TABLE SubjectTags (
    SubjectId       INT                 NOT NULL REFERENCES Subjects(SubjectId),
    TagId           INT                 NOT NULL REFERENCES Tags(TagId),
    PRIMARY KEY (SubjectId, TagId)
);

CREATE TABLE Records (
    RecordId            UNIQUEIDENTIFIER   PRIMARY KEY DEFAULT NEWID(),
    UserId               INT                NOT NULL REFERENCES Users(UserId),
    DepartmentCategoryId INT                NULL REFERENCES Categories(CategoryId),  -- level 1
    CategoryId            INT               NULL REFERENCES Categories(CategoryId),  -- level 2
    SubCategoryId         INT               NULL REFERENCES Categories(CategoryId),  -- level 3
    TypeCategoryId         INT              NULL REFERENCES Categories(CategoryId),  -- level 4
    SubjectId            INT                NOT NULL REFERENCES Subjects(SubjectId),
    Remark               NVARCHAR(MAX)      NULL,
    CreatedOn            DATETIME2          NOT NULL DEFAULT SYSUTCDATETIME()
);
CREATE INDEX IX_Records_SubjectId ON Records(SubjectId);
CREATE INDEX IX_Records_UserId ON Records(UserId);
CREATE INDEX IX_Records_CreatedOn ON Records(CreatedOn);

CREATE TABLE RecordFiles (
    FileId          INT IDENTITY(1,1)   PRIMARY KEY,
    RecordId        UNIQUEIDENTIFIER    NOT NULL REFERENCES Records(RecordId),
    OriginalName    NVARCHAR(300)       NOT NULL,
    StoredName      NVARCHAR(300)       NOT NULL,   -- GUID-based name on disk, prevents path traversal
    FileExtension   NVARCHAR(20)        NOT NULL,
    FileSizeBytes   BIGINT              NOT NULL,
    UploadedOn      DATETIME2           NOT NULL DEFAULT SYSUTCDATETIME()
);
CREATE INDEX IX_RecordFiles_RecordId ON RecordFiles(RecordId);

CREATE TABLE RecordTags (
    RecordId        UNIQUEIDENTIFIER    NOT NULL REFERENCES Records(RecordId),
    TagId           INT                 NOT NULL REFERENCES Tags(TagId),
    PRIMARY KEY (RecordId, TagId)
);
