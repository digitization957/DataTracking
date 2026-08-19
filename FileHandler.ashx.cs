using System;
using System.IO;
using System.Linq;
using System.Web;
using DataTracking.Helpers;
using Newtonsoft.Json.Linq;

namespace DataTracking
{
    public class FileHandler : IHttpHandler
    {
        public bool IsReusable { get { return false; } }

        // extensions that are safe to render directly in the browser tab
        private static readonly string[] InlineExtensions = { ".pdf", ".jpg", ".jpeg", ".png", ".gif" };

        public void ProcessRequest(HttpContext context)
        {
            string recordId = context.Request.QueryString["recordId"];
            string storedName = context.Request.QueryString["file"];

            Guid parsedId;
            if (string.IsNullOrWhiteSpace(recordId) || !Guid.TryParse(recordId, out parsedId) ||
                string.IsNullOrWhiteSpace(storedName))
            {
                context.Response.StatusCode = 400;
                return;
            }

            var records = JsonStore.Read("records.json") as JArray;
            var record = records?.FirstOrDefault(r => string.Equals((string)r["id"], recordId, StringComparison.OrdinalIgnoreCase));
            if (record == null)
            {
                context.Response.StatusCode = 404;
                return;
            }

            var fileEntry = (record["files"] as JArray)?
                .FirstOrDefault(f => string.Equals((string)f["storedName"], storedName, StringComparison.OrdinalIgnoreCase));
            if (fileEntry == null)
            {
                context.Response.StatusCode = 404;
                return;
            }

            string safeStoredName = Path.GetFileName(storedName);
            string uploadRoot = context.Server.MapPath("~/App_Data/Uploads/" + parsedId.ToString("N"));
            string filePath = Path.Combine(uploadRoot, safeStoredName);

            if (!Path.GetFullPath(filePath).StartsWith(Path.GetFullPath(uploadRoot), StringComparison.OrdinalIgnoreCase) ||
                !File.Exists(filePath))
            {
                context.Response.StatusCode = 404;
                return;
            }

            string originalName = (string)fileEntry["originalName"] ?? safeStoredName;
            string ext = Path.GetExtension(safeStoredName).ToLowerInvariant();

            context.Response.Clear();
            context.Response.ContentType = MimeTypeFor(ext);
            context.Response.Headers["X-Content-Type-Options"] = "nosniff";

            bool inline = InlineExtensions.Contains(ext);
            context.Response.AddHeader("Content-Disposition",
                (inline ? "inline" : "attachment") + "; filename=\"" + SanitizeForHeader(originalName) + "\"");

            context.Response.TransmitFile(filePath);
        }

        private static string SanitizeForHeader(string name)
        {
            var clean = new string(name.Where(c => c != '"' && c != '\r' && c != '\n').ToArray());
            return string.IsNullOrWhiteSpace(clean) ? "file" : clean;
        }

        private static string MimeTypeFor(string ext)
        {
            switch (ext)
            {
                case ".pdf": return "application/pdf";
                case ".jpg":
                case ".jpeg": return "image/jpeg";
                case ".png": return "image/png";
                case ".gif": return "image/gif";
                case ".msg": return "application/vnd.ms-outlook";
                case ".xls": return "application/vnd.ms-excel";
                case ".xlsx": return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
                case ".doc": return "application/msword";
                case ".docx": return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
                case ".ppt": return "application/vnd.ms-powerpoint";
                case ".pptx": return "application/vnd.openxmlformats-officedocument.presentationml.presentation";
                default: return "application/octet-stream";
            }
        }
    }
}
