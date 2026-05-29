<%--
  compare.jsp — Multi-converter comparison results.
  Shows all converters side by side for an uploaded document.
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

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
        rel="stylesheet"
        integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
        crossorigin="anonymous">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"
        rel="stylesheet">
  <link href="${pageContext.request.contextPath}/static/css/desjardins.css" rel="stylesheet">

  <style>
    .result-card {
      border: 1px solid var(--dz-border);
      border-radius: 12px;
      overflow: hidden;
      background: var(--dz-bg);
      transition: transform 0.2s ease, box-shadow 0.2s ease;
    }
    .result-card:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 24px var(--dz-shadow);
    }
    .result-card.success {
      border-color: var(--dz-green);
    }
    .result-card.fail {
      border-color: #dc3545;
    }
    .result-card-header {
      padding: 1rem;
      border-bottom: 1px solid var(--dz-border);
      display: flex;
      align-items: center;
      gap: 10px;
    }
    .result-card-header.success {
      background: linear-gradient(135deg, #e8f5e9, #f0f9f0);
    }
    .result-card-header.fail {
      background: linear-gradient(135deg, #ffebee, #fff5f5);
    }
    .result-icon {
      width: 40px;
      height: 40px;
      border-radius: 10px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 1.3rem;
      flex-shrink: 0;
    }
    .result-icon.success {
      background: var(--dz-green);
      color: #fff;
    }
    .result-icon.fail {
      background: #dc3545;
      color: #fff;
    }
    .result-card-body {
      padding: 1rem;
    }
    .stat-item {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 6px 0;
      border-bottom: 1px solid rgba(0,0,0,0.04);
    }
    .stat-item:last-child {
      border-bottom: none;
    }
    .stat-label {
      font-size: 0.8rem;
      color: var(--dz-text-light);
    }
    .stat-value {
      font-size: 0.85rem;
      font-weight: 600;
      font-variant-numeric: tabular-nums;
    }
    .file-header {
      background: var(--dz-bg);
      border: 1px solid var(--dz-border);
      border-radius: 12px;
      padding: 1.25rem;
    }
    .file-header .file-icon {
      width: 48px;
      height: 48px;
      border-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 1.5rem;
      color: #fff;
      flex-shrink: 0;
    }
    .file-icon.docx, .file-icon.doc { background: #1a73e8; }
    .file-icon.xlsx, .file-icon.xls { background: #00843D; }
    .file-icon.pptx, .file-icon.ppt { background: #e37400; }
    .file-icon.pdf { background: #dc3545; }
    .file-icon.jpg, .file-icon.jpeg, .file-icon.png, .file-icon.gif, .file-icon.bmp { background: #9c27b0; }
    .file-icon.tiff, .file-icon.tif { background: #607d8b; }
    .file-icon.eml, .file-icon.msg, .file-icon.mbox { background: #e91e63; }
    .file-icon.default { background: #6c757d; }

    .result-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
      gap: 1rem;
    }

    .category-badge {
      display: inline-block;
      padding: 2px 8px;
      border-radius: 4px;
      font-size: 0.7rem;
      font-weight: 600;
      letter-spacing: 0.3px;
      text-transform: uppercase;
    }
    .category-badge.word { background: #e3f2fd; color: #1a73e8; }
    .category-badge.spreadsheet { background: #e8f5e9; color: #00843D; }
    .category-badge.presentation { background: #fff3e0; color: #e37400; }
    .category-badge.image, .category-badge.image-scan { background: #f3e5f5; color: #9c27b0; }
    .category-badge.email { background: #fce4ec; color: #e91e63; }

    .summary-stat {
      text-align: center;
      padding: 0.75rem;
      border-radius: 8px;
    }
    .summary-stat.ok { background: #e8f5e9; }
    .summary-stat.fail { background: #ffebee; }
    .summary-stat.total { background: var(--dz-green-light); }

    .notes-box {
      background: #f8f9fa;
      border-radius: 6px;
      padding: 0.6rem;
      font-size: 0.78rem;
      color: var(--dz-text-light);
      max-height: 100px;
      overflow-y: auto;
      word-break: break-word;
    }

    .success-badge {
      display: inline-flex;
      align-items: center;
      gap: 4px;
      padding: 2px 10px;
      border-radius: 12px;
      font-size: 0.75rem;
      font-weight: 600;
    }
    .success-badge.ok {
      background: #e8f5e9;
      color: #00843D;
    }
    .success-badge.fail {
      background: #ffebee;
      color: #dc3545;
    }

    .category-filter .btn-outline-dz {
      color: var(--dz-green);
      border-color: var(--dz-border);
    }
    .category-filter .btn-outline-dz.active,
    .category-filter .btn-outline-dz:hover {
      background: var(--dz-green);
      color: #fff;
      border-color: var(--dz-green);
    }

    @media (max-width: 576px) {
      .result-grid {
        grid-template-columns: 1fr;
      }
      .file-header {
        padding: 1rem;
        flex-direction: column;
        text-align: center;
      }
    }
  </style>
</head>
<body class="d-flex flex-column">

  <d:header pageTitle="Comparaison" totalDocs="0" activeTab="upload"/>

  <main class="container py-4 flex-grow-1">

    <!-- ═══ File info header ═══ -->
    <div class="file-header d-flex align-items-center gap-3 mb-4">
      <c:set var="extLower" value="${fn:toLowerCase(fileType)}"/>
      <div class="file-icon
        ${extLower eq 'docx' or extLower eq 'doc' ? 'docx' : ''}
        ${extLower eq 'xlsx' or extLower eq 'xls' ? 'xlsx' : ''}
        ${extLower eq 'pptx' or extLower eq 'ppt' ? 'pptx' : ''}
        ${extLower eq 'pdf' ? 'pdf' : ''}
        ${extLower eq 'jpg' or extLower eq 'jpeg' or extLower eq 'png' or extLower eq 'gif' or extLower eq 'bmp' ? 'jpg' : ''}
        ${extLower eq 'tiff' or extLower eq 'tif' ? 'tiff' : ''}
        ${extLower eq 'eml' or extLower eq 'msg' or extLower eq 'mbox' ? 'eml' : ''}
        ${extLower ne 'docx' and extLower ne 'doc' and extLower ne 'xlsx' and extLower ne 'xls'
          and extLower ne 'pptx' and extLower ne 'ppt' and extLower ne 'pdf'
          and extLower ne 'jpg' and extLower ne 'jpeg' and extLower ne 'png'
          and extLower ne 'gif' and extLower ne 'bmp'
          and extLower ne 'tiff' and extLower ne 'tif'
          and extLower ne 'eml' and extLower ne 'msg' and extLower ne 'mbox' ? 'default' : ''}">
        <i class="bi bi-file-earmark-text"></i>
      </div>
      <div class="flex-grow-1">
        <h5 class="mb-1">${fileName}</h5>
        <div class="d-flex flex-wrap gap-2 align-items-center">
          <span class="badge bg-dz">${fileType}</span>
          <c:choose>
            <c:when test="${fileSize lt 1024}">
              <span class="small text-muted">${fileSize} o</span>
            </c:when>
            <c:when test="${fileSize lt 1048576}">
              <span class="small text-muted">${String.format('%.1f', fileSize / 1024)} Ko</span>
            </c:when>
            <c:otherwise>
              <span class="small text-muted">${String.format('%.1f', fileSize / 1048576)} Mo</span>
            </c:otherwise>
          </c:choose>
          <span class="badge bg-light text-dark">${totalConverters} convertisseur(s)</span>
        </div>
      </div>
      <a href="${pageContext.request.contextPath}/upload" class="btn btn-dz-outline btn-sm flex-shrink-0">
        <i class="bi bi-cloud-upload me-1"></i>Nouveau test
      </a>
    </div>

    <!-- ═══ Summary stats ═══ -->
    <div class="row g-2 mb-4">
      <div class="col-4">
        <div class="summary-stat total">
          <div class="fs-3 fw-bold" style="color:var(--dz-green)">${totalConverters}</div>
          <small class="text-muted">Convertisseurs</small>
        </div>
      </div>
      <div class="col-4">
        <div class="summary-stat ok">
          <div class="fs-3 fw-bold text-success">${totalSuccess}</div>
          <small class="text-muted">Réussis</small>
        </div>
      </div>
      <div class="col-4">
        <div class="summary-stat fail">
          <div class="fs-3 fw-bold text-danger">${totalFail}</div>
          <small class="text-muted">Échecs</small>
        </div>
      </div>
    </div>

    <!-- ═══ Category filter (client-side) ═══ -->
    <div class="d-flex flex-wrap gap-2 mb-3 category-filter" id="categoryFilter">
      <button class="btn btn-sm btn-outline-dz active" data-filter="all">Tous</button>
      <c:set var="seenCategories" value=""/>
      <c:forEach var="r" items="${results}" varStatus="loop">
        <c:set var="cat" value="${fn:toLowerCase(r.category)}"/>
        <c:if test="${not fn:contains(seenCategories, cat)}">
          <c:set var="seenCategories" value="${seenCategories}${cat},"/>
          <button class="btn btn-sm btn-outline-dz" data-filter="${cat}">${r.category}</button>
        </c:if>
      </c:forEach>
    </div>

    <!-- ═══ Results grid ═══ -->
    <div class="result-grid" id="resultGrid">
      <c:forEach var="r" items="${results}" varStatus="loop">
        <div class="result-card ${r.success ? 'success' : 'fail'}"
             data-category="${fn:toLowerCase(r.category)}">
          <!-- Header -->
          <div class="result-card-header ${r.success ? 'success' : 'fail'}">
            <div class="result-icon ${r.success ? 'success' : 'fail'}">
              <c:choose>
                <c:when test="${r.success}"><i class="bi bi-check-lg"></i></c:when>
                <c:otherwise><i class="bi bi-x-lg"></i></c:otherwise>
              </c:choose>
            </div>
            <div class="flex-grow-1 min-w-0">
              <div class="fw-semibold small text-truncate">${r.converterName}</div>
              <div class="d-flex gap-2 align-items-center">
                <span class="category-badge ${fn:toLowerCase(r.category)}">${r.category}</span>
                <small class="text-muted">${r.libraryName}</small>
              </div>
            </div>
          </div>

          <!-- Body -->
          <div class="result-card-body">
            <!-- Duration -->
            <div class="stat-item">
              <span class="stat-label"><i class="bi bi-clock me-1"></i>Durée</span>
              <span class="stat-value">${r.durationMs} ms</span>
            </div>

            <!-- Output size -->
            <div class="stat-item">
              <span class="stat-label"><i class="bi bi-file-earmark me-1"></i>PDF généré</span>
              <c:choose>
                <c:when test="${r.success}">
                  <c:choose>
                    <c:when test="${r.outputSizeBytes lt 1024}">
                      <span class="stat-value">${r.outputSizeBytes} o</span>
                    </c:when>
                    <c:when test="${r.outputSizeBytes lt 1048576}">
                      <span class="stat-value">${String.format('%.1f', r.outputSizeBytes / 1024)} Ko</span>
                    </c:when>
                    <c:otherwise>
                      <span class="stat-value">${String.format('%.1f', r.outputSizeBytes / 1048576)} Mo</span>
                    </c:otherwise>
                  </c:choose>
                </c:when>
                <c:otherwise>
                  <span class="stat-value text-muted">—</span>
                </c:otherwise>
              </c:choose>
            </div>

            <!-- Status badge -->
            <div class="stat-item">
              <span class="stat-label"><i class="bi bi-check-circle me-1"></i>Statut</span>
              <span class="success-badge ${r.success ? 'ok' : 'fail'}">
                <c:choose>
                  <c:when test="${r.success}"><i class="bi bi-check-circle-fill"></i>Réussi</c:when>
                  <c:otherwise><i class="bi bi-x-circle-fill"></i>Échec</c:otherwise>
                </c:choose>
              </span>
            </div>

            <!-- Notes -->
            <c:if test="${not empty r.notes}">
              <div class="mt-2">
                <div class="notes-box">
                  <c:choose>
                    <c:when test="${r.success}">
                      <i class="bi bi-info-circle me-1"></i>
                    </c:when>
                    <c:otherwise>
                      <i class="bi bi-exclamation-triangle text-danger me-1"></i>
                    </c:otherwise>
                  </c:choose>
                  ${r.notes}
                </div>
              </div>
            </c:if>

            <!-- Download -->
            <c:if test="${r.success and not empty r.outputFileName}">
              <div class="d-grid mt-3">
                <a href="${pageContext.request.contextPath}/output/${r.outputFileName}"
                   class="btn btn-dz btn-sm" target="_blank">
                  <i class="bi bi-download me-2"></i>Télécharger le PDF
                </a>
                <a href="${pageContext.request.contextPath}/output/${r.outputFileName}"
                   class="btn btn-dz-outline btn-sm mt-1" target="_blank">
                  <i class="bi bi-eye me-2"></i>Aperçu
                </a>
              </div>
            </c:if>
          </div>
        </div>
      </c:forEach>
    </div>

    <!-- ═══ Legend ═══ -->
    <div class="alert alert-info mt-4 d-flex align-items-center gap-3 py-3" role="alert">
      <i class="bi bi-info-circle fs-4 flex-shrink-0"></i>
      <div>
        <strong>Comparaison de convertisseurs</strong><br>
        <small>
          Chaque convertisseur Java a été exécuté sur le même fichier source.
          Les résultats PDF peuvent être téléchargés ou visualisés.
          Cliquez sur une catégorie ci-dessus pour filtrer par type de convertisseur.
        </small>
      </div>
    </div>
  </main>

  <d:footer/>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
          integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
          crossorigin="anonymous"></script>

  <script>
  (function() {
    'use strict';

    // Category filtering
    var filterBtns = document.querySelectorAll('#categoryFilter .btn');
    var cards = document.querySelectorAll('#resultGrid .result-card');

    filterBtns.forEach(function(btn) {
      btn.addEventListener('click', function() {
        filterBtns.forEach(function(b) { b.classList.remove('active'); });
        btn.classList.add('active');

        var filter = btn.getAttribute('data-filter');
        cards.forEach(function(card) {
          if (filter === 'all') {
            card.style.display = '';
          } else {
            var cat = card.getAttribute('data-category');
            card.style.display = cat === filter ? '' : 'none';
          }
        });
      });
    });

    // Footer time
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
