package com.docviewer.controller;

import com.docconverter.api.ConvertResult;
import com.docviewer.service.ConverterService;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.core.io.FileSystemResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Duration;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Main controller: document listing, Java conversion, ONLYOFFICE viewer.
 *
 * Couleurs Desjardins partout dans les vues JSP.
 */
@Controller
public class DocumentController {

    private static final ObjectMapper JSON = new ObjectMapper();
    private static final HttpClient HTTP = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();

    private final ResourceLoader resourceLoader;
    private final ConverterService converterService;

    @Value("${onlyoffice.ds.url:http://localhost:3080}")
    private String dsBaseUrl;

    @Value("${onlyoffice.docservice.url:}")
    private String docserviceUrl;

    @Value("${server.url:http://localhost:8080}")
    private String serverUrl;

    private List<Map<String, Object>> documents;

    public DocumentController(ResourceLoader resourceLoader, ConverterService converterService) {
        this.resourceLoader = resourceLoader;
        this.converterService = converterService;
    }

    @PostConstruct
    public void init() {
        loadDocuments();
        if (docserviceUrl.isEmpty()) {
            docserviceUrl = dsBaseUrl;
        }
    }

    @SuppressWarnings("unchecked")
    private void loadDocuments() {
        try {
            Resource res = resourceLoader.getResource("classpath:documents.json");
            try (InputStream is = res.getInputStream()) {
                documents = JSON.readValue(is, new TypeReference<List<Map<String, Object>>>() {});
            }
        } catch (IOException e) {
            documents = new ArrayList<>();
        }
    }

    // ════════════════════════════════════════════
    // Pages
    // ════════════════════════════════════════════

    /** Page d'accueil : grille de tous les documents avec convertisseurs. */
    @GetMapping("/")
    public String index(Model model) {
        model.addAttribute("documents", documents);
        model.addAttribute("totalDocs", documents.size());
        model.addAttribute("pageTitle", "Convertisseurs Java");
        return "index";
    }

    /** Page ONLYOFFICE : documents compatibles avec ODS. */
    @GetMapping("/onlyoffice")
    public String onlyoffice(Model model) {
        List<Map<String, Object>> ooDocs = documents.stream()
                .filter(d -> {
                    Object oo = d.get("ooCompatible");
                    return oo instanceof Boolean && (Boolean) oo;
                })
                .collect(Collectors.toList());
        model.addAttribute("ooDocuments", ooDocs);
        model.addAttribute("totalDocs", ooDocs.size());
        model.addAttribute("pageTitle", "Visionneuse ONLYOFFICE");
        return "onlyoffice";
    }

    /** Page de conversion d'un document. */
    @GetMapping("/convert/{docId}")
    public String convertForm(@PathVariable String docId, Model model) {
        Map<String, Object> doc = findDocument(docId);
        if (doc == null) {
            return "redirect:/";
        }
        model.addAttribute("doc", doc);
        model.addAttribute("pageTitle", "Convertir : " + doc.get("name"));
        return "convertView";
    }

    /** POST: exécute la conversion et affiche le résultat. */
    @PostMapping("/convert/{docId}")
    public String convert(@PathVariable String docId, Model model) {
        Map<String, Object> doc = findDocument(docId);
        if (doc == null) {
            return "redirect:/";
        }
        model.addAttribute("doc", doc);
        model.addAttribute("pageTitle", "Conversion : " + doc.get("name"));

        String filePath = (String) doc.get("filePath");
        if (filePath == null) {
            model.addAttribute("result", ConvertResult.failed("demo", docId, "No file path configured"));
            return "convertView";
        }

        // Resolve file path — try file: then classpath:
        Path inputPath;
        try {
            Resource res;
            try {
                res = resourceLoader.getResource("file:" + filePath);
                res.getInputStream();
            } catch (IOException e) {
                res = resourceLoader.getResource("classpath:" + filePath);
            }
            // If it's a classpath resource inside a JAR, copy to temp file
            try {
                inputPath = res.getFile().toPath();
            } catch (IOException e) {
                // Resource is inside JAR — copy to temp
                Path tempFile = Files.createTempFile("doc-conv-", "." + getExtension(filePath));
                try (InputStream is = res.getInputStream()) {
                    Files.copy(is, tempFile, java.nio.file.StandardCopyOption.REPLACE_EXISTING);
                }
                tempFile.toFile().deleteOnExit();
                inputPath = tempFile;
            }
        } catch (IOException e) {
            model.addAttribute("result", ConvertResult.failed("demo", filePath, "File not found: " + e.getMessage()));
            return "convertView";
        }

        // Run conversion
        ConvertResult result = converterService.convert(inputPath);
        model.addAttribute("result", result);
        return "convertView";
    }

