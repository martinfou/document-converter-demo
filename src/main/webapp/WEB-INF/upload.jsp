<%--
  upload.jsp — Upload a document to test with all compatible converters.
  Drag-and-drop interface, Desjardins theme.
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
    .upload-zone {
      border: 2px dashed var(--dz-border);
      border-radius: 16px;
      padding: 3rem 2rem;
      text-align: center;
      cursor: pointer;
      transition: all 0.25s ease;
      background: var(--dz-bg);
    }
    .upload-zone:hover,
    .upload-zone.dragover {
      border-color: var(--dz-green);
      background: var(--dz-green-light);
      box-shadow: 0 0 0 4px rgba(0, 132, 61, 0.1);
    }
    .upload-zone.dragover .upload-icon {
      transform: scale(1.1);
    }
    .upload-zone.has-file {
      border-color: var(--dz-green);
      background: var(--dz-green-lighter);
    }
    .upload-icon {
      font-size: 4rem;
      color: var(--dz-green);
      transition: transform 0.2s ease;
      display: block;
      margin-bottom: 1rem;
    }
    .upload-zone .btn {
      pointer-events: none;
    }
    #fileInput {
      display: none;
    }
    .format-badge {
      display: inline-block;
      padding: 2px 8px;
      margin: 2px;
      border-radius: 4px;
      background: var(--dz-green-light);
      color: var(--dz-green);
      font-size: 0.75rem;
      font-weight: 600;
      letter-spacing: 0.3px;
    }
    .file-info {
      display: none;
      margin-top: 1rem;
      padding: 1rem;
      background: var(--dz-green-light);
      border-radius: 8px;
    }
    .file-info.visible {
      display: block;
    }
    .custom-filename {
      display: none;
      margin-top: 1rem;
    }
    .custom-filename.visible {
      display: block;
    }
    .error-alert {
      border-left: 4px solid #dc3545;
    }
    .format-grid {
      display: flex;
      flex-wrap: wrap;
      gap: 4px;
      justify-content: center;
      margin-top: 0.5rem;
    }
    .spinner-overlay {
      display: none;
      position: fixed;
      inset: 0;
      background: rgba(255,255,255,0.85);
      z-index: 9999;
      align-items: center;
      justify-content: center;
      flex-direction: column;
    }
    .spinner-overlay.active {
      display: flex;
    }
    @media (max-width: 576px) {
      .upload-zone { padding: 2rem 1rem; }
      .upload-icon { font-size: 3rem; }
    }
  </style>
