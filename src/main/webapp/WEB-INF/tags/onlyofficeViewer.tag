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
<!-- Loader (pleine hauteur du parent flex) -->
<div id="oo-loader" class="d-flex flex-column align-items-center justify-content-center" style="min-height:300px;flex:1;">
  <div class="spinner-dz mb-3"></div>
  <p class="text-muted small">Ouverture du document dans ONLYOFFICE...</p>
</div>

<!-- Conteneur de la visionneuse (pleine hauteur) -->
<div id="oo-container" style="display:none;width:100%;flex:1;min-height:300px;"></div>

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

  // Ajuster la hauteur du conteneur pour remplir tout l'espace
  config.height = "100%";
  config.width = "100%";

  // Ajouter le callback d'initialisation
  config.events = {
    'onAppReady': function() {
      var loader = document.getElementById('oo-loader');
      var container = document.getElementById('oo-container');
      if (loader) loader.style.display = 'none';
      if (container) container.style.display = 'block';
    },
    'onDocumentReady': function() {
      console.log('Document prêt dans ONLYOFFICE');
    },
    'onError': function(e) {
      var loader = document.getElementById('oo-loader');
      if (loader) {
        loader.innerHTML = '<div class="alert alert-warning m-3">' +
          'Impossible de charger le document. Vérifiez que le serveur ONLYOFFICE est accessible.' +
          '</div>';
      }
    }
  };

  try {
    var docEditor = new DocsAPI.DocEditor('oo-container', config);
  } catch(e) {
    var container = document.getElementById('oo-container');
    if (container) {
      container.innerHTML = '<div class="alert alert-danger m-3">' +
        'Erreur lors de l\'initialisation de la visionneuse ONLYOFFICE : ' + e.message +
        '</div>';
      container.style.display = 'block';
    }
    var loader = document.getElementById('oo-loader');
    if (loader) loader.style.display = 'none';
  }
})();
</script>