    /** Sert un fichier PDF converti en téléchargement. */
    @GetMapping("/output/{filename:.+}")
    public ResponseEntity<FileSystemResource> serveOutput(@PathVariable String filename) {
        File file = converterService.getOutputDir().resolve(filename).toFile();
        if (!file.exists()) {
            return ResponseEntity.notFound().build();
        }

        MediaType mediaType = filename.toLowerCase().endsWith(".pdf")
                ? MediaType.APPLICATION_PDF
                : MediaType.APPLICATION_OCTET_STREAM;

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + filename + "\"")
                .contentType(mediaType)
                .body(new FileSystemResource(file));
    }

    /** Page de visionneuse ONLYOFFICE pour un document. */
    @GetMapping("/viewer/{docId}")
    public String viewer(@PathVariable String docId, Model model) throws IOException {
        Map<String, Object> doc = findDocument(docId);
        if (doc == null) {
            return "redirect:/";
        }

        // Construire la config ONLYOFFICE pour la visionneuse
        ObjectNode ooConfig = buildOnlyOfficeConfig(doc);

        model.addAttribute("doc", doc);
        model.addAttribute("ooconfig", JSON.writeValueAsString(ooConfig));
        model.addAttribute("dsUrl", docserviceUrl);
        model.addAttribute("pageTitle", doc.get("name") + " — Visionneuse");
        return "viewer";
    }

    // ════════════════════════════════════════════
    // API interne pour ONLYOFFICE
    // ════════════════════════════════════════════

    @GetMapping("/api/documents/{docId}/content")
    public ResponseEntity<byte[]> serveDocumentContent(@PathVariable String docId) throws IOException {
        Map<String, Object> doc = findDocument(docId);
        if (doc == null) {
            throw new IOException("Document not found: " + docId);
        }
        String path = (String) doc.get("filePath");
        // Try file: first (runtime-generated), then classpath: (baked into WAR)
        byte[] data;
        try {
            Resource res = resourceLoader.getResource("file:" + path);
            try (InputStream is = res.getInputStream()) {
                data = is.readAllBytes();
            }
        } catch (IOException e) {
            Resource res = resourceLoader.getResource("classpath:" + path);
            try (InputStream is = res.getInputStream()) {
                data = is.readAllBytes();
            }
        }

        // Determine content type from file extension
        String ext = "";
        int dot = path.lastIndexOf('.');
        if (dot >= 0) ext = path.substring(dot + 1).toLowerCase();
        MediaType mediaType = switch (ext) {
            case "pdf" -> MediaType.APPLICATION_PDF;
            case "jpg", "jpeg" -> MediaType.IMAGE_JPEG;
            case "png" -> MediaType.IMAGE_PNG;
            case "gif" -> MediaType.IMAGE_GIF;
            case "bmp" -> MediaType.parseMediaType("image/bmp");
            case "tiff", "tif" -> MediaType.parseMediaType("image/tiff");
            default -> MediaType.APPLICATION_OCTET_STREAM;
        };

        String filename = path.contains("/") ? path.substring(path.lastIndexOf('/') + 1) : path;
        return ResponseEntity.ok()
                .contentType(mediaType)
                .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + filename + "\"")
                .body(data);
    }

    @PostMapping("/api/documents/{docId}/key")
    @ResponseBody
    public Map<String, Object> generateKey(@PathVariable String docId) {
        Map<String, Object> doc = findDocument(docId);
        if (doc == null) {
            return Map.of("error", "not found");
        }
        String key = UUID.nameUUIDFromBytes(docId.getBytes()).toString();
        return Map.of("key", key);
    }

    // ════════════════════════════════════════════
    // Helpers
    // ════════════════════════════════════════════

    private Map<String, Object> findDocument(String docId) {
        return documents.stream()
                .filter(d -> docId.equals(d.get("id")))
                .findFirst()
                .orElse(null);
    }

    private String getExtension(String path) {
        int dot = path.lastIndexOf('.');
        return dot >= 0 ? path.substring(dot + 1) : "";
    }

    private ObjectNode buildOnlyOfficeConfig(Map<String, Object> doc) {
        String docId = (String) doc.get("id");
        String name = (String) doc.get("name");
        String fileType = (String) doc.get("fileType");
        String filePath = (String) doc.get("filePath");

        String fileUrl = serverUrl + "/api/documents/" + docId + "/content";
        String key = UUID.nameUUIDFromBytes(docId.getBytes()).toString();

        ObjectNode config = JSON.createObjectNode();

        ObjectNode document = JSON.createObjectNode();
        document.put("fileType", fileType != null ? fileType : "docx");
        document.put("key", key);
        document.put("title", name != null ? name : "Document");
        document.put("url", fileUrl);

        ObjectNode permissions = JSON.createObjectNode();
        permissions.put("comment", false);
        permissions.put("copy", true);
        permissions.put("download", true);
        permissions.put("edit", false);
        permissions.put("print", true);
        permissions.put("review", false);
        document.set("permissions", permissions);

        config.set("document", document);

        ObjectNode editorConfig = JSON.createObjectNode();
        editorConfig.put("mode", "view");
        editorConfig.put("callbackUrl", serverUrl + "/api/documents/" + docId + "/key");

        ObjectNode customization = JSON.createObjectNode();
        customization.put("autosave", false);
        customization.put("chat", false);
        customization.put("comments", false);
        customization.put("help", true);
        customization.put("hideRightMenu", false);
        customization.put("logo", JSON.createObjectNode()
                .put("image", serverUrl + "/static/img/desjardins-logo.png")
                .put("imageDark", serverUrl + "/static/img/desjardins-logo.png")
                .put("url", "https://www.desjardins.com"));
        customization.put("reviewDisplay", "original");
        customization.put("showPrintButton", true);
        // toolbarNoTabs force index_loader.html, absent de documenteditor/main/ en ODS 9.4+
        customization.put("customer", "Desjardins");
        customization.put("compactToolbar", false);
        customization.put("hidePlacementButtons", true);
        customization.put("showHorizontalScrollBar", true);
        customization.put("showVerticalScrollBar", true);
        customization.put("zoom", 100);

        String docType = "word";
        if (fileType != null) {
            String ft = fileType.toLowerCase();
            if (ft.equals("xlsx") || ft.equals("xls") || ft.equals("csv")) {
                docType = "cell";
            } else if (ft.equals("pptx") || ft.equals("ppt")) {
                docType = "slide";
            }
        }
        editorConfig.put("documentType", docType);
        config.put("documentType", docType);

        ObjectNode theme = JSON.createObjectNode();
        theme.put("primaryColor", "#00843D");
        theme.put("primaryHover", "#006b30");
        theme.put("primaryLight", "#e8f5e9");
        theme.put("text", "#1a1a1a");
        theme.put("textLight", "#6c757d");
        theme.put("bg", "#ffffff");
        theme.put("bgLight", "#f5faf5");
        theme.put("border", "#dee2e6");
        theme.put("success", "#00843D");
        theme.put("warning", "#ffc107");
        theme.put("danger", "#dc3545");
        customization.set("theme", theme);

        editorConfig.set("customization", customization);
        config.set("editorConfig", editorConfig);

        config.put("documentServerUrl", docserviceUrl + "/");
        config.put("width", "100%");
        config.put("height", "100%");
        config.put("type", "desktop");

        return config;
    }
}
