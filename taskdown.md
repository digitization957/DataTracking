# Task Log

- Built dummy Login page (Token + Role) that generates a base64 JWT-like string and redirects to Dashboard.
- Built Dashboard page that decodes JWT client-side, fetches user info from dummy DB (App_Data/users.json) via WebMethod, shows role-based UI.
- Built Upload page with 4 cascading category dropdowns, smart subject autocomplete, remark, multi-file upload (up to 8: pdf/image/msg/excel/word/ppt), and tag input with autocomplete + related-tag suggestions.
- Added UploadHandler.ashx to validate & save files (extension whitelist, size limit, GUID filenames) and persist record/subject/tag metadata to JSON files in App_Data.
- Added Helpers/JsonStore.cs for reading/writing JSON data files.
- Hardened Web.config (request size limits) for file upload support; all data/UI logic uses plain HTML/JS/AJAX + WebMethods only, no MVC controllers.
