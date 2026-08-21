// Resolves the token + role the user arrived with: either a JWT (?jwt=header.payload.sig,
// or a raw base64url payload) or a plain query string (?token=...&role=...).
// Persists both in sessionStorage so pages navigated to without a query string still work.
var DTAuth = (function () {
    function b64UrlDecode(str) {
        str = str.replace(/-/g, "+").replace(/_/g, "/");
        while (str.length % 4) { str += "="; }
        return decodeURIComponent(escape(atob(str)));
    }

    function decodeJwtPayload(jwt) {
        var segment = jwt.indexOf(".") !== -1 ? jwt.split(".")[1] : jwt;
        return JSON.parse(b64UrlDecode(segment));
    }

    function resolve() {
        var params = new URLSearchParams(window.location.search);
        var token = params.get("token");
        var role = params.get("role");
        var jwt = params.get("jwt");

        if (jwt) {
            try {
                var payload = decodeJwtPayload(jwt);
                token = token || payload.token || payload.Token;
                role = role || payload.role || payload.Role;
            } catch (ex) { /* malformed jwt, fall back to whatever else we have */ }
        }

        if (token) {
            sessionStorage.setItem("dt_token", token);
            sessionStorage.setItem("dt_role", role || "");
        }

        token = token || sessionStorage.getItem("dt_token");
        role = role || sessionStorage.getItem("dt_role") || "";

        if (!token) {
            window.location.href = "Login.aspx";
            return null;
        }

        return { token: token, role: role };
    }

    function logout() {
        sessionStorage.clear();
        window.location.href = "Login.aspx";
    }

    return { resolve: resolve, logout: logout };
})();
