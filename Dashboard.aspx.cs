using System;
using System.Web.Script.Services;
using System.Web.Services;
using DataTracking.Helpers;
using MySqlConnector;
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
                string name = null;
                try
                {
                    name = LoginDb.GetNameByToken(token);
                }
                catch
                {
                    // LoginDb connection string is a placeholder until the real Azure MySQL host is supplied.
                }

                if (name != null)
                {
                    result["found"] = true;
                    result["name"] = name;
                }
            }

            return JsonConvert.SerializeObject(result);
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static string GetStats(string token)
        {
            int records = 0, departments = 0, tags = 0, mine = 0;

            try
            {
                using (var conn = AppDb.Open())
                {
                    using (var cmd = new MySqlCommand("SELECT COUNT(*) FROM Records", conn))
                        records = Convert.ToInt32(cmd.ExecuteScalar());

                    using (var cmd = new MySqlCommand("SELECT COUNT(*) FROM Categories WHERE Level = 1 AND IsActive = 1", conn))
                        departments = Convert.ToInt32(cmd.ExecuteScalar());

                    using (var cmd = new MySqlCommand("SELECT COUNT(*) FROM Tags", conn))
                        tags = Convert.ToInt32(cmd.ExecuteScalar());

                    if (!string.IsNullOrWhiteSpace(token))
                    {
                        using (var cmd = new MySqlCommand("SELECT COUNT(*) FROM Records WHERE Token = @token", conn))
                        {
                            cmd.Parameters.AddWithValue("@token", token);
                            mine = Convert.ToInt32(cmd.ExecuteScalar());
                        }
                    }
                }
            }
            catch
            {
                // AppDb connection string is a placeholder until the real Azure MySQL host is supplied.
            }

            var result = new JObject
            {
                ["records"] = records,
                ["departments"] = departments,
                ["tags"] = tags,
                ["mine"] = mine
            };

            return JsonConvert.SerializeObject(result);
        }
    }
}
