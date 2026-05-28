<%--
  viewer.jsp — Page de visionneuse ONLYOFFICE.
  Utilise les tag files : header, footer, onlyofficeViewer
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="d" tagdir="/WEB-INF/tags" %>
<!DOCTYPE html>
<html lang="fr" data-bs-theme="light">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${pageTitle} — Desjardins</title>

  <!-- Bootstrap 5 -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" 
        rel="stylesheet"
        integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" 
        crossorigin="anonymous">
  <!-- Bootstrap Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" 
        rel="stylesheet">
  <!-- Thème Desjardins -->
  <link href="${pageContext.request.contextPath}/static/css/desjardins.css" rel="stylesheet">

  <style>
    /* Pleine hauteur */
    html, body { height: 100%; margin: 0; }
    body { display: flex; flex-direction: column; background: #f0f0f0; }
    .viewer-wrapper { flex: 1; display: flex; flex-direction: column; min-height: 0; overflow: hidden; }
    
    /* Barre d'info du document */
    .doc-info-bar {
      background: #fff;
      border-bottom: 1px solid var(--dz-border);
      padding: 8px 16px;
      display: flex;
      align-items: center;
      gap: 12px;
      flex-shrink: 0;
    }
    .doc-info-bar .doc-name {
      font-weight: 600;
      font-size: 0.95rem;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
      flex: 1;
      min-width: 0;
    }
    .doc-info-bar .doc-meta {
      font-size: 0.8rem;
      color: var(--dz-text-light);
      white-space: nowrap;
      flex-shrink: 0;
    }
    @media (max-width: 576px) {
      .doc-info-bar { padding: 6px 10px; gap: 6px; flex-wrap: wrap; }
      .doc-info-bar .doc-name { font-size: 0.85rem; width: 100%; flex: none; order: 3; white-space: normal; }
      .doc-info-bar .vr { display: none; }
      .doc-info-bar .d-none.d-sm-inline { display: none !important; }
    }
  </style>
</head>
<body>

  <!-- ═══ Header ═══ -->
  <d:header pageTitle="Visionneuse" totalDocs="0" activeTab="onlyoffice"/>

  <!-- ═══ Info document ═══ -->
  <div class="doc-info-bar">
    <a href="${pageContext.request.contextPath}/" class="btn btn-sm btn-dz-outline">
      <i class="bi bi-arrow-left"></i>
      <span class="d-none d-sm-inline">Retour</span>
    </a>
    <div class="vr"></div>
    <span class="doc-name">
      <c:choose>
        <c:when test="${not empty doc}">
          <c:out value="${doc.name}"/>
        </c:when>
        <c:otherwise>Document inconnu</c:otherwise>
      </c:choose>
    </span>
    <c:if test="${not empty doc}">
      <c:if test="${not empty doc.fileType}">
        <span class="doc-meta">
          <span class="pill-dz">
            <i class="bi bi-file-earmark"></i>
            ${fn:toUpperCase(doc.fileType)}
          </span>
        </span>
      </c:if>
      <c:if test="${not empty doc.category}">
        <span class="doc-meta d-none d-md-inline">
          <c:out value="${doc.category}"/>
        </span>
      </c:if>
      <span class="doc-meta ms-auto d-none d-sm-inline">
        <i class="bi bi-info-circle me-1"></i>
        Mode lecture seule &middot; Visionneuse ONLYOFFICE
      </span>
    </c:if>
  </div>

  <!-- ═══ Visionneuse ONLYOFFICE ═══ -->
  <div class="viewer-wrapper">
    <d:onlyofficeViewer configJson="${ooconfig}" dsUrl="${dsUrl}"/>
  </div>

  <!-- ═══ Footer ═══ -->
  <d:footer/>

  <!-- Bootstrap JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
          integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
          crossorigin="anonymous"></script>

  <script>
  (function() {
    'use strict';
    // Horloge footer
    function updateFooterTime() {
      var el = document.getElementById('footerTime');
      if (el) el.textContent = new Date().toLocaleString('fr-CA');
    }
    updateFooterTime();
    setInterval(updateFooterTime, 30000);
  })();
  </script>
</body>
</html>
