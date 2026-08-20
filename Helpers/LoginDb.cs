using System.Configuration;
using System.Data.OleDb;

namespace DataTracking.Helpers
{
    /// <summary>
    /// Reads Name by Token from the org's existing Access database (login_tokenpass table).
    /// Connection string "LoginDb" in Web.config is a dummy placeholder until the real
    /// .accdb path is supplied.
    /// </summary>
    public static class LoginDb
    {
        public static string GetNameByToken(string token)
        {
            var connectionString = ConfigurationManager.ConnectionStrings["LoginDb"]?.ConnectionString;
            if (string.IsNullOrWhiteSpace(connectionString) || string.IsNullOrWhiteSpace(token))
                return null;

            using (var conn = new OleDbConnection(connectionString))
            using (var cmd = new OleDbCommand("SELECT [Name] FROM [login_tokenpass] WHERE [Token] = ?", conn))
            {
                cmd.Parameters.AddWithValue("?", token);
                conn.Open();
                var result = cmd.ExecuteScalar();
                return result == null || result is System.DBNull ? null : result.ToString();
            }
        }
    }
}
