using System;
using System.Linq;
using System.Web.Script.Services;
using System.Web.Services;
using DataTracking.Helpers;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace DataTracking
{
    public partial class Upload : System.Web.UI.Page
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
        public static string SearchSubjects(string term)
        {
            var subjects = JsonStore.Read("subjects.json") as JArray ?? new JArray();
            term = (term ?? "").Trim().ToLowerInvariant();

            var matches = subjects
                .Where(s => (s["subject"]?.ToString() ?? "").ToLowerInvariant().Contains(term))
                .Take(8)
                .ToList();

            return JsonConvert.SerializeObject(matches);
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
    }
}
