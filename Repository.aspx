<%@ Page Title="Repository" Language="C#" AutoEventWireup="true" CodeBehind="Repository.aspx.cs" Inherits="DataTracking.Repository" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Repository - Data Tracking</title>
    <link href="Content/bootstrap.min.css" rel="stylesheet" />
    <style>
        body { background: #f2f4f7; }
        .topbar { background: #212529; color: #fff; padding: 12px 24px; display: flex; justify-content: space-between; align-items: center; }
        .card-box { background: #fff; border-radius: 8px; padding: 20px; box-shadow: 0 1px 6px rgba(0,0,0,0.06); margin: 20px; }
        .suggest-box { position: relative; }
        .suggest-list { position: absolute; z-index: 20; background: #fff; border: 1px solid #ddd; width: 100%; max-height: 200px; overflow-y: auto; display: none; border-radius: 0 0 6px 6px; }
        .suggest-list div { padding: 6px 10px; cursor: pointer; }
        .suggest-list div:hover { background: #f0f0f0; }
        .tag-chip { display: inline-flex; align-items: center; background: #0d6efd; color: #fff; border-radius: 14px; padding: 3px 10px; margin: 3px 4px 3px 0; font-size: 13px; }
        .tag-chip .rm { cursor: pointer; margin-left: 6px; font-weight: bold; }
        .rec-row { border-bottom: 1px solid #e9ecef; padding: 14px 0; }
        .rec-row:last-child { border-bottom: none; }
        .rec-subject { font-weight: 600; }
        .rec-path { font-size: 12px; color: #6c757d; }
        .mini-tag { display: inline-block; background: #eef1f4; border-radius: 10px; padding: 1px 8px; margin: 0 4px 4px 0; font-size: 11px; }
        .file-pill { display: inline-flex; align-items: center; gap: 6px; border: 1px solid #dee2e6; border-radius: 16px; padding: 4px 10px; margin: 3px 6px 3px 0; font-size: 12px; background: #fafbfc; text-decoration: none; color: #212529; }
        .file-pill:hover { border-color: #0d6efd; color: #0d6efd; }
        .file-ext { font-size: 10px; text-transform: uppercase; color: #6c757d; }
        .empty-note { color: #6c757d; padding: 20px 0; }

        .preview-overlay { display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.6); z-index: 1000; align-items: center; justify-content: center; }
        .preview-overlay.show { display: flex; }
        .preview-box { background: #fff; border-radius: 6px; width: min(900px, 92vw); height: min(85vh, 900px); display: flex; flex-direction: column; overflow: hidden; }
        .preview-head { display: flex; justify-content: space-between; align-items: center; padding: 10px 16px; border-bottom: 1px solid #e9ecef; }
        .preview-head button { border: none; background: none; font-size: 20px; cursor: pointer; line-height: 1; }
        .preview-body { flex: 1; overflow: auto; background: #333; display: flex; align-items: center; justify-content: center; }
        .preview-body iframe { width: 100%; height: 100%; border: none; background: #fff; }
        .preview-body img { max-width: 100%; max-height: 100%; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="topbar">
            <div>Data Tracking</div>
            <div>
                <span id="lblUser"></span>
                <a href="Upload.aspx" class="btn btn-sm btn-outline-light ms-2">Upload</a>
                <a href="Dashboard.aspx" class="btn btn-sm btn-outline-light ms-2">Dashboard</a>
            </div>
        </div>

        <div class="card-box">
            <h4>Repository</h4>

            <div class="row g-2 mb-2">
                <div class="col-md-3">
                    <label class="form-label">Department</label>
                    <select id="ddl1" class="form-select"><option value="">-- Any --</option></select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Category</label>
                    <select id="ddl2" class="form-select" disabled><option value="">-- Any --</option></select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Sub-Category</label>
                    <select id="ddl3" class="form-select" disabled><option value="">-- Any --</option></select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Type</label>
                    <select id="ddl4" class="form-select" disabled><option value="">-- Any --</option></select>
                </div>
            </div>

            <div class="row g-2 mb-2">
                <div class="col-md-4">
                    <label class="form-label">Subject contains</label>
                    <input type="text" id="txtSubject" class="form-control" autocomplete="off" />
                </div>
                <div class="col-md-4">
                    <label class="form-label">From date</label>
                    <input type="date" id="txtFrom" class="form-control" />
                </div>
                <div class="col-md-4">
                    <label class="form-label">To date</label>
                    <input type="date" id="txtTo" class="form-control" />
                </div>
            </div>

            <div class="row g-2 mb-3">
                <div class="col-md-6 suggest-box">
                    <label class="form-label">Tags</label>
                    <input type="text" id="txtTagFilter" class="form-control" autocomplete="off" placeholder="Type to add a tag filter" />
                    <div class="suggest-list" id="tagSuggest"></div>
                    <div id="tagChips" class="mt-2"></div>
                </div>
            </div>

            <button type="button" id="btnSearch" class="btn btn-primary">Search</button>
            <button type="button" id="btnClear" class="btn btn-outline-secondary ms-2">Clear filters</button>
        </div>

        <div class="card-box">
            <div id="resultCount" class="text-muted small mb-2"></div>
            <div id="results"></div>
            <div class="empty-note" id="emptyNote" style="display:none;">No records match these filters.</div>
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
