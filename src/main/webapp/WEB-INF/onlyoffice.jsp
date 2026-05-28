<%--
  onlyoffice.jsp — Page ONLYOFFICE.
  Liste les documents compatibles avec la visionneuse ONLYOFFICE.
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
  <title>Visionneuse ONLYOFFICE — Desjardins</title>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" 
        rel="stylesheet"
        integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" 
        crossorigin="anonymous">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" 
        rel="stylesheet">
  <link href="${pageContext.request.contextPath}/static/css/desjardins.css" rel="stylesheet">

  <style>
    .oo-hero {
      background: linear-gradient(135deg, var(--dz-green) 0%, #006b30 100%);
      color: #fff;
      border-radius: 12px;
      padding: 2rem;
      margin-bottom: 2rem;
    }
    .oo-hero h2 { font-size: 1.5rem; margin-bottom: 0.5rem; }
    .oo-hero p { opacity: 0.9; font-size: 0.9rem; margin-bottom: 0; }
    .oo-hero .badge { background: rgba(255,255,255,0.2); font-size: 0.8rem; }
    @media (max-width: 576px) {
      .oo-hero { padding: 1.25rem; border-radius: 8px; }
      .oo-hero h2 { font-size: 1.15rem; }
      .oo-hero p { font-size: 0.8rem; }
      .oo-hero .d-flex { flex-direction: column; text-align: center; }
      .oo-hero .badge { font-size: 0.7rem; }
    }
  </style>
</head>
<body class="d-flex flex-column">

  <d:header pageTitle="ONLYOFFICE" totalDocs="${fn:length(ooDocuments)}" activeTab="onlyoffice"/>

  <main class="container py-4 flex-grow-1">
    <div class="oo-hero">
      <div class="d-flex align-items-center gap-3">
        <i class="bi bi-eye" style="font-size:2.5rem"></i>
        <div>
          <h2><i class="bi bi-onlyoffice me-2"></i>Visionneuse ONLYOFFICE</h2>
          <p>Documents bureautiques visualisés en ligne avec le Document Server. 
             Cliquez sur un document pour l'ouvrir dans la visionneuse interactive.</p>
          <div>
            <span class="badge me-2"><i class="bi bi-filetype-docx me-1"></i>DOCX</span>
            <span class="badge me-2"><i class="bi bi-filetype-xlsx me-1"></i>XLSX</span>
            <span class="badge me-2"><i class="bi bi-filetype-pptx me-1"></i>PPTX</span>
            <span class="badge me-2"><i class="bi bi-filetype-pdf me-1"></i>PDF</span>
            <span class="badge"><i class="bi bi-filetype-doc me-1"></i>DOC</span>
          </div>
        </div>
      </div>
    </div>

    <c:choose>
      <c:when test="${empty ooDocuments}">
        <div class="empty-state">
          <i class="bi bi-inbox"></i>
          <h4 class="mt-3">Aucun document compatible</h4>
          <p class="text-muted">Les documents ONLYOFFICE sont gérés par le Document Server externe.</p>
        </div>
      </c:when>
      <c:otherwise>
        <div class="row">
          <c:forEach var="doc" items="${ooDocuments}">
            <div class="col-12 col-sm-6 col-lg-4 mb-3">
              <a href="${pageContext.request.contextPath}/viewer/${doc.id}" 
                 class="text-decoration-none">
                <div class="card border-0 shadow-sm oo-card h-100">
                  <div class="card-body d-flex align-items-center gap-3">
                    <div class="oo-icon ${fn:toLowerCase(doc.fileType) eq 'pdf' ? 'card-icon-pdf' : 
                      fn:toLowerCase(doc.fileType) eq 'xlsx' or fn:toLowerCase(doc.fileType) eq 'xls' ? 'card-icon-xlsx' :
                      fn:toLowerCase(doc.fileType) eq 'pptx' ? 'card-icon-pptx' : 'card-icon-docx'}">
                      <i class="bi ${fn:toLowerCase(doc.fileType) eq 'pdf' ? 'bi-filetype-pdf' : 
                        fn:toLowerCase(doc.fileType) eq 'xlsx' or fn:toLowerCase(doc.fileType) eq 'xls' ? 'bi-filetype-xlsx' :
                        fn:toLowerCase(doc.fileType) eq 'pptx' ? 'bi-filetype-pptx' : 'bi-filetype-docx'}"></i>
                    </div>
                    <div class="min-w-0">
                      <h6 class="mb-1 text-truncate" style="color:var(--dz-text)">${doc.name}</h6>
                      <small class="text-muted">${doc.category} &middot; ${fn:toUpperCase(doc.fileType)}</small>
                    </div>
                    <i class="bi bi-chevron-right ms-auto text-muted"></i>
                  </div>
                </div>
              </a>
            </div>
          </c:forEach>
        </div>
      </c:otherwise>
    </c:choose>

    <div class="alert alert-info mt-4">
      <i class="bi bi-info-circle me-2"></i>
      La visionneuse se connecte à <strong>ods-document-server.fly.dev</strong> (ONLYOFFICE Document Server).
      Formats supportés : DOCX, XLSX, PPTX, PDF, DOC, XLS, PPT, ODT, ODS, ODP, CSV, TXT, RTF, HTML.
    </div>
  </main>

  <d:footer/>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
          integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
          crossorigin="anonymous"></script>
</body>
</html>
