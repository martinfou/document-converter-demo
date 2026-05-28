<%--
  onlyofficeViewer.tag — Intègre la visionneuse ONLYOFFICE.
  Attributs : configJson (String), dsUrl (String)
  Utilise 100% de la hauteur du parent (.viewer-wrapper en flex:1)
--%>
<%@ tag body-content="empty" %>
<%@ attribute name="configJson" required="true" type="java.lang.String" rtexprvalue="true" %>
<%@ attribute name="dsUrl" required="true" type="java.lang.String" rtexprvalue="true" %>
<%
  String safeConfig = configJson != null ?
    configJson.replace("\\", "\\\\").replace("\"", "\\\"") : "{}";
  String dsUrlClean = dsUrl != null ? dsUrl.replaceAll("/+$", "") : "";
%>
<!-- Un seul enfant flex : loader en overlay, conteneur en pleine hauteur -->
<div id="oo-viewer-root">
  <div id="oo-container"></div>
  <div id="oo-loader">
    <div class="spinner-dz mb-3"></div>
    <p class="text-muted small">Ouverture du document dans ONLYOFFICE...</p>
  </div>
</div>

<!-- ONLYOFFICE Document Editor API -->
<script type="text/javascript" src="<%= dsUrlClean %>/web-apps/apps/api/documents/api.js"></script>
<script>
(function() {
  'use strict';

  var config = null;
  try {
    config = JSON.parse('<%= safeConfig %>');
  } catch(e) {
    document.getElementById('oo-loader').innerHTML = 
      '<div class="alert alert-danger m-3">Erreur de configuration de la visionneuse.</div>';
    return;
  }

  if (!config) return;

  var docEditor = null;

  function viewerHeight() {
    var wrapper = document.querySelector('.viewer-wrapper');
    return wrapper && wrapper.clientHeight > 0
      ? wrapper.clientHeight + 'px'
      : '100%';
  }

  config.width = '100%';

  function hideLoader() {
    var loader = document.getElementById('oo-loader');
    if (loader) loader.classList.add('hidden');
  }

  // Ajouter le callback d'initialisation
  config.events = {
    'onAppReady': function() {
      hideLoader();
      if (docEditor && typeof docEditor.resizeEditor === 'function') {
        docEditor.resizeEditor();
      }
    },
    'onDocumentReady': function() {
      hideLoader();
      console.log('Document prêt dans ONLYOFFICE');
    },
    'onError': function(e) {
      console.error('ONLYOFFICE error:', e);
      var loader = document.getElementById('oo-loader');
      if (loader) {
        loader.innerHTML = '<div class="alert alert-warning m-3">' +
          'Impossible de charger le document. Vérifiez que le serveur ONLYOFFICE est accessible.' +
          (e && e.data ? ' (' + e.data + ')' : '') +
          '</div>';
      }
    }
  };

  window.addEventListener('resize', function() {
    if (docEditor && typeof docEditor.resizeEditor === 'function') {
      docEditor.resizeEditor();
    }
  });

  function startEditor() {
    config.height = viewerHeight();
    try {
      docEditor = new DocsAPI.DocEditor('oo-container', config);
    } catch(e) {
      var container = document.getElementById('oo-container');
      if (container) {
        container.innerHTML = '<div class="alert alert-danger m-3">' +
          'Erreur lors de l\'initialisation de la visionneuse ONLYOFFICE : ' + e.message +
          '</div>';
      }
      hideLoader();
    }
  }

  if (document.readyState === 'complete') {
    startEditor();
  } else {
    window.addEventListener('load', startEditor);
  }
})();
</script>
