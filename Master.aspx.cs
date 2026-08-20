using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Script.Services;
using System.Web.Services;
using DataTracking.Helpers;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace DataTracking
{
    public partial class MasterData : System.Web.UI.Page
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
        public static string AddCategory(string name, int level, string parentId)
        {
            name = (name ?? "").Trim();
            if (string.IsNullOrEmpty(name) || name.Length > 200)
                return JsonConvert.SerializeObject(new { success = false, message = "Enter a name up to 200 characters." });
            if (level < 1 || level > 4)
                return JsonConvert.SerializeObject(new { success = false, message = "Invalid level." });
            if (level > 1 && string.IsNullOrWhiteSpace(parentId))
                return JsonConvert.SerializeObject(new { success = false, message = "Select a parent first." });

            var data = JsonStore.Read("categories.json") as JArray ?? new JArray();

            if (level > 1)
            {
                var parent = data.FirstOrDefault(c => string.Equals((string)c["id"], parentId, StringComparison.OrdinalIgnoreCase));
                if (parent == null || (int)parent["level"] != level - 1)
                    return JsonConvert.SerializeObject(new { success = false, message = "Parent not found." });
            }

            string parentKey = level == 1 ? null : parentId;
            bool duplicate = data.Any(c =>
                (int)c["level"] == level &&
                string.Equals((string)c["parentId"], parentKey, StringComparison.OrdinalIgnoreCase) &&
                string.Equals((string)c["name"], name, StringComparison.OrdinalIgnoreCase));
            if (duplicate)
                return JsonConvert.SerializeObject(new { success = false, message = "That option already exists here." });

            var item = new JObject
            {
                ["id"] = Guid.NewGuid().ToString("N"),
                ["level"] = level,
                ["parentId"] = parentKey,
                ["name"] = name
            };
            data.Add(item);
            JsonStore.Write("categories.json", data);

            return JsonConvert.SerializeObject(new { success = true, item = item });
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static string DeleteCategory(string id)
        {
            if (string.IsNullOrWhiteSpace(id))
                return JsonConvert.SerializeObject(new { success = false, message = "Missing id." });

            var data = JsonStore.Read("categories.json") as JArray ?? new JArray();

            var toRemove = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            var frontier = new List<string> { id };
            while (frontier.Count > 0)
            {
                var next = new List<string>();
                foreach (var pid in frontier)
                {
                    if (toRemove.Add(pid))
                    {
                        next.AddRange(data
                            .Where(c => string.Equals((string)c["parentId"], pid, StringComparison.OrdinalIgnoreCase))
                            .Select(c => (string)c["id"]));
                    }
                }
                frontier = next;
            }

            var remaining = new JArray(data.Where(c => !toRemove.Contains((string)c["id"])));
            JsonStore.Write("categories.json", remaining);

            return JsonConvert.SerializeObject(new { success = true, removed = toRemove.Count });
        }
    }
}
