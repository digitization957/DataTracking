using System;
using System.IO;
using System.Web;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace DataTracking.Helpers
{
    public static class JsonStore
    {
        private static readonly object FileLock = new object();

        private static string MapPath(string fileName)
        {
            return HttpContext.Current.Server.MapPath("~/App_Data/" + fileName);
        }

        public static JToken Read(string fileName)
        {
            lock (FileLock)
            {
                string path = MapPath(fileName);
                if (!File.Exists(path)) return null;
                string content = File.ReadAllText(path);
                return string.IsNullOrWhiteSpace(content) ? null : JToken.Parse(content);
            }
        }

        public static void Write(string fileName, JToken data)
        {
            lock (FileLock)
            {
                string path = MapPath(fileName);
                File.WriteAllText(path, data.ToString(Formatting.Indented));
            }
        }
    }
}
