using System;
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
    }
}