</head>
<body class="d-flex flex-column">

  <d:header pageTitle="Tester un document" totalDocs="0" activeTab="upload"/>

  <main class="container py-4 flex-grow-1">
    <div class="row justify-content-center">
      <div class="col-12 col-lg-8">

        <div class="d-flex align-items-center gap-3 mb-4">
          <div class="d-flex align-items-center justify-content-center"
               style="width:48px;height:48px;border-radius:12px;
                      background:var(--dz-green-light);color:var(--dz-green);font-size:1.5rem;">
            <i class="bi bi-cloud-upload"></i>
          </div>
          <div>
            <h4 class="mb-1">Tester un document</h4>
            <p class="text-muted mb-0 small">
              Importez un fichier pour le tester avec <strong>${converterCount} convertisseurs</strong>
              Java différents. Résultats comparés côte à côte.
            </p>
          </div>
        </div>

        <c:if test="${not empty error}">
          <div class="alert alert-danger error-alert d-flex align-items-center gap-2 py-3" role="alert">
            <i class="bi bi-exclamation-triangle-fill fs-5"></i>
            <div>
              <strong>Erreur</strong><br>
              <span>${error}</span>
              <c:if test="${not empty supportedExts}">
                <div class="mt-2">
                  <small>Formats supportés :</small>
                  <div class="format-grid">
                    <c:forTokens var="ext" items="${supportedExts}" delims=",">
                      <span class="format-badge">${fn:toUpperCase(fn:trim(ext))}</span>
                    </c:forTokens>
                  </div>
                </div>
              </c:if>
            </div>
          </div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/upload"
              enctype="multipart/form-data" id="uploadForm">

          <!-- Drop zone -->
          <div class="upload-zone" id="dropZone">
            <i class="bi bi-cloud-arrow-up upload-icon"></i>
            <h5 class="mb-2">Déposez un fichier ici</h5>
            <p class="text-muted mb-3 small">ou cliquez pour parcourir</p>
            <button type="button" class="btn btn-dz" id="browseBtn">
              <i class="bi bi-folder2-open me-2"></i>Parcourir
            </button>
            <input type="file" id="fileInput" name="file"
                   accept=".docx,.doc,.xlsx,.xls,.pptx,.ppt,.tiff,.tif,.jpg,.jpeg,.png,.gif,.bmp,.eml,.msg,.mbox,.pdf">

            <!-- File info -->
            <div class="file-info" id="fileInfo">
              <div class="d-flex align-items-center gap-3">
                <i class="bi bi-file-earmark-check fs-2 text-dz"></i>
                <div class="text-start flex-grow-1">
                  <strong id="fileName">—</strong><br>
                  <small class="text-muted" id="fileSize">—</small>
                  <span class="format-badge ms-2" id="fileFormat">—</span>
                </div>
                <button type="button" class="btn btn-sm btn-dz-outline" id="changeFileBtn"
                        title="Changer de fichier">
                  <i class="bi bi-arrow-repeat"></i>
                </button>
              </div>
            </div>
          </div>

          <!-- Custom filename (optional) -->
          <div class="custom-filename" id="customFilename">
            <label class="form-label small text-muted">
              <i class="bi bi-pencil me-1"></i>Renommer (optionnel)
            </label>
            <input type="text" class="form-control form-control-sm" name="filename"
                   id="filenameInput" placeholder="mon-document.docx"
                   style="max-width:400px">
          </div>

          <div class="d-grid gap-2 mt-4">
            <button type="submit" class="btn btn-dz btn-lg" id="submitBtn" disabled>
              <i class="bi bi-arrow-repeat me-2"></i>Tester avec tous les convertisseurs
            </button>
          </div>

          <div class="text-center mt-3">
            <small class="text-muted">
              <i class="bi bi-info-circle me-1"></i>
              Formats supportés :
            </small>
            <div class="format-grid">
              <c:forTokens var="ext" items="${supportedExts}" delims=",">
                <span class="format-badge">${fn:toUpperCase(fn:trim(ext))}</span>
              </c:forTokens>
            </div>
          </div>

        </form>
      </div>
    </div>
  </main>

  <!-- Spinner overlay -->
  <div class="spinner-overlay" id="spinnerOverlay">
    <div class="spinner-border text-dz" style="width:3rem;height:3rem;" role="status">
      <span class="visually-hidden">Conversion en cours...</span>
    </div>
    <p class="mt-3 fw-medium text-dz">Analyse avec tous les convertisseurs...</p>
    <small class="text-muted">${converterCount} convertisseurs en parallèle</small>
  </div>

  <d:footer/>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
          integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
          crossorigin="anonymous"></script>

  <script>
  (function() {
    'use strict';

    var dropZone = document.getElementById('dropZone');
    var fileInput = document.getElementById('fileInput');
    var browseBtn = document.getElementById('browseBtn');
    var fileInfo = document.getElementById('fileInfo');
    var fileName = document.getElementById('fileName');
    var fileSize = document.getElementById('fileSize');
    var fileFormat = document.getElementById('fileFormat');
    var changeFileBtn = document.getElementById('changeFileBtn');
    var submitBtn = document.getElementById('submitBtn');
    var uploadForm = document.getElementById('uploadForm');
    var spinnerOverlay = document.getElementById('spinnerOverlay');
    var customFilename = document.getElementById('customFilename');
    var filenameInput = document.getElementById('filenameInput');

    var selectedFile = null;

    function formatSize(bytes) {
      if (bytes < 1024) return bytes + ' o';
      if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' Ko';
      return (bytes / (1024 * 1024)).toFixed(1) + ' Mo';
    }

    function handleFile(file) {
      selectedFile = file;
      var ext = file.name.split('.').pop().toLowerCase();

      fileName.textContent = file.name;
      fileSize.textContent = formatSize(file.size);
      fileFormat.textContent = ext.toUpperCase();
      fileInfo.classList.add('visible');
      dropZone.classList.add('has-file');
      submitBtn.disabled = false;

      // Auto-fill filename input
      filenameInput.value = file.name;
      customFilename.classList.add('visible');
    }

    function clearFile() {
      selectedFile = null;
      fileInfo.classList.remove('visible');
      dropZone.classList.remove('has-file');
      customFilename.classList.remove('visible');
      submitBtn.disabled = true;
      fileInput.value = '';
    }

    // Browse button
    browseBtn.addEventListener('click', function(e) {
      e.stopPropagation();
      fileInput.click();
    });

    // Drop zone click → file picker
    dropZone.addEventListener('click', function() {
      fileInput.click();
    });

    // File input change
    fileInput.addEventListener('change', function() {
      if (this.files && this.files.length > 0) {
        handleFile(this.files[0]);
      }
    });

    // Change file button
    changeFileBtn.addEventListener('click', function(e) {
      e.stopPropagation();
      clearFile();
      fileInput.click();
    });

    // Drag and drop
    ['dragenter', 'dragover'].forEach(function(evt) {
      dropZone.addEventListener(evt, function(e) {
        e.preventDefault();
        e.stopPropagation();
        dropZone.classList.add('dragover');
      });
    });
    ['dragleave', 'drop'].forEach(function(evt) {
      dropZone.addEventListener(evt, function(e) {
        e.preventDefault();
        e.stopPropagation();
        dropZone.classList.remove('dragover');
      });
    });
    dropZone.addEventListener('drop', function(e) {
      var files = e.dataTransfer.files;
      if (files && files.length > 0) {
        // Update the file input for proper form submission
        var dt = new DataTransfer();
        dt.items.add(files[0]);
        fileInput.files = dt.files;
        handleFile(files[0]);
      }
    });

    // Submit → show spinner
    uploadForm.addEventListener('submit', function() {
      if (selectedFile) {
        spinnerOverlay.classList.add('active');
      }
    });

  })();
  </script>
</body>
</html>
