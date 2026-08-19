<%@ Page Title="Login" Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="DataTracking.Login" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Login - Data Tracking</title>
    <link href="Content/bootstrap.min.css" rel="stylesheet" />
    <style>
        body { background: #f2f4f7; }
        .login-box { max-width: 380px; margin: 80px auto; padding: 30px; background: #fff; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.08); }
        .login-box h3 { margin-bottom: 20px; }
        .err-msg { color: #c0392b; font-size: 13px; margin-top: 8px; display: none; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="login-box">
            <h3>Data Tracking Login</h3>
            <div class="mb-3">
                <label class="form-label">Token</label>
                <input type="text" id="txtToken" class="form-control" maxlength="100" placeholder="Enter your token" autocomplete="off" />
            </div>
            <div class="mb-3">
                <label class="form-label">Role</label>
                <select id="ddlRole" class="form-select">
                    <option value="">-- Select Role --</option>
                    <option value="Admin">Admin</option>
                    <option value="Manager">Manager</option>
                    <option value="Employee">Employee</option>
                    <option value="Viewer">Viewer</option>
                </select>
            </div>
            <button type="button" id="btnLogin" class="btn btn-primary w-100">Login</button>
            <div class="err-msg" id="errMsg">Please enter token and select a role.</div>
        </div>
    </form>

    <script src="Scripts/jquery-3.7.0.min.js"></script>
    <script>
        function b64Encode(str) {
            return btoa(unescape(encodeURIComponent(str)));
        }

        $(function () {
            $("#btnLogin").on("click", function () {
                var token = $.trim($("#txtToken").val());
                var role = $("#ddlRole").val();

                if (!token || !role) {
                    $("#errMsg").show();
                    return;
                }
                $("#errMsg").hide();

                var payload = token + "|" + role + "|" + Date.now();
                var jwt = b64Encode(payload);

                sessionStorage.setItem("dt_token", token);
                sessionStorage.setItem("dt_role", role);
                sessionStorage.setItem("dt_jwt", jwt);

                window.location.href = "Dashboard.aspx?jwt=" + encodeURIComponent(jwt);
            });

            $("#txtToken").on("keypress", function (e) {
                if (e.which === 13) { $("#btnLogin").click(); }
            });
        });
    </script>
</body>
</html>
