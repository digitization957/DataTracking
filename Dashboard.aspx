<%@ Page Title="Dashboard" Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="DataTracking.Dashboard" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Dashboard - Data Tracking</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@600;700&family=Inter:wght@400;500;600&family=JetBrains+Mono:wght@400;500&display=swap" />
    <link href="Content/tokens.css" rel="stylesheet" />
    <link href="Content/app.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="topbar">
            <div class="topbar-brand"><div class="topbar-mark">DT</div><span>Data Tracking</span></div>
            <div class="topbar-right">
                <div class="topbar-nav">
                    <a href="Dashboard.aspx" aria-current="page">Dashboard</a>
                    <a href="Upload.aspx">Upload</a>
                    <a href="Repository.aspx">Repository</a>
                    <div class="nav-dropdown" id="masterNav">
                        <button type="button" class="nav-dropdown-toggle" id="masterToggle">Master <span class="chev">&#9662;</span></button>
                        <div class="nav-dropdown-menu">
                            <a href="Master.aspx">Dropdown options</a>
                        </div>
                    </div>
                </div>
                <span class="user-chip" id="lblUser">Loading…</span>
                <button type="button" id="btnLogout" class="btn btn-ghost btn-sm">Logout</button>
            </div>
        </div>

        <div class="app-content">
            <div class="panel">
                <div class="panel-head">
                    <h2 id="lblWelcomeHead">Welcome</h2>
                    <p class="lead" id="lblWelcome">Fetching your details…</p>
                </div>
                <a href="Upload.aspx" class="btn btn-primary">Upload files</a>
                <a href="Repository.aspx" class="btn btn-outline" style="margin-left:var(--space-sm);">Browse repository</a>
            </div>

            <div class="stat-strip">
                <div class="stat-tile"><div class="n mono" id="statRecords">—</div><div class="l">Records in repository</div></div>
                <div class="stat-tile"><div class="n mono" id="statDepts">—</div><div class="l">Departments</div></div>
                <div class="stat-tile"><div class="n mono" id="statTags">—</div><div class="l">Known tags</div></div>
                <div class="stat-tile"><div class="n mono" id="statMine">—</div><div class="l">Uploaded by you</div></div>
            </div>
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
            $("#masterToggle").on("click", function (e) {
                e.stopPropagation();
                $("#masterNav").toggleClass("open");
            });
            $(document).on("click", function () { $("#masterNav").removeClass("open"); });

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

            sessionStorage.setItem("dt_token", token);
            sessionStorage.setItem("dt_jwt", jwt);

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
                        $("#lblWelcome").text("Hello " + data.name + " (" + data.department + ").");
                    } else {
                        $("#lblUser").text("Guest");
                        $("#lblWelcome").text("Token not recognized in records.");
                    }
                },
                error: function () {
                    $("#lblWelcome").text("Could not fetch user details.");
                }
            });

            $.ajax({
                type: "POST",
                url: "Dashboard.aspx/GetStats",
                data: JSON.stringify({ token: token }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (res) {
                    var s = JSON.parse(res.d);
                    $("#statRecords").text(s.records);
                    $("#statDepts").text(s.departments);
                    $("#statTags").text(s.tags);
                    $("#statMine").text(s.mine);
                },
                error: function () {
                    $(".stat-tile .n").text("—");
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
