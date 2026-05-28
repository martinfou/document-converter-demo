<%--
  convertView.jsp — Visionneuse + Conversion en un seul écran.
  Split layout : visionneuse du document à gauche, contrôles de conversion à droite.
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
  <title>Conversion : ${doc.name} — Desjardins</title>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" 
        rel="stylesheet"
        integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" 
        crossorigin="anonymous">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" 
        rel="stylesheet">
  <link href="${pageContext.request.contextPath}/static/css/desjardins.css" rel="stylesheet">

  <style>
    html, body { height: 100%; margin: 0; }
    body { display: flex; flex-direction: column; }
    .split-layout { flex: 1; display: flex; overflow: hidden; }
    .split-preview {
      flex: 1;
      display: flex;
      flex-direction: column;
      background: #f5f5f5;
      border-right: 1px solid var(--dz-border);
      overflow: hidden;
    }
    .split-preview .preview-header {
      padding: 10px 16px;
      background: #fff;
      border-bottom: 1px solid var(--dz-border);
      flex-shrink: 0;
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .split-preview .preview-body {
      flex: 1;
      display: flex;
      align-items: center;
      justify-content: center;
      overflow: auto;
      padding: 16px;
    }
    .split-preview .preview-body img {
      max-width: 100%;
      max-height: 100%;
      object-fit: contain;
      border-radius: 4px;
      box-shadow: 0 2px 12px rgba(0,0,0,0.1);
    }
    .split-preview .preview-body embed,
    .split-preview .preview-body iframe {
      width: 100%;
      height: 100%;
      border: none;
      border-radius: 4px;
    }
    .split-controls {
      width: 400px;
      flex-shrink: 0;
      display: flex;
      flex-direction: column;
      overflow-y: auto;
      background: #fff;
    }
    .split-controls .controls-header {
      padding: 16px;
      border-bottom: 1px solid var(--dz-border);
      flex-shrink: 0;
    }
    .split-controls .controls-body {
      padding: 16px;
      flex: 1;
    }
    .preview-icon {
      width: 80px;
      height: 80px;
      display: flex;
      align-items: center;
      justify-content: center;
      border-radius: 16px;
      font-size: 2.5rem;
      color: #fff;
      margin-bottom: 12px;
    }
    .preview-icon.pdf { background: #dc3545; }
    .preview-icon.docx { background: #1a73e8; }
    .preview-icon.xlsx { background: #00843D; }
    .preview-icon.pptx { background: #e37400; }
    .preview-icon.image { background: #9c27b0; }
    .preview-icon.email { background: #e91e63; }

    @media (max-width: 768px) {
      .split-layout { flex-direction: column; }
      .split-preview { min-height: 30vh; max-height: 50vh; border-right: none; border-bottom: 1px solid var(--dz-border); }
      .split-controls { width: 100%; }
      .preview-body { padding: 8px; }
      #progressSteps .step-label { font-size: 0.7rem; }
      .split-controls .controls-body { padding: 12px; }
    }
    @media (max-width: 480px) {
      .split-preview { min-height: 25vh; max-height: 40vh; }
      .split-controls .controls-header { padding: 10px 12px; }
      .split-controls .controls-body { padding: 10px; }
    }
    /* Toggle preview on mobile */
    .preview-toggle {
      display: none;
      background: none;
      border: none;
      color: var(--dz-text-light);
      font-size: 0.8rem;
      padding: 2px 6px;
      border-radius: 4px;
    }
    .preview-toggle:hover { background: var(--dz-green-light); color: var(--dz-green); }
    @media (max-width: 768px) {
      .preview-toggle { display: inline-flex; align-items: center; gap: 4px; }
    }
  </style>
</head>
<body>

  <d:header pageTitle="Convertisseur" totalDocs="0" activeTab="converters"/>

  <div class="split-layout">

    <!-- ═══ Paneau gauche : Visionneuse du document ═══ -->
    <div class="split-preview">
      <div class="preview-header">
        <a href="${pageContext.request.contextPath}/" class="btn btn-sm btn-dz-outline" title="Retour">
          <i class="bi bi-arrow-left"></i>
        </a>
        <button class="preview-toggle" id="previewToggle" type="button" title="Afficher/masquer">
          <i class="bi bi-eye-slash"></i>
          <span class="d-none d-sm-inline">Aperçu</span>
        </button>
        <i class="bi bi-file-earmark me-1"></i>
        <strong class="text-truncate">${doc.name}</strong>
        <span class="badge bg-dz ms-auto">${fn:toUpperCase(doc.fileType)}</span>
      </div>
      <div class="preview-body">
        <c:choose>
          <%-- PDF viewer --%>
          <c:when test="${fn:toLowerCase(doc.fileType) eq 'pdf'}">
            <embed src="${pageContext.request.contextPath}/api/documents/${doc.id}/content" type="application/pdf">
          </c:when>

          <%-- Image viewer --%>
          <c:when test="${fn:toLowerCase(doc.fileType) eq 'jpg' or 
                         fn:toLowerCase(doc.fileType) eq 'jpeg' or
                         fn:toLowerCase(doc.fileType) eq 'png' or
                         fn:toLowerCase(doc.fileType) eq 'gif' or
                         fn:toLowerCase(doc.fileType) eq 'bmp' or
                         fn:toLowerCase(doc.fileType) eq 'tiff' or
                         fn:toLowerCase(doc.fileType) eq 'tif'}">
            <img src="${pageContext.request.contextPath}/api/documents/${doc.id}/content" alt="${doc.name}">
          </c:when>

          <%-- ONLYOFFICE compatible -- embed viewer --%>
          <c:when test="${doc.ooCompatible}">
            <div class="text-center">
              <div class="preview-icon ${fn:toLowerCase(doc.fileType) eq 'pdf' ? 'pdf' :
                fn:toLowerCase(doc.fileType) eq 'xlsx' or fn:toLowerCase(doc.fileType) eq 'xls' ? 'xlsx' :
                fn:toLowerCase(doc.fileType) eq 'pptx' or fn:toLowerCase(doc.fileType) eq 'ppt' ? 'pptx' : 'docx'}">
                <i class="bi ${fn:toLowerCase(doc.fileType) eq 'pdf' ? 'bi-filetype-pdf' :
                  fn:toLowerCase(doc.fileType) eq 'xlsx' or fn:toLowerCase(doc.fileType) eq 'xls' ? 'bi-filetype-xlsx' :
                  fn:toLowerCase(doc.fileType) eq 'pptx' or fn:toLowerCase(doc.fileType) eq 'ppt' ? 'bi-filetype-pptx' : 'bi-filetype-docx'}"></i>
              </div>
              <p class="text-muted mb-2">Document bureautique — visionneuse interactive disponible</p>
              <a href="${pageContext.request.contextPath}/viewer/${doc.id}" class="btn btn-dz" target="_blank">
                <i class="bi bi-eye me-2"></i>Ouvrir dans ONLYOFFICE
              </a>
            </div>
          </c:when>

          <%-- Email viewer --%>
          <c:when test="${fn:toLowerCase(doc.fileType) eq 'eml' or 
                         fn:toLowerCase(doc.fileType) eq 'msg' or
                         fn:toLowerCase(doc.fileType) eq 'mbox'}">
            <div class="text-center">
              <div class="preview-icon email">
                <i class="bi bi-envelope"></i>
              </div>
              <p class="text-muted">Email — sera converti en PDF par Apache Tika</p>
            </div>
          </c:when>

          <%-- Fallback --%>
          <c:otherwise>
            <div class="text-center">
              <div class="preview-icon docx">
                <i class="bi bi-file-earmark"></i>
              </div>
              <p class="text-muted">Document — sera converti en PDF par ${doc.library}</p>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
    </div>

    <!-- ═══ Paneau droit : Contrôles de conversion ═══ -->
    <div class="split-controls">
      <div class="controls-header">
        <h5 class="mb-0"><i class="bi bi-tools me-2"></i>Conversion</h5>
      </div>
      <div class="controls-body">
        <dl class="small mb-3">
          <dt>Format source</dt>
          <dd><span class="badge bg-dz">${fn:toUpperCase(doc.fileType)}</span></dd>
          <dt>Librairie</dt>
          <dd>${doc.library}</dd>
          <dt>Catégorie</dt>
          <dd>${doc.category}</dd>
        </dl>

        <form method="post" action="${pageContext.request.contextPath}/convert/${doc.id}" 
              class="d-grid gap-2" id="convertForm">
          <button type="button" class="btn btn-dz" id="convertBtn">
            <i class="bi bi-arrow-repeat me-2"></i>Convertir en PDF
          </button>
          <c:if test="${doc.ooCompatible}">
            <a href="${pageContext.request.contextPath}/viewer/${doc.id}" class="btn btn-dz-outline">
              <i class="bi bi-eye me-2"></i>Ouvrir dans ONLYOFFICE
            </a>
          </c:if>
        </form>

        <!-- ═══ Barre de progression ═══ -->
        <div id="progressContainer" style="display:none;">
          <hr>
          <div class="mb-2 d-flex align-items-center gap-2">
            <i class="bi bi-arrow-repeat text-dz fs-5" id="progressIcon"></i>
            <small class="text-muted" id="progressLabel">Analyse du document...</small>
          </div>
          <div class="progress" style="height:10px;" role="progressbar">
            <div class="progress-bar progress-bar-striped progress-bar-animated bg-dz" 
                 id="progressBar" style="width:0%"></div>
          </div>
          <div class="d-flex justify-content-between mt-1">
            <small class="text-muted" id="progressStage">Étape 1/5</small>
            <small class="text-muted" id="progressPct">0%</small>
          </div>
          <!-- Étapes de progression -->
          <div class="mt-3 small" id="progressSteps">
            <div class="d-flex align-items-center gap-2 mb-1 step" data-pct="15">
              <span class="step-indicator">○</span>
              <span class="step-label">Analyse du document source</span>
            </div>
            <div class="d-flex align-items-center gap-2 mb-1 step" data-pct="35">
              <span class="step-indicator">○</span>
              <span class="step-label">Extraction du contenu</span>
            </div>
            <div class="d-flex align-items-center gap-2 mb-1 step" data-pct="60">
              <span class="step-indicator">○</span>
              <span class="step-label">Conversion du format</span>
            </div>
            <div class="d-flex align-items-center gap-2 mb-1 step" data-pct="80">
              <span class="step-indicator">○</span>
              <span class="step-label">Génération du PDF</span>
            </div>
            <div class="d-flex align-items-center gap-2 mb-1 step" data-pct="95">
              <span class="step-indicator">○</span>
              <span class="step-label">Finalisation</span>
            </div>
          </div>
        </div>

        <!-- ═══ Résultat de conversion ═══ -->
        <div id="resultContainer">
          <c:if test="${not empty result}">
            <hr>
            <div class="card border-0 ${result.success ? 'bg-success-subtle' : 'bg-danger-subtle'}">
              <div class="card-body p-3">
                <div class="d-flex align-items-center gap-2 mb-2">
                  <c:choose>
                    <c:when test="${result.success}">
                      <i class="bi bi-check-circle-fill text-success fs-5"></i>
                      <strong class="text-success">Conversion réussie</strong>
                    </c:when>
                    <c:otherwise>
                      <i class="bi bi-x-circle-fill text-danger fs-5"></i>
                      <strong class="text-danger">Échec</strong>
                    </c:otherwise>
                  </c:choose>
                </div>
                <dl class="small mb-0">
                  <dt>Librairie</dt>
                  <dd class="mb-1">${result.libraryName}</dd>
                  <dt>Durée</dt>
                  <dd class="mb-1">${result.durationMs} ms</dd>
                  <c:if test="${result.success}">
                    <dt>PDF généré</dt>
                    <dd class="mb-1">${result.outputSizeBytes} octets</dd>
                  </c:if>
                  <dt>Notes</dt>
                  <dd><small>${result.notes}</small></dd>
                </dl>
                <c:if test="${result.success}">
                  <div class="d-grid gap-2 mt-3">
                    <a href="${pageContext.request.contextPath}/output/${result.outputFileName}" 
                       class="btn btn-dz btn-sm" target="_blank">
                      <i class="bi bi-download me-2"></i>Télécharger le PDF
                    </a>
                    <a href="${pageContext.request.contextPath}/output/${result.outputFileName}" 
                       class="btn btn-dz-outline btn-sm" target="_blank">
                      <i class="bi bi-eye me-2"></i>Aperçu du PDF
                    </a>
                  </div>
                </c:if>
              </div>
            </div>
          </c:if>
        </div>
      </div>
    </div>

  </div>

  <d:footer/>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
          integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
          crossorigin="anonymous"></script>

  <style>
    .step-indicator {
      width: 20px; height: 20px;
      display: inline-flex; align-items: center; justify-content: center;
      border-radius: 50%;
      font-size: 0.75rem;
      font-weight: 700;
      border: 2px solid #dee2e6;
      color: #adb5bd;
      flex-shrink: 0;
      transition: all 0.3s ease;
    }
    .step.done .step-indicator {
      background: var(--dz-green);
      border-color: var(--dz-green);
      color: #fff;
    }
    .step.active .step-indicator {
      border-color: var(--dz-green);
      color: var(--dz-green);
      background: var(--dz-green-light);
    }
    .step.done .step-label { color: var(--dz-text); }
    .step.active .step-label { color: var(--dz-green); font-weight: 600; }
    .step-label { transition: all 0.3s ease; color: #adb5bd; }
  </style>

  <script>
  (function() {
    'use strict';

    var convertBtn = document.getElementById('convertBtn');
    var convertForm = document.getElementById('convertForm');
    var progressContainer = document.getElementById('progressContainer');
    var resultContainer = document.getElementById('resultContainer');
    var progressBar = document.getElementById('progressBar');
    var progressLabel = document.getElementById('progressLabel');
    var progressStage = document.getElementById('progressStage');
    var progressPct = document.getElementById('progressPct');
    var progressIcon = document.getElementById('progressIcon');
    var steps = document.querySelectorAll('.step');

    var stages = [
      { pct: 15, label: 'Analyse du document source' },
      { pct: 35, label: 'Extraction du contenu' },
      { pct: 60, label: 'Conversion du format' },
      { pct: 80, label: 'Génération du PDF' },
      { pct: 95, label: 'Finalisation' },
    ];

    function updateProgress(pct, stageIdx) {
      progressBar.style.width = pct + '%';
      progressPct.textContent = pct + '%';
      progressStage.textContent = 'Étape ' + (stageIdx + 1) + '/' + stages.length;
      if (stages[stageIdx]) {
        progressLabel.textContent = stages[stageIdx].label;
      }
      // Update step indicators
      steps.forEach(function(s, i) {
        s.classList.remove('done', 'active');
        if (i < stageIdx) s.classList.add('done');
        else if (i === stageIdx) s.classList.add('active');
      });
      // Update icon
      if (pct >= 100) {
        progressIcon.className = 'bi bi-check-circle-fill text-success fs-5';
      } else if (stageIdx >= 2) {
        progressIcon.className = 'bi bi-arrow-repeat text-dz fs-5 spinner-dz-sm';
        progressIcon.style.animation = 'spin 0.8s linear infinite';
      } else {
        progressIcon.className = 'bi bi-arrow-repeat text-dz fs-5';
        progressIcon.style.animation = '';
      }
    }

    convertBtn.addEventListener('click', function() {
      var btn = this;
      var origHtml = btn.innerHTML;

      // Disable button
      btn.disabled = true;
      btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Conversion en cours...';

      // Hide result, show progress
      resultContainer.style.display = 'none';
      progressContainer.style.display = 'block';
      updateProgress(0, 0);

      // Reset steps
      steps.forEach(function(s) { s.classList.remove('done', 'active'); });

      // Animate progress through stages on a timer
      var stageIdx = 0;
      var currentPct = 0;
      var animId = null;

      function animateProgress() {
        if (stageIdx >= stages.length) {
          // Keep at 95% waiting for response
          updateProgress(95, stages.length - 1);
          return;
        }
        var target = stages[stageIdx].pct;
        // Progress animation speed
        currentPct += Math.random() * 3 + 1;
        if (currentPct >= target) {
          currentPct = target;
          // Move to next stage
          steps[stageIdx].classList.add('done');
          stageIdx++;
          if (stageIdx < stages.length) {
            steps[stageIdx].classList.add('active');
            updateProgress(currentPct, stageIdx);
            animId = setTimeout(animateProgress, 500 + Math.random() * 400);
          } else {
            updateProgress(currentPct, stages.length - 1);
          }
          return;
        }
        updateProgress(currentPct, stageIdx);
        animId = setTimeout(animateProgress, 200 + Math.random() * 300);
      }

      animId = setTimeout(animateProgress, 300);

      // Submit via fetch
      fetch(convertForm.action, {
        method: 'POST',
        headers: { 'X-Requested-With': 'XMLHttpRequest' },
        body: new FormData(convertForm)
      })
      .then(function(resp) { return resp.text(); })
      .then(function(html) {
        // Cancel animation
        if (animId) clearTimeout(animId);

        // Jump to 100%
        updateProgress(100, stages.length - 1);
        steps.forEach(function(s) { s.classList.add('done'); });
        progressLabel.textContent = 'Conversion terminée ✓';
        progressStage.textContent = 'Terminé';

        // Extract result from response HTML
        var parser = new DOMParser();
        var doc = parser.parseFromString(html, 'text/html');
        var newResult = doc.getElementById('resultContainer');
        if (newResult) {
          resultContainer.innerHTML = newResult.innerHTML;
        }

        // Show result after a brief delay
        setTimeout(function() {
          progressContainer.style.display = 'none';
          resultContainer.style.display = 'block';
          btn.disabled = false;
          btn.innerHTML = '<i class="bi bi-arrow-repeat me-2"></i>Convertir en PDF';
        }, 600);
      })
      .catch(function(err) {
        if (animId) clearTimeout(animId);
        progressContainer.style.display = 'none';
        resultContainer.style.display = 'block';
        resultContainer.innerHTML = '<hr><div class="alert alert-danger">Erreur de conversion: ' + err.message + '</div>';
        btn.disabled = false;
        btn.innerHTML = origHtml;
      });
    });

    // Add spinner animation for progress icon
    var style = document.createElement('style');
    style.textContent = '.spinner-dz-sm { display: inline-block; }';
    document.head.appendChild(style);

    // Preview toggle on mobile
    var previewToggle = document.getElementById('previewToggle');
    var splitPreview = document.querySelector('.split-preview');
    if (previewToggle && splitPreview) {
      var previewVisible = true;
      previewToggle.addEventListener('click', function() {
        previewVisible = !previewVisible;
        splitPreview.style.display = previewVisible ? '' : 'none';
        previewToggle.innerHTML = previewVisible
          ? '<i class="bi bi-eye-slash"></i><span class="d-none d-sm-inline"> Aperçu</span>'
          : '<i class="bi bi-eye"></i><span class="d-none d-sm-inline"> Aperçu</span>';
      });
      // Reset on resize above breakpoint
      window.addEventListener('resize', function() {
        if (window.innerWidth > 768 && !previewVisible) {
          previewVisible = true;
          splitPreview.style.display = '';
          previewToggle.innerHTML = '<i class="bi bi-eye-slash"></i><span class="d-none d-sm-inline"> Aperçu</span>';
        }
      });
    }

  })();
  </script>
</body>
</html>
