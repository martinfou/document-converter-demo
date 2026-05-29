<%--
  header.tag — Barre de navigation Desjardins avec onglets Convertisseurs / ONLYOFFICE.
  Attributs : pageTitle (String), totalDocs (int), activeTab (String: "converters"|"onlyoffice")
--%>
<%@ tag body-content="empty" %>
<%@ attribute name="pageTitle" required="false" type="java.lang.String" rtexprvalue="true" %>
<%@ attribute name="totalDocs" required="false" type="java.lang.Integer" rtexprvalue="true" %>
<%@ attribute name="activeTab" required="false" type="java.lang.String" rtexprvalue="true" %>
<%
  String title = pageTitle != null ? pageTitle : "Document Converter Demo";
  Integer total = totalDocs != null ? totalDocs : 0;
  String active = activeTab != null ? activeTab : "converters";
%>
<nav class="navbar navbar-expand-lg navbar-dz sticky-top">
  <div class="container">
    <a class="navbar-brand d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/">
      <span class="navbar-brand-icon">
        <i class="bi bi-file-earmark-text"></i>
      </span>
      <span>Document Converter <span style="font-weight:400;color:var(--dz-text-light);font-size:0.85rem">Desjardins</span></span>
    </a>

    <button class="navbar-toggler" type="button" 
            data-bs-toggle="collapse" data-bs-target="#navMain"
            aria-controls="navMain" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="navMain">
      <!-- Tabs -->
      <ul class="navbar-nav me-auto">
        <li class="nav-item">
          <a class="nav-link <%= active.equals("converters") ? "active" : "" %>" 
             href="${pageContext.request.contextPath}/">
            <i class="bi bi-tools me-1"></i>Convertisseurs Java
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link <%= active.equals("upload") ? "active" : "" %>" 
             href="${pageContext.request.contextPath}/upload">
            <i class="bi bi-cloud-upload me-1"></i>Tester un document
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link <%= active.equals("onlyoffice") ? "active" : "" %>" 
             href="${pageContext.request.contextPath}/onlyoffice">
            <i class="bi bi-eye me-1"></i>Visionneuse ONLYOFFICE
          </a>
        </li>
      </ul>

      <!-- Search (only on converters tab) -->
      <% if (active.equals("converters")) { %>
      <form class="d-flex ms-auto me-2" role="search" onsubmit="return false;">
        <div class="input-group input-group-sm" style="max-width:280px">
          <span class="input-group-text bg-transparent border-end-0">
            <i class="bi bi-search text-muted"></i>
          </span>
          <input type="search" class="form-control border-start-0" 
                 id="docSearch" placeholder="Rechercher un document..."
                 aria-label="Search">
        </div>
      </form>
      <a href="${pageContext.request.contextPath}/" class="btn btn-sm btn-dz" title="Actualiser">
        <i class="bi bi-arrow-clockwise"></i>
      </a>
      <% } %>
    </div>
  </div>
</nav>

<!-- Stats bar (only on converters tab) -->
<% if (active.equals("converters")) { %>
<div class="stats-bar">
  <div class="container d-flex justify-content-between align-items-center small text-muted">
    <span>
      <i class="bi bi-files me-1"></i>
      <strong><%= total %></strong> document(s) &mdash;
      <strong><%= total %></strong> librairie(s)
    </span>
    <span class="d-none d-sm-inline">
      <i class="bi bi-arrow-right-circle me-1"></i>
      Cliquez sur un document pour voir sa conversion PDF
    </span>
  </div>
</div>
<% } %>
