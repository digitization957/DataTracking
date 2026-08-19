using System;
using System.Linq;
using System.Web.Script.Services;
using System.Web.Services;
using DataTracking.Helpers;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace DataTracking
{
    public partial class Repository : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static string GetCategories()
        {
            var data = JsonStore.Read("categories.json") as JArray ?? new JArray();
            return JsonConvert.SerializeObject(data);
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static string SearchTags(string term)
        {
            var tags = JsonStore.Read("tags.json") as JArray ?? new JArray();
            term = (term ?? "").Trim().ToLowerInvariant();

            var matches = tags
                .Select(t => t.ToString())
                .Where(t => t.ToLowerInvariant().Contains(term))
                .Take(8)
                .ToList();

            return JsonConvert.SerializeObject(matches);
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static string SearchRecords(string department, string category, string subCategory, string type,
            string subject, string[] tags, string dateFrom, string dateTo)
        {
            var records = JsonStore.Read("records.json") as JArray ?? new JArray();
            var users = JsonStore.Read("users.json") as JObject ?? new JObject();

            var query = records.Cast<JObject>().AsEnumerable();

            if (!string.IsNullOrWhiteSpace(department))
                query = query.Where(r => string.Equals((string)r["department"], department, StringComparison.OrdinalIgnoreCase));
            if (!string.IsNullOrWhiteSpace(category))
                query = query.Where(r => string.Equals((string)r["category"], category, StringComparison.OrdinalIgnoreCase));
            if (!string.IsNullOrWhiteSpace(subCategory))
                query = query.Where(r => string.Equals((string)r["subCategory"], subCategory, StringComparison.OrdinalIgnoreCase));
            if (!string.IsNullOrWhiteSpace(type))
                query = query.Where(r => string.Equals((string)r["type"], type, StringComparison.OrdinalIgnoreCase));

            if (!string.IsNullOrWhiteSpace(subject))
            {
                string s = subject.Trim().ToLowerInvariant();
                query = query.Where(r => ((string)r["subject"] ?? "").ToLowerInvariant().Contains(s));
            }

            if (tags != null && tags.Length > 0)
            {
                var wanted = tags.Select(t => t.ToLowerInvariant()).ToList();
                query = query.Where(r => (r["tags"] as JArray != null) &&
                    ((JArray)r["tags"]).Select(t => t.ToString().ToLowerInvariant()).Any(t => wanted.Contains(t)));
            }

            DateTime fromDate, toDate;
            if (!string.IsNullOrWhiteSpace(dateFrom) && DateTime.TryParse(dateFrom, out fromDate))
                query = query.Where(r => (DateTime)r["createdOn"] >= fromDate);
            if (!string.IsNullOrWhiteSpace(dateTo) && DateTime.TryParse(dateTo, out toDate))
                query = query.Where(r => (DateTime)r["createdOn"] <= toDate.AddDays(1));

            var result = query
                .OrderByDescending(r => (DateTime)r["createdOn"])
                .Select(r =>
                {
                    string token = (string)r["token"];
                    var user = users[token];
                    var clone = (JObject)r.DeepClone();
                    clone["uploaderName"] = user != null ? (string)user["name"] : (token ?? "Unknown");
                    return clone;
                })
                .ToList();

            return JsonConvert.SerializeObject(result);
        }
    }
}
