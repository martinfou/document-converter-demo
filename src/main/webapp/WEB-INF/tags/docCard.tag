<%-- 
  docCard.tag — Carte de document avec infos de conversion.
  Attributs : doc (Map), contextPath (String)
--%>
<%@ tag body-content="empty" import="java.util.Map" %>
<%@ attribute name="doc" required="true" type="java.util.Map" rtexprvalue="true" %>
<%@ attribute name="contextPath" required="false" type="java.lang.String" rtexprvalue="true" %>
<%
  Map<String, Object> d = (Map<String, Object>) doc;
  String id = (String) d.get("id");
  String name = (String) d.get("name");
  String desc = (String) d.get("description");
  String fileType = (String) d.get("fileType");
  String library = (String) d.get("library");
  String category = (String) d.get("category");
  String size = (String) d.get("size");
  Boolean ooOk = (Boolean) d.get("ooCompatible");
  boolean ooCompatible = ooOk != null && ooOk;
  String ctx = contextPath != null ? contextPath : "";
  
  // Icône par type
  String iconClass;
  String iconColorClass;
  if (fileType != null) {
    switch(fileType.toLowerCase()) {
      case "pdf":  iconClass = "bi-filetype-pdf"; iconColorClass = "card-icon-pdf"; break;
      case "xlsx":
      case "xls":  iconClass = "bi-filetype-xlsx"; iconColorClass = "card-icon-xlsx"; break;
      case "pptx":
      case "ppt":  iconClass = "bi-filetype-pptx"; iconColorClass = "card-icon-pptx"; break;
      case "docx":
      case "doc":  iconClass = "bi-filetype-docx"; iconColorClass = "card-icon-docx"; break;
      case "jpg":
      case "jpeg":
      case "png":
      case "gif":
      case "bmp":  iconClass = "bi-filetype-jpg"; iconColorClass = "card-icon-img"; break;
      case "tiff":
      case "tif":  iconClass = "bi-filetype-tiff"; iconColorClass = "card-icon-tiff"; break;
      case "eml":
      case "msg":
      case "mbox":
                   iconClass = "bi-envelope"; iconColorClass = "card-icon-email"; break;
      default:     iconClass = "bi-file-earmark"; iconColorClass = ""; break;
    }
  } else {
    iconClass = "bi-file-earmark"; iconColorClass = "";
  }
  
  String safeName = name != null ? 
    name.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;") : "Document";
  String safeDesc = desc != null ? 
    desc.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;") : "";
  String safeCategory = category != null ? 
    category.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;") : "";
  String safeLibrary = library != null ? 
    library.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;") : "";
%>
<div class="col-12 col-sm-6 col-md-4 col-lg-3 mb-4">
  <div class="doc-card" onclick="location.href='<%= ctx %>/convert/<%= id %>'" title="<%= safeName %>">
    <div class="position-relative">
      <div class="card-icon <%= iconColorClass %>">
        <i class="bi <%= iconClass %>"></i>
      </div>
      <% if (safeCategory.length() > 0) { %>
        <span class="doc-category-badge"><%= safeCategory %></span>
      <% } %>
      <% if (ooCompatible) { %>
        <span class="doc-badge-oo" title="Compatible ONLYOFFICE">OO</span>
      <% } %>
    </div>
    <div class="card-body">
      <h6 class="card-title text-truncate"><%= safeName %></h6>
      <% if (safeDesc.length() > 0) { %>
        <p class="card-text text-truncate"><%= safeDesc %></p>
      <% } %>
    </div>
    <div class="card-footer d-flex flex-wrap gap-1">
      <% if (safeLibrary.length() > 0) { %>
        <span class="badge bg-light text-dark small"><%= safeLibrary %></span>
      <% } %>
      <span class="small text-muted ms-auto"><%= fileType != null ? fileType.toUpperCase() : "—" %></span>
    </div>
  </div>
</div>
