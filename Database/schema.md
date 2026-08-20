# DataTracking — Database Schema

Full schema needed to run this app for real, replacing the `App_Data/*.json`
dummy files. Two **separate Azure Database for MySQL** databases:

- **LoginDb** — the org's existing login database (this app only reads from it).
- **AppDb** — this app's own data (Categories, Subjects, Tags, Records, files, tags).

Both are wired via `MySqlConnector` (NuGet package) and connection strings in
`Web.config`. Both connection strings are currently **dummy placeholders** —
replace host/database/credentials before go-live.

```xml
<!-- Web.config -->
<add name="LoginDb" connectionString="Server=login-db.mysql.database.azure.com;Port=3306;Database=login_auth;Uid=REPLACE_ME;Pwd=REPLACE_ME;SslMode=Required;" providerName="MySqlConnector" />
<add name="AppDb"   connectionString="Server=datatracking-db.mysql.database.azure.com;Port=3306;Database=datatracking;Uid=REPLACE_ME;Pwd=REPLACE_ME;SslMode=Required;" providerName="MySqlConnector" />
```

## 1. Login source — LoginDb (existing, external to this app)

The app looks up the logged-in person's name from a table that already
exists in the org's MySQL Azure login database — this app does not own or
create this table, only reads from it.

| Table | Columns used | Notes |
| --- | --- | --- |
| `login_tokenpass` | `Token`, `Name` | Looked up by `Token` on every Dashboard load via `Helpers/LoginDb.cs`. Other columns may exist in the real table; only these two are read. |

**Still needed from you** before go-live: the real Azure MySQL host, database
name, and credentials for `LoginDb` in `Web.config`.

## 2. App-owned tables — AppDb (`schema.sql`, MySQL DDL)

| Table | Purpose |
| --- | --- |
| `Users` | Local copy of person info keyed by `Token` (department/email/role) — used everywhere in the app *besides* the name lookup, which comes from `login_tokenpass` in LoginDb. |
| `Categories` | 4-level department → category → sub-category → type tree. Self-referencing via `ParentId`. Managed from the app's **Master** screen (`Master.aspx`) — admins add/delete options here instead of editing data directly; delete cascades to all descendant rows. |
| `Subjects` | Distinct subject lines typed on Upload, reused for autocomplete. |
| `Tags` | Master tag list, reused for autocomplete. |
| `SubjectTags` | Tags historically used with a subject — powers "related tags" suggestions. |
| `Records` | One row per uploaded item: who, classification path, subject, remark, timestamp. `RecordId` is a 32-char hex GUID (no dashes), matching the GUIDs already used for on-disk upload folders. |
| `RecordFiles` | Files attached to a record — GUID-based stored name, original name, extension, size. |
| `RecordTags` | Many-to-many: tags applied to a record. |

See `Database/schema.sql` for full column definitions, types, and indexes —
this file is the narrative map; `schema.sql` is the source of truth for DDL.
`schema.sql` targets AppDb; nothing in it touches LoginDb.

## 3. How login works today (code already wired)

1. User enters a token on Login (unchanged).
2. Dashboard calls `GetUserInfo(token)` (`Dashboard.aspx.cs`).
3. `GetUserInfo` calls `Helpers/LoginDb.cs`, which queries **`login_tokenpass`**
   in LoginDb for `Name` where `Token` matches (parameterized, no string
   concatenation).
4. If LoginDb isn't reachable yet (dummy connection string), it falls back to
   `App_Data/users.json`'s `name` field so the app keeps working in dev.
5. Department/email still come from the app's own `Users` table (today:
   `App_Data/users.json`; once AppDb is live, the `Users` table above), joined
   by `Token` — `login_tokenpass` only carries `Name`.

## 4. Still to do

- Point `AppDb` at the real Azure MySQL instance and run `schema.sql` against it.
- Migrate `Categories`/`Subjects`/`Tags`/`Records`/`RecordFiles`/`RecordTags`
  reads and writes (`Upload.aspx.cs`, `Repository.aspx.cs`, `Master.aspx.cs`,
  `UploadHandler.ashx.cs`, `FileHandler.ashx.cs`) from `App_Data/*.json`
  (`Helpers/JsonStore.cs`) to AppDb — not done yet, only the login lookup has
  been migrated so far. `Master.aspx.cs`'s recursive delete maps to a single
  `DELETE ... WHERE CategoryId = @id` once live, since `FK_Categories_Parent`
  is `ON DELETE CASCADE`.
- Point `LoginDb` at the real Azure MySQL login database and remove the
  `users.json` fallback once confirmed reachable.
