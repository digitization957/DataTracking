<%@ Page Title="Repository" Language="C#" AutoEventWireup="true" CodeBehind="Repository.aspx.cs" Inherits="DataTracking.Repository" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Repository - Data Tracking</title>
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
                    <a href="Dashboard.aspx">Dashboard</a>
                    <a href="Upload.aspx">Upload</a>
                    <a href="Repository.aspx" aria-current="page">Repository</a>
                </div>
                <span class="user-chip" id="lblUser"></span>
            </div>
        </div>

        <div class="app-content">
            <div class="panel-head" style="margin-bottom:var(--space-lg);">
                <h2>Repository</h2>
                <p class="lead">Filter across department, subject, tags and date.</p>
            </div>

            <div class="browser-layout">
                <div class="panel filter-rail">
                    <div class="field" style="margin-bottom:var(--space-sm);">
                        <label>Department</label>
                        <select id="ddl1"><option value="">-- Any --</option></select>
                    </div>
                    <div class="field" style="margin-bottom:var(--space-sm);">
                        <label>Category</label>
                        <select id="ddl2" disabled><option value="">-- Any --</option></select>
                    </div>
                    <div class="field" style="margin-bottom:var(--space-sm);">
                        <label>Sub-Category</label>
                        <select id="ddl3" disabled><option value="">-- Any --</option></select>
                    </div>
                    <div class="field" style="margin-bottom:var(--space-md);">
                        <label>Type</label>
                        <select id="ddl4" disabled><option value="">-- Any --</option></select>
                    </div>

                    <div class="field" style="margin-bottom:var(--space-sm);">
                        <label>Subject contains</label>
                        <input type="text" id="txtSubject" autocomplete="off" />
                    </div>
                    <div class="field" style="margin-bottom:var(--space-sm);">
                        <label>From date</label>
                        <input type="date" id="txtFrom" />
                    </div>
                    <div class="field" style="margin-bottom:var(--space-md);">
                        <label>To date</label>
                        <input type="date" id="txtTo" />
                    </div>

                    <div class="field suggest-box" style="margin-bottom:var(--space-lg);">
                        <label>Tags</label>
                        <input type="text" id="txtTagFilter" autocomplete="off" placeholder="Type to add a tag filter" />
                        <div class="suggest-list" id="tagSuggest"></div>
                        <div id="tagChips" style="margin-top:var(--space-xs);"></div>
                    </div>

                    <button type="button" id="btnSearch" class="btn btn-primary" style="width:100%;justify-content:center;">Search</button>
                    <button type="button" id="btnClear" class="btn btn-ghost" style="width:100%;justify-content:center;margin-top:var(--space-xs);">Clear filters</button>
                </div>

                <div class="panel">
                    <div id="resultCount" class="mono" style="color:var(--color-muted);font-size:var(--text-xs);margin-bottom:var(--space-sm);"></div>
                    <div id="results"></div>
                    <div class="empty-note" id="emptyNote" style="display:none;">No records match these filters.</div>
                </div>
            </div>
        </div>
    </form>

    <div class="preview-overlay" id="previewOverlay">
        <div class="preview-box">
            <div class="preview-head">
                <strong id="previewTitle"></strong>
                <button type="button" id="previewClose">&times;</button>
            </div>
            <div class="preview-body" id="previewBody"></div>
        </div>
    </div>

    <script src="Scripts/jquery-3.7.0.min.js"></script>
    <script>
        var categoryData = [];
        var selectedTags = [];
        var INLINE_EXT = ["pdf", "jpg", "jpeg", "png", "gif"];

        function b64Decode(str) { return decodeURIComponent(escape(atob(str))); }

        function requireAuth() {
            var jwt = sessionStorage.getItem("dt_jwt");
            if (!jwt) { window.location.href = "Login.aspx"; return null; }
            try {
                var parts = b64Decode(jwt).split("|");
                return { token: parts[0] };
            } catch (ex) {
                window.location.href = "Login.aspx";
                return null;
            }
        }

        function loadDropdown(sel, items) {
            sel.empty().append($("<option>").val("").text("-- Any --"));
            items.forEach(function (it) { sel.append($("<option>").val(it.id).text(it.name)); });
        }
        function childrenOf(parentId) {
            return categoryData.filter(function (c) { return c.parentId === parentId; });
        }
        function fileUrl(recordId, storedName) {
            return "FileHandler.ashx?recordId=" + encodeURIComponent(recordId) + "&file=" + encodeURIComponent(storedName);
        }
        function extOf(name) {
            return name.split(".").pop().toLowerCase();
        }

        $(function () {
            var auth = requireAuth();
            if (!auth) return;
            $("#lblUser").text(auth.token);

            $.ajax({
                type: "POST", url: "Repository.aspx/GetCategories",
                data: "{}", contentType: "application/json; charset=utf-8", dataType: "json",
                success: function (res) {
                    categoryData = JSON.parse(res.d);
                    loadDropdown($("#ddl1"), categoryData.filter(function (c) { return c.level === 1; }));
                }
            });

            $("#ddl1").on("change", function () {
                var val = $(this).val();
                $("#ddl3, #ddl4").prop("disabled", true).empty().append("<option value=''>-- Any --</option>");
                if (!val) { $("#ddl2").prop("disabled", true).empty().append("<option value=''>-- Any --</option>"); return; }
                loadDropdown($("#ddl2"), childrenOf(val));
                $("#ddl2").prop("disabled", false);
            });
            $("#ddl2").on("change", function () {
                var val = $(this).val();
                $("#ddl4").prop("disabled", true).empty().append("<option value=''>-- Any --</option>");
                if (!val) { $("#ddl3").prop("disabled", true).empty().append("<option value=''>-- Any --</option>"); return; }
                loadDropdown($("#ddl3"), childrenOf(val));
                $("#ddl3").prop("disabled", false);
            });
            $("#ddl3").on("change", function () {
                var val = $(this).val();
                if (!val) { $("#ddl4").prop("disabled", true).empty().append("<option value=''>-- Any --</option>"); return; }
                loadDropdown($("#ddl4"), childrenOf(val));
                $("#ddl4").prop("disabled", false);
            });

            var tagTimer;
            $("#txtTagFilter").on("input", function () {
                clearTimeout(tagTimer);
                var term = $(this).val();
                if (!term) { $("#tagSuggest").hide(); return; }
                tagTimer = setTimeout(function () {
                    $.ajax({
                        type: "POST", url: "Repository.aspx/SearchTags",
                        data: JSON.stringify({ term: term }), contentType: "application/json; charset=utf-8", dataType: "json",
                        success: function (res) {
                            var list = JSON.parse(res.d);
                            var box = $("#tagSuggest").empty();
                            if (list.length === 0) { box.hide(); return; }
                            list.forEach(function (t) {
                                var div = $("<div>").text(t).on("click", function () {
                                    addTagFilter(t);
                                    $("#txtTagFilter").val("");
                                    box.hide();
                                });
                                box.append(div);
                            });
                            box.show();
                        }
                    });
                }, 180);
            });
            $("#txtTagFilter").on("keypress", function (e) {
                if (e.which === 13) {
                    e.preventDefault();
                    addTagFilter($(this).val());
                    $(this).val("");
                    $("#tagSuggest").hide();
                }
            });
            $(document).on("click", function (e) {
                if (!$(e.target).closest(".suggest-box").length) { $("#tagSuggest").hide(); }
            });

            function addTagFilter(tag) {
                tag = $.trim(tag);
                if (!tag || selectedTags.indexOf(tag) !== -1) return;
                selectedTags.push(tag);
                renderTagChips();
            }
            function renderTagChips() {
                var box = $("#tagChips").empty();
                selectedTags.forEach(function (t) {
                    var chip = $("<span>").addClass("tag-chip").text(t);
                    var rm = $("<span>").addClass("rm").text("x").on("click", function () {
                        selectedTags = selectedTags.filter(function (x) { return x !== t; });
                        renderTagChips();
                    });
                    chip.append(rm);
                    box.append(chip);
                });
            }

            $("#btnClear").on("click", function () {
                $("#ddl1").val("").trigger("change");
                $("#txtSubject, #txtFrom, #txtTo, #txtTagFilter").val("");
                selectedTags = [];
                renderTagChips();
                runSearch();
            });

            $("#btnSearch").on("click", runSearch);

            function runSearch() {
                var payload = {
                    department: $("#ddl1 option:selected").text() === "-- Any --" ? "" : $("#ddl1 option:selected").text(),
                    category: $("#ddl2 option:selected").text() === "-- Any --" ? "" : $("#ddl2 option:selected").text(),
                    subCategory: $("#ddl3 option:selected").text() === "-- Any --" ? "" : $("#ddl3 option:selected").text(),
                    type: $("#ddl4 option:selected").text() === "-- Any --" ? "" : $("#ddl4 option:selected").text(),
                    subject: $("#txtSubject").val(),
                    tags: selectedTags,
                    dateFrom: $("#txtFrom").val(),
                    dateTo: $("#txtTo").val()
                };

                $.ajax({
                    type: "POST", url: "Repository.aspx/SearchRecords",
                    data: JSON.stringify(payload), contentType: "application/json; charset=utf-8", dataType: "json",
                    success: function (res) {
                        renderResults(JSON.parse(res.d));
                    }
                });
            }

            function renderResults(list) {
                var box = $("#results").empty();
                $("#resultCount").text(list.length + " record(s) found");
                $("#emptyNote").toggle(list.length === 0);

                list.forEach(function (r) {
                    var row = $("<div>").addClass("rec-row");
                    var pathParts = [r.department, r.category, r.subCategory, r.type].filter(function (p) { return p; });
                    row.append($("<div>").addClass("rec-subject").text(r.subject));
                    var metaLine = (pathParts.join(" / ") || "Uncategorised") + " · " + r.uploaderName + " · " + new Date(r.createdOn).toLocaleString();
                    row.append($("<div>").addClass("rec-path").text(metaLine));

                    if (r.remark) {
                        row.append($("<div>").addClass("small text-muted mt-1").text(r.remark));
                    }

                    var tagWrap = $("<div>").addClass("mt-2");
                    (r.tags || []).forEach(function (t) { tagWrap.append($("<span>").addClass("mini-tag").text(t)); });
                    row.append(tagWrap);

                    var fileWrap = $("<div>").addClass("mt-2");
                    (r.files || []).forEach(function (f) {
                        var ext = extOf(f.originalName);
                        var pill;
                        if (INLINE_EXT.indexOf(ext) !== -1) {
                            pill = $("<a href='#'>").addClass("file-pill").html(f.originalName + " <span class='file-ext'>" + ext + "</span>");
                            pill.on("click", function (e) {
                                e.preventDefault();
                                openPreview(f.originalName, ext, fileUrl(r.id, f.storedName));
                            });
                        } else if (ext === "msg") {
                            pill = $("<a>").attr("href", fileUrl(r.id, f.storedName)).attr("target", "_blank")
                                .addClass("file-pill").html(f.originalName + " <span class='file-ext'>open in outlook</span>");
                        } else {
                            pill = $("<a>").attr("href", fileUrl(r.id, f.storedName))
                                .addClass("file-pill").html(f.originalName + " <span class='file-ext'>download</span>");
                        }
                        fileWrap.append(pill);
                    });
                    row.append(fileWrap);

                    box.append(row);
                });
            }

            function openPreview(name, ext, url) {
                $("#previewTitle").text(name);
                var body = $("#previewBody").empty();
                if (ext === "pdf") {
                    body.append($("<iframe>").attr("src", url));
                } else {
                    body.append($("<img>").attr("src", url).attr("alt", name));
                }
                $("#previewOverlay").addClass("show");
            }
            $("#previewClose").on("click", function () {
                $("#previewOverlay").removeClass("show");
                $("#previewBody").empty();
            });
            $("#previewOverlay").on("click", function (e) {
                if (e.target === this) { $("#previewClose").click(); }
            });

            runSearch();
        });
    </script>
</body>
</html>
