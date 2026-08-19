<%@ Page Title="Dashboard" Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="DataTracking.Dashboard" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Dashboard - Data Tracking</title>
    <link href="Content/bootstrap.min.css" rel="stylesheet" />
    <style>
        body { background: #f2f4f7; }
        .topbar { background: #212529; color: #fff; padding: 12px 24px; display: flex; justify-content: space-between; align-items: center; }
        .card-box { background: #fff; border-radius: 8px; padding: 20px; box-shadow: 0 1px 6px rgba(0,0,0,0.06); margin: 20px; }
        .role-badge { background: #0d6efd; color: #fff; padding: 3px 10px; border-radius: 12px; font-size: 12px; }
        .admin-only { display: none; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="topbar">
            <div>Data Tracking</div>
            <div>
                <span id="lblUser">Loading...</span>
                <span class="role-badge" id="lblRole"></span>
                <button type="button" id="btnLogout" class="btn btn-sm btn-outline-light ms-2">Logout</button>
            </div>
        </div>

        <div class="card-box">
            <h4>Welcome</h4>
            <p id="lblWelcome">Fetching your details...</p>
            <a href="Upload.aspx" class="btn btn-primary">Go to Upload / Repository</a>
            <a href="#" class="btn btn-outline-secondary admin-only" id="btnAdmin">Manage Users (Admin)</a>
        </div>
    </form>

    <script src="Scripts/jquery-3.7.0.min.js"></script>
    <script>
        function b64Decode(str) {
            return decodeURIComponent(escape(atob(str)));
        }

        function getParam(name) {
            var params = new URLSearchParams(window.location.search);
            return params.get(name);
        }

        $(function () {
            var jwt = getParam("jwt") || sessionStorage.getItem("dt_jwt");
            if (!jwt) {
                window.location.href = "Login.aspx";
                return;
            }

            var parts;
            try {
                parts = b64Decode(jwt).split("|");
            } catch (ex) {
                window.location.href = "Login.aspx";
                return;
            }

            var token = parts[0];
            var role = parts[1];

            sessionStorage.setItem("dt_token", token);
            sessionStorage.setItem("dt_role", role);
            sessionStorage.setItem("dt_jwt", jwt);

            $("#lblRole").text(role);

            if (role === "Admin") {
                $(".admin-only").show();
            }

            $.ajax({
                type: "POST",
                url: "Dashboard.aspx/GetUserInfo",
                data: JSON.stringify({ token: token }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var data = JSON.parse(res.d);
                    if (data.found) {
                        $("#lblUser").text(data.name);
                        $("#lblWelcome").text("Hello " + data.name + " (" + data.department + "), you are logged in as " + role + ".");
                    } else {
                        $("#lblUser").text("Guest");
                        $("#lblWelcome").text("Token not recognized in records. You are logged in as " + role + ".");
                    }
                },
                error: function () {
                    $("#lblWelcome").text("Could not fetch user details.");
                }
            });

            $("#btnLogout").on("click", function () {
                sessionStorage.clear();
                window.location.href = "Login.aspx";
            });
        });
    </script>
</body>
</html>
