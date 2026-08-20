using System;
using System.Linq;
using System.Web.Script.Services;
using System.Web.Services;
using DataTracking.Helpers;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace DataTracking
{
    public partial class Dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static string GetUserInfo(string token)
        {
            var result = new JObject { ["found"] = false };

            if (!string.IsNullOrWhiteSpace(token))
            {
                var users = JsonStore.Read("users.json") as JObject;
                if (users != null && users[token] != null)
                {
                    var u = users[token];
                    result["found"] = true;
                    result["name"] = u["name"];
                    result["department"] = u["department"];
                    result["email"] = u["email"];
                }
            }

            return JsonConvert.SerializeObject(result);
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static string GetStats(string token)
        {
            var records = JsonStore.Read("records.json") as JArray ?? new JArray();
            var categories = JsonStore.Read("categories.json") as JArray ?? new JArray();
            var tags = JsonStore.Read("tags.json") as JArray ?? new JArray();

            int deptCount = categories.Count(c => (int?)c["level"] == 1);
            int mine = string.IsNullOrWhiteSpace(token)
                ? 0
                : records.Count(r => string.Equals((string)r["token"], token, StringComparison.OrdinalIgnoreCase));

            var result = new JObject
            {
                ["records"] = records.Count,
                ["departments"] = deptCount,
                ["tags"] = tags.Count,
                ["mine"] = mine
            };

            return JsonConvert.SerializeObject(result);
        }
    }
}
