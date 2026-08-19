<%@ Page Title="Upload" Language="C#" AutoEventWireup="true" CodeBehind="Upload.aspx.cs" Inherits="DataTracking.Upload" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Upload - Data Tracking</title>
    <link href="Content/bootstrap.min.css" rel="stylesheet" />
    <style>
        body { background: #f2f4f7; }
        .topbar { background: #212529; color: #fff; padding: 12px 24px; display: flex; justify-content: space-between; align-items: center; }
        .card-box { background: #fff; border-radius: 8px; padding: 24px; box-shadow: 0 1px 6px rgba(0,0,0,0.06); margin: 20px; max-width: 900px; }
        .tag-chip { display: inline-flex; align-items: center; background: #0d6efd; color: #fff; border-radius: 14px; padding: 3px 10px; margin: 3px 4px 3px 0; font-size: 13px; }
        .tag-chip .rm { cursor: pointer; margin-left: 6px; font-weight: bold; }
        .suggest-box { position: relative; }
        .suggest-list { position: absolute; z-index: 20; background: #fff; border: 1px solid #ddd; width: 100%; max-height: 200px; overflow-y: auto; display: none; border-radius: 0 0 6px 6px; }
        .suggest-list div { padding: 6px 10px; cursor: pointer; }
        .suggest-list div:hover { background: #f0f0f0; }
        .related-tags { margin-top: 6px; }
        .related-tags .rel-tag { cursor: pointer; background: #e9ecef; border-radius: 12px; padding: 2px 9px; font-size: 12px; margin-right: 5px; display: inline-block; margin-bottom: 4px; }
        #fileList { margin-top: 8px; }
        #fileList li { font-size: 13px; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="topbar">
            <div>Data Tracking</div>
            <div>
                <span id="lblUser"></span>
                <a href="Repository.aspx" class="btn btn-sm btn-outline-light ms-2">Repository</a>
                <a href="Dashboard.aspx" class="btn btn-sm btn-outline-light ms-2">Dashboard</a>
            </div>
        </div>

        <div class="card-box">
            <h4>Add Repository Item</h4>

            <div class="row g-2 mb-3">
                <div class="col-md-3">
                    <label class="form-label">Department</label>
                    <select id="ddl1" class="form-select"><option value="">-- Select --</option></select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Category</label>
                    <select id="ddl2" class="form-select" disabled><option value="">-- Select --</option></select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Sub-Category</label>
                    <select id="ddl3" class="form-select" disabled><option value="">-- Select --</option></select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Type</label>
                    <select id="ddl4" class="form-select" disabled><option value="">-- Select --</option></select>
                </div>
            </div>

            <div class="mb-3 suggest-box">
                <label class="form-label">Subject</label>
                <input type="text" id="txtSubject" class="form-control" autocomplete="off" placeholder="Type subject..." />
                <div class="suggest-list" id="subjectSuggest"></div>
            </div>

            <div class="mb-3">
                <label class="form-label">Remark</label>
                <textarea id="txtRemark" class="form-control" rows="2"></textarea>
            </div>

            <div class="mb-3">
                <label class="form-label">Files (up to 8: pdf, image, .msg, excel, word, ppt)</label>
                <input type="file" id="fileInput" class="form-control" multiple
                    accept=".pdf,.jpg,.jpeg,.png,.gif,.msg,.xls,.xlsx,.doc,.docx,.ppt,.pptx" />
                <ul id="fileList" class="list-unstyled"></ul>
                <div class="text-danger small" id="fileErr" style="display:none;"></div>
            </div>

            <div class="mb-3 suggest-box">
                <label class="form-label">Tags (press Enter to add)</label>
                <input type="text" id="txtTag" class="form-control" autocomplete="off" placeholder="Type a tag and press Enter" />
                <div class="suggest-list" id="tagSuggest"></div>
                <div id="tagChips" class="mt-2"></div>
                <div class="related-tags" id="relatedTags"></div>
            </div>

            <button type="button" id="btnSave" class="btn btn-primary">Save</button>
            <span id="saveMsg" class="ms-2"></span>
        </div>
    </form>

    <script src="Scripts/jquery-3.7.0.min.js"></script>
    <script>
        var selectedTags = [];
        var selectedFiles = [];
        var categoryData = [];
        var MAX_FILES = 8;
        var ALLOWED_EXT = ["pdf", "jpg", "jpeg", "png", "gif", "msg", "xls", "xlsx", "doc", "docx", "ppt", "pptx"];
        var MAX_SIZE = 20 * 1024 * 1024;

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

        function loadDropdown(sel, items, placeholder) {
            sel.empty().append($("<option>").val("").text(placeholder));
            items.forEach(function (it) {
                sel.append($("<option>").val(it.id).text(it.name));
            });
        }

        function childrenOf(parentId) {
            return categoryData.filter(function (c) { return c.parentId === parentId; });
        }

        $(function () {
            var auth = requireAuth();
            if (!auth) return;
            $("#lblUser").text(auth.token);

            $.getJSON("Upload.aspx/GetCategories", {}).done(function () {});

            $.ajax({
                type: "POST", url: "Upload.aspx/GetCategories",
                data: "{}", contentType: "application/json; charset=utf-8", dataType: "json",
                success: function (res) {
                    categoryData = JSON.parse(res.d);
                    loadDropdown($("#ddl1"), categoryData.filter(function (c) { return c.level === 1; }), "-- Select --");
                }
            });

            $("#ddl1").on("change", function () {
                var val = $(this).val();
                $("#ddl3, #ddl4").prop("disabled", true).empty().append("<option value=''>-- Select --</option>");
                if (!val) { $("#ddl2").prop("disabled", true).empty().append("<option value=''>-- Select --</option>"); return; }
                loadDropdown($("#ddl2"), childrenOf(val), "-- Select --");
                $("#ddl2").prop("disabled", false);
            });

            $("#ddl2").on("change", function () {
                var val = $(this).val();
                $("#ddl4").prop("disabled", true).empty().append("<option value=''>-- Select --</option>");
                if (!val) { $("#ddl3").prop("disabled", true).empty().append("<option value=''>-- Select --</option>"); return; }
                loadDropdown($("#ddl3"), childrenOf(val), "-- Select --");
                $("#ddl3").prop("disabled", false);
            });

            $("#ddl3").on("change", function () {
                var val = $(this).val();
                if (!val) { $("#ddl4").prop("disabled", true).empty().append("<option value=''>-- Select --</option>"); return; }
                loadDropdown($("#ddl4"), childrenOf(val), "-- Select --");
                $("#ddl4").prop("disabled", false);
            });

            var subjTimer;
            $("#txtSubject").on("input", function () {
                clearTimeout(subjTimer);
                var term = $(this).val();
                if (term.length < 2) { $("#subjectSuggest").hide(); $("#relatedTags").empty(); return; }
                subjTimer = setTimeout(function () {
                    $.ajax({
                        type: "POST", url: "Upload.aspx/SearchSubjects",
                        data: JSON.stringify({ term: term }), contentType: "application/json; charset=utf-8", dataType: "json",
                        success: function (res) {
                            var list = JSON.parse(res.d);
                            var box = $("#subjectSuggest").empty();
                            if (list.length === 0) { box.hide(); return; }
                            list.forEach(function (s) {
                                var div = $("<div>").text(s.subject).on("click", function () {
                                    $("#txtSubject").val(s.subject);
                                    box.hide();
                                    showRelatedTags(s.tags || []);
                                });
                                box.append(div);
                            });
                            box.show();
                        }
                    });
                }, 250);
            });

            $(document).on("click", function (e) {
                if (!$(e.target).closest(".suggest-box").length) {
                    $(".suggest-list").hide();
                }
            });

            function showRelatedTags(tags) {
                var box = $("#relatedTags").empty();
                if (!tags.length) return;
                box.append($("<div class='small text-muted'>Related tags:</div>"));
                tags.forEach(function (t) {
                    var span = $("<span>").addClass("rel-tag").text(t).on("click", function () { addTag(t); });
                    box.append(span);
                });
            }

            function addTag(tag) {
                tag = $.trim(tag);
                if (!tag) return;
                if (selectedTags.indexOf(tag) !== -1) return;
                selectedTags.push(tag);
                renderTags();
            }

            function renderTags() {
                var box = $("#tagChips").empty();
                selectedTags.forEach(function (t) {
                    var chip = $("<span>").addClass("tag-chip").text(t);
                    var rm = $("<span>").addClass("rm").text("x").on("click", function () {
                        selectedTags = selectedTags.filter(function (x) { return x !== t; });
                        renderTags();
                    });
                    chip.append(rm);
                    box.append(chip);
                });
            }

            $("#txtTag").on("keypress", function (e) {
                if (e.which === 13) {
                    e.preventDefault();
                    addTag($(this).val());
                    $(this).val("");
                    $("#tagSuggest").hide();
                }
            });

            var tagTimer;
            $("#txtTag").on("input", function () {
                clearTimeout(tagTimer);
                var term = $(this).val();
                if (term.length < 1) { $("#tagSuggest").hide(); return; }
                tagTimer = setTimeout(function () {
                    $.ajax({
                        type: "POST", url: "Upload.aspx/SearchTags",
                        data: JSON.stringify({ term: term }), contentType: "application/json; charset=utf-8", dataType: "json",
                        success: function (res) {
                            var list = JSON.parse(res.d);
                            var box = $("#tagSuggest").empty();
                            if (list.length === 0) { box.hide(); return; }
                            list.forEach(function (t) {
                                var div = $("<div>").text(t).on("click", function () {
                                    addTag(t);
                                    $("#txtTag").val("");
                                    box.hide();
                                });
                                box.append(div);
                            });
                            box.show();
                        }
                    });
                }, 200);
            });

            $("#fileInput").on("change", function () {
                var newFiles = Array.prototype.slice.call(this.files);
                var err = $("#fileErr").hide().text("");

                newFiles.forEach(function (f) {
                    var ext = f.name.split(".").pop().toLowerCase();
                    if (selectedFiles.length >= MAX_FILES) {
                        err.text("Maximum " + MAX_FILES + " files allowed.").show();
                        return;
                    }
                    if (ALLOWED_EXT.indexOf(ext) === -1) {
                        err.text("File type not allowed: " + f.name).show();
                        return;
                    }
                    if (f.size > MAX_SIZE) {
                        err.text("File too large (max 20MB): " + f.name).show();
                        return;
                    }
                    selectedFiles.push(f);
                });

                renderFileList();
                $(this).val("");
            });

            function renderFileList() {
                var ul = $("#fileList").empty();
                selectedFiles.forEach(function (f, idx) {
                    var li = $("<li>").text(f.name + " (" + Math.round(f.size / 1024) + " KB) ");
                    var rm = $("<a href='#' class='text-danger ms-1'>remove</a>").on("click", function (e) {
                        e.preventDefault();
                        selectedFiles.splice(idx, 1);
                        renderFileList();
                    });
                    li.append(rm);
                    ul.append(li);
                });
            }

            $("#btnSave").on("click", function () {
                var subject = $.trim($("#txtSubject").val());
                if (!subject) { alert("Please enter a subject."); return; }
                if (!$("#ddl1").val()) { alert("Please select department."); return; }
                if (selectedFiles.length === 0) { alert("Please attach at least one file."); return; }

                var fd = new FormData();
                fd.append("token", auth.token);
                fd.append("department", $("#ddl1 option:selected").text());
                fd.append("category", $("#ddl2 option:selected").text());
                fd.append("subCategory", $("#ddl3 option:selected").text());
                fd.append("type", $("#ddl4 option:selected").text());
                fd.append("subject", subject);
                fd.append("remark", $("#txtRemark").val());
                fd.append("tags", JSON.stringify(selectedTags));
                selectedFiles.forEach(function (f) { fd.append("files", f); });

                $("#btnSave").prop("disabled", true).text("Saving...");
                $.ajax({
                    type: "POST", url: "UploadHandler.ashx", data: fd,
                    processData: false, contentType: false,
                    success: function (res) {
                        var r = JSON.parse(res);
                        if (r.success) {
                            $("#saveMsg").removeClass("text-danger").addClass("text-success").text("Saved successfully.");
                            selectedFiles = []; selectedTags = [];
                            renderFileList(); renderTags();
                            $("#txtSubject, #txtRemark").val("");
                        } else {
                            $("#saveMsg").removeClass("text-success").addClass("text-danger").text(r.message || "Save failed.");
                        }
                    },
                    error: function () {
                        $("#saveMsg").removeClass("text-success").addClass("text-danger").text("Save failed.");
                    },
                    complete: function () {
                        $("#btnSave").prop("disabled", false).text("Save");
                    }
                });
            });
        });
    </script>
</body>
</html>
