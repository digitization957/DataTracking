# Task Log

- Built dummy Login page (Token + Role) that generates a base64 JWT-like string and redirects to Dashboard.
- Built Dashboard page that decodes JWT client-side, fetches user info from dummy DB (App_Data/users.json) via WebMethod, shows role-based UI.
- Built Upload page with 4 cascading category dropdowns, smart subject autocomplete, remark, multi-file upload (up to 8: pdf/image/msg/excel/word/ppt), and tag input with autocomplete + related-tag suggestions.
- Added UploadHandler.ashx to validate & save files (extension whitelist, size limit, GUID filenames) and persist record/subject/tag metadata to JSON files in App_Data.
- Added Helpers/JsonStore.cs for reading/writing JSON data files.
- Hardened Web.config (request size limits) for file upload support; all data/UI logic uses plain HTML/JS/AJAX + WebMethods only, no MVC controllers.
- Added Database/schema.sql with the real table design (Users, Categories, Subjects, Tags, Records, RecordFiles, RecordTags, SubjectTags).
- Published two Claude artifacts: a schema/flow reference sheet, and a fully clickable Login → Dashboard → Upload demo of the whole app.
- Simplified to a single role: removed the Role dropdown from Login and all role branching from Dashboard/Upload.
- Added Repository.aspx: filterable file/log browser (department/category/subject/tags/date), with inline PDF/image preview, .msg served for direct Outlook open, and download for Office files.
- Added FileHandler.ashx to stream stored files securely (record/file validated against records.json, GUID-based paths, no path traversal).
- Rebuilt the "DataTracking Console" Claude artifact into a full clickable prototype of Login → Dashboard → Upload → Repository, including live file preview for uploaded images/PDFs.
- Redesigned the whole app UI/UX (Hallmark): new Cobalt design system (design.md + Content/tokens.css + Content/app.css) replacing Bootstrap defaults; Login is now an auth card, Dashboard an instrument panel with real record/tag/department counts (new GetStats WebMethod), Upload a two-pane workbench, Repository a filter-rail data browser. All existing element IDs/AJAX contracts preserved untouched.
- Wired Dashboard's name lookup to the org's existing Access DB (login_tokenpass: Token, Name) via a new parameterized Helpers/LoginDb.cs (OleDb) and a dummy "LoginDb" connection string in Web.config — falls back to App_Data/users.json if the DB isn't reachable yet. Added Database/schema.md documenting the full app schema (external login_tokenpass + the app's own SQL Server tables).
- Switched target DB from Access/SQL Server to Azure Database for MySQL (two separate databases: LoginDb for login_tokenpass, AppDb for the app's own tables). Vendored MySqlConnector 2.3.7 (packages.config + csproj reference), rewrote Helpers/LoginDb.cs to use it, added dummy AppDb/LoginDb MySQL connection strings in Web.config, converted Database/schema.sql to MySQL DDL, and updated schema.md.
