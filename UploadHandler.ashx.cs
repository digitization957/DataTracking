using System;
using System.IO;
using System.Linq;
using System.Web;
using DataTracking.Helpers;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace DataTracking
{
    public class UploadHandler : IHttpHandler
    {
        private static readonly string[] AllowedExtensions =
        {
            ".pdf", ".jpg", ".jpeg", ".png", ".gif",
            ".msg", ".xls", ".xlsx", ".doc", ".docx", ".ppt", ".pptx"
        };

        private const long MaxFileSize = 20 * 1024 * 1024;
        private const int MaxFiles = 8;

        public bool IsReusable { get { return false; } }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";

            try
            {
                var request = context.Request;

                string token = request.Form["token"];
                string role = request.Form["role"];
                string department = request.Form["department"];
                string category = request.Form["category"];
                string subCategory = request.Form["subCategory"];
                string type = request.Form["type"];
                string subject = request.Form["subject"];
                string remark = request.Form["remark"];
                string tagsRaw = request.Form["tags"];

                if (string.IsNullOrWhiteSpace(subject))
                {
                    WriteError(context, "Subject is required.");
                    return;
                }

                if (request.Files.Count == 0 || request.Files.Count > MaxFiles)
                {
                    WriteError(context, "Attach between 1 and " + MaxFiles + " files.");
                    return;
                }

                var recordId = Guid.NewGuid().ToString("N");
                var uploadRoot = context.Server.MapPath("~/App_Data/Uploads/" + recordId);
                Directory.CreateDirectory(uploadRoot);

                var savedFiles = new JArray();

                for (int i = 0; i < request.Files.Count; i++)
                {
                    var file = request.Files[i];
                    if (file == null || file.ContentLength == 0) continue;

                    string ext = Path.GetExtension(file.FileName).ToLowerInvariant();
                    if (!AllowedExtensions.Contains(ext))
                    {
                        WriteError(context, "File type not allowed: " + Path.GetFileName(file.FileName));
                        return;
                    }
                    if (file.ContentLength > MaxFileSize)
                    {
                        WriteError(context, "File too large: " + Path.GetFileName(file.FileName));
                        return;
                    }

                    string safeName = Guid.NewGuid().ToString("N") + ext;
                    string savePath = Path.Combine(uploadRoot, safeName);
                    file.SaveAs(savePath);

                    savedFiles.Add(new JObject
                    {
                        ["originalName"] = Path.GetFileName(file.FileName),
                        ["storedName"] = safeName
                    });
                }

                var tags = string.IsNullOrWhiteSpace(tagsRaw)
                    ? new JArray()
                    : JArray.Parse(tagsRaw);

                var record = new JObject
                {
                    ["id"] = recordId,
                    ["token"] = token,
                    ["role"] = role,
                    ["department"] = department,
                    ["category"] = category,
                    ["subCategory"] = subCategory,
                    ["type"] = type,
                    ["subject"] = subject,
                    ["remark"] = remark,
                    ["tags"] = tags,
                    ["files"] = savedFiles,
                    ["createdOn"] = DateTime.UtcNow.ToString("o")
                };

                var records = JsonStore.Read("records.json") as JArray ?? new JArray();
                records.Add(record);
                JsonStore.Write("records.json", records);

                UpsertSubject(subject, tags);
                UpsertTags(tags);

                context.Response.Write(JsonConvert.SerializeObject(new { success = true, id = recordId }));
            }
            catch (Exception)
            {
                WriteError(context, "Unexpected error while saving.");
            }
        }

        private void WriteError(HttpContext context, string message)
        {
            context.Response.Write(JsonConvert.SerializeObject(new { success = false, message }));
        }

        private void UpsertSubject(string subject, JArray tags)
        {
            var subjects = JsonStore.Read("subjects.json") as JArray ?? new JArray();
            var existing = subjects.FirstOrDefault(s =>
                string.Equals(s["subject"]?.ToString(), subject, StringComparison.OrdinalIgnoreCase));

            if (existing != null)
            {
                var existingTags = (existing["tags"] as JArray) ?? new JArray();
                foreach (var t in tags)
                {
                    if (!existingTags.Any(x => string.Equals(x.ToString(), t.ToString(), StringComparison.OrdinalIgnoreCase)))
                        existingTags.Add(t);
                }
                existing["tags"] = existingTags;
            }
            else
            {
                subjects.Add(new JObject { ["subject"] = subject, ["tags"] = tags });
            }

            JsonStore.Write("subjects.json", subjects);
        }

        private void UpsertTags(JArray tags)
        {
            var master = JsonStore.Read("tags.json") as JArray ?? new JArray();
            foreach (var t in tags)
            {
                if (!master.Any(x => string.Equals(x.ToString(), t.ToString(), StringComparison.OrdinalIgnoreCase)))
                    master.Add(t);
            }
            JsonStore.Write("tags.json", master);
        }
    }
}
