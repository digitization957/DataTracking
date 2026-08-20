# DataTracking — Database Schema

Full schema needed to run this app for real, replacing the `App_Data/*.json`
dummy files. Two sources: an **existing external Access database** used for
login lookup, and the **app's own tables** (SQL Server, see `schema.sql`).

## 1. Login source — existing Access database (external)

The app looks up the logged-in person's name from a table that already
exists in an organisation Access database — this app does not own or create
this table, only reads from it.

| Table | Columns used | Notes |
| --- | --- | --- |
| `login_tokenpass` | `Token`, `Name` | Looked up by `Token` on every Dashboard load. Other columns may exist in the real table; only these two are read. |

**Still needed from you** to wire this up in code: the `.accdb`/`.mdb` file
path (or DSN) reachable from the web server, and confirmation of the exact
column names/types if they differ from `Token` (text) / `Name` (text).

## 2. App-owned tables (SQL Server — `schema.sql`)

| Table | Purpose |
| --- | --- |
| `Users` | Local copy of person info keyed by `Token` (department/email/role) — used everywhere in the app *besides* the name lookup, which now comes from `login_tokenpass`. |
| `Categories` | 4-level department → category → sub-category → type tree. Self-referencing via `ParentId`. |
| `Subjects` | Distinct subject lines typed on Upload, reused for autocomplete. |
| `Tags` | Master tag list, reused for autocomplete. |
| `SubjectTags` | Tags historically used with a subject — powers "related tags" suggestions. |
| `Records` | One row per uploaded item: who, classification path, subject, remark, timestamp. |
| `RecordFiles` | Files attached to a record — GUID-based stored name, original name, extension, size. |
| `RecordTags` | Many-to-many: tags applied to a record. |

See `Database/schema.sql` for full column definitions, types, and indexes —
this file is the narrative map; `schema.sql` is the source of truth for DDL.

## 3. How login will work once wired

1. User enters a token on Login (unchanged).
2. Dashboard calls `GetUserInfo(token)`.
3. `GetUserInfo` queries **`login_tokenpass`** in the Access database for
   `Name` where `Token` matches — this replaces today's `App_Data/users.json`
   lookup.
4. Department/email (not present in `login_tokenpass`) continue to come from
   the app's own `Users` table, joined by `Token`, until/unless the org
   database carries more fields we should read instead.
