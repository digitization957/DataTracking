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

    function tryDecode(str) {
        if (!str) return str;
        try { return b64UrlDecode(str); } catch (ex) { return str; }
    }

    function resolve() {
        var params = new URLSearchParams(window.location.search);
        var token = tryDecode(params.get("token"));
        var role = tryDecode(params.get("role"));
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

    function initials(label) {
        if (!label) return "?";
        var parts = String(label).trim().split(/\s+/);
        var chars = parts.length > 1 ? parts[0][0] + parts[1][0] : parts[0].slice(0, 2);
        return chars.toUpperCase();
    }

    // Fills the shared user-menu markup (avatar, name, role, token) present on every page's topbar.
    function renderUserMenu(name, role, token) {
        var label = name || token;
        var $ = window.jQuery;
        $("#userAvatar, #userAvatarLg").text(initials(name || token));
        $("#lblUser, #userPopName").text(label);
        $("#userPopRole").text(role || "Unknown");
        $("#userToken").text(token);
    }

    // Wires a nav-dropdown toggle button + click-outside-to-close, shared by Master/user menus.
    function bindDropdown(toggleSelector, navSelector) {
        var $ = window.jQuery;
        $(toggleSelector).on("click", function (e) {
            e.stopPropagation();
            $(navSelector).toggleClass("open");
        });
    }

    function bindGlobalDropdownClose() {
        window.jQuery(document).on("click", function () {
            window.jQuery(".nav-dropdown.open").removeClass("open");
        });
    }

    return {
        resolve: resolve,
        logout: logout,
        initials: initials,
        renderUserMenu: renderUserMenu,
        bindDropdown: bindDropdown,
        bindGlobalDropdownClose: bindGlobalDropdownClose
    };
})();
