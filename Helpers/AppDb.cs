using MySqlConnector;

namespace DataTracking.Helpers
{
    /// <summary>
    /// Connection helper for this app's own Azure Database for MySQL (Categories,
    /// Subjects, Tags, Records, RecordFiles, RecordTags). Connection string "AppDb"
    /// in Web.config is a dummy placeholder until the real Azure MySQL host/credentials
    /// are supplied.
    /// </summary>
    public static class AppDb
    {
        public static string ConnectionString
        {
            get
            {
                return System.Configuration.ConfigurationManager
                    .ConnectionStrings["AppDb"]?.ConnectionString;
            }
        }

        public static MySqlConnection Open()
        {
            var conn = new MySqlConnection(ConnectionString);
            conn.Open();
            return conn;
        }
    }
}
