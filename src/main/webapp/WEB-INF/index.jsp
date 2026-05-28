<%--
  index.jsp — Page d'accueil : grille de documents.
  Utilise les tag files : header, footer, docCard
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
</head>
<body class="d-flex flex-column">

  <!-- ═══ Header ═══ -->
  <d:header pageTitle="${pageTitle}" totalDocs="${totalDocs}" activeTab="converters"/>

  <!-- ═══ Grille de documents ═══ -->
  <main class="container py-4 flex-grow-1">
    <c:choose>
      <c:when test="${empty documents}">
        <div class="empty-state">
          <i class="bi bi-inbox"></i>
          <h4 class="mt-3">Aucun document</h4>
          <p class="text-muted">Ajoutez des documents dans la configuration.</p>
          <a href="${pageContext.request.contextPath}/" class="btn btn-dz">
            <i class="bi bi-arrow-repeat me-1"></i>Recharger
          </a>
        </div>
      </c:when>
      <c:otherwise>
        <div class="row" id="docGrid">
          <c:forEach var="doc" items="${documents}" varStatus="loop">
            <d:docCard doc="${doc}" contextPath="${pageContext.request.contextPath}"/>
          </c:forEach>
        </div>
      </c:otherwise>
    </c:choose>
  </main>

  <!-- ═══ Footer ═══ -->
  <d:footer/>

  <!-- Bootstrap JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
          integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
          crossorigin="anonymous"></script>

  <!-- Filtre de recherche -->
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

    // Recherche
    var searchInput = document.getElementById('docSearch');
    if (searchInput) {
      searchInput.addEventListener('input', function(e) {
        var query = e.target.value.toLowerCase().trim();
        var items = document.querySelectorAll('.doc-card');
        items.forEach(function(card) {
          var col = card.closest('.col-12');
          if (!col) return;
          var title = (card.querySelector('.card-title') || {}).textContent || '';
          var desc = (card.querySelector('.card-text') || {}).textContent || '';
          var category = (card.querySelector('.doc-category-badge') || {}).textContent || '';
          var match = title.toLowerCase().indexOf(query) !== -1 ||
                      desc.toLowerCase().indexOf(query) !== -1 ||
                      category.toLowerCase().indexOf(query) !== -1;
          col.style.display = match ? '' : 'none';
        });
      });
    }
  })();
  </script>
</body>
</html>
