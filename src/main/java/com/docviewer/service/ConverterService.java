package com.docviewer.service;

import com.docconverter.api.ConvertResult;
import com.docconverter.api.DocumentConverter;
import com.docconverter.impl.CommonsImagingConverter;
import com.docconverter.impl.Docx4jWordConverter;
import com.docconverter.impl.PdfBoxTiffConverter;
import com.docconverter.impl.PoiExcelConverter;
import com.docconverter.impl.PoiPresentationConverter;
import com.docconverter.impl.PoiWordConverter;
import com.docconverter.impl.TikaEmailConverter;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.*;

/**
 * Service de conversion utilisant les convertisseurs pure Java.
 *
 * Aucun serveur externe requis — tout tourne en Java natif.
 * Supporte tous les formats document courants → PDF.
 */
@Service
public class ConverterService {

    private static final Logger log = LoggerFactory.getLogger(ConverterService.class);

    private final Path outputDir;
    private final List<ConverterEntry> converters = new ArrayList<>();

    public ConverterService() {
        try {
            this.outputDir = Files.createTempDirectory("doc-converter-");
            this.outputDir.toFile().deleteOnExit();
        } catch (IOException e) {
            throw new RuntimeException("Cannot create temp output dir", e);
        }
    }

    @PostConstruct
    public void init() {
        // — Word Processing —
        converters.add(new ConverterEntry(
                "DOCX → PDF (docx4j)", "docx", "pdf",
                new Docx4jWordConverter(), "docx4j 11.5 (FOP)",
                "Word Processing"
        ));
        converters.add(new ConverterEntry(
                "DOC/DOCX → PDF (POI)", "doc", "pdf",
                new PoiWordConverter(), "Apache POI 5.4 + OpenPDF",
                "Word Processing"
        ));
        // POI also handles DOCX (text-only fallback), but docx4j wins for DOCX due to order
        converters.add(new ConverterEntry(
                "DOCX → PDF (POI text)", "docx_poi", "pdf",
                new PoiWordConverter(), "Apache POI 5.4 + OpenPDF",
                "Word Processing"
        ));

        // — Spreadsheets —
        converters.add(new ConverterEntry(
                "XLSX/XLS → PDF (POI)", "xlsx", "pdf",
                new PoiExcelConverter(), "Apache POI 5.4 + OpenPDF",
                "Spreadsheet"
        ));
        converters.add(new ConverterEntry(
                "XLS → PDF (POI)", "xls", "pdf",
                new PoiExcelConverter(), "Apache POI 5.4 + OpenPDF",
                "Spreadsheet"
        ));

        // — Presentations —
        converters.add(new ConverterEntry(
                "PPTX/PPT → PDF (POI)", "pptx", "pdf",
                new PoiPresentationConverter(), "Apache POI 5.4 + OpenPDF",
                "Presentation"
        ));
        converters.add(new ConverterEntry(
                "PPT → PDF (POI)", "ppt", "pdf",
                new PoiPresentationConverter(), "Apache POI 5.4 + OpenPDF",
                "Presentation"
        ));

        // — Image/Scan —
        converters.add(new ConverterEntry(
                "TIFF → PDF (PDFBox)", "tiff", "pdf",
                new PdfBoxTiffConverter(), "Apache PDFBox 3.0",
                "Image/Scan"
        ));
        converters.add(new ConverterEntry(
                "TIFF → PDF (PDFBox)", "tif", "pdf",
                new PdfBoxTiffConverter(), "Apache PDFBox 3.0",
                "Image/Scan"
        ));

        // — Images (Commons Imaging) —
        converters.add(new ConverterEntry(
                "JPEG → PDF", "jpg", "pdf",
                new CommonsImagingConverter(), "Apache Commons Imaging 1.0-alpha6",
                "Image"
        ));
        converters.add(new ConverterEntry(
                "JPEG → PDF", "jpeg", "pdf",
                new CommonsImagingConverter(), "Apache Commons Imaging 1.0-alpha6",
                "Image"
        ));
        converters.add(new ConverterEntry(
                "PNG → PDF", "png", "pdf",
                new CommonsImagingConverter(), "Apache Commons Imaging 1.0-alpha6",
                "Image"
        ));
        converters.add(new ConverterEntry(
                "GIF → PDF", "gif", "pdf",
                new CommonsImagingConverter(), "Apache Commons Imaging 1.0-alpha6",
                "Image"
        ));
        converters.add(new ConverterEntry(
                "BMP → PDF", "bmp", "pdf",
                new CommonsImagingConverter(), "Apache Commons Imaging 1.0-alpha6",
                "Image"
        ));

        // — Email —
        converters.add(new ConverterEntry(
                "EML → PDF (Tika)", "eml", "pdf",
                new TikaEmailConverter(), "Apache Tika 3.1 + PDFBox",
                "Email"
        ));
        converters.add(new ConverterEntry(
                "MSG → PDF (Tika)", "msg", "pdf",
                new TikaEmailConverter(), "Apache Tika 3.1 + PDFBox",
                "Email"
        ));

        log.info("ConverterService initialized with {} converters", converters.size());
    }

    public List<ConverterEntry> getConverters() {
        return Collections.unmodifiableList(converters);
    }

    public ConvertResult convert(Path inputPath) {
        String ext = getExtension(inputPath.getFileName().toString()).toLowerCase();
        File inputFile = inputPath.toFile();

        for (ConverterEntry entry : converters) {
            if (entry.sourceExt.equals(ext)) {
                log.info("Converting {} using {} ({})",
                        inputPath.getFileName(), entry.name, entry.library);
                ConvertResult result = entry.converter.convert(inputFile, outputDir.toFile());
                log.info("Conversion result: success={}, output={}, duration={}ms",
                        result.success(), result.outputFile(), result.durationMs());
                return result;
            }
        }

        return ConvertResult.failed("demo", inputPath.getFileName().toString(),
                "Unsupported format: " + ext + ". Supported: " + getSupportedExtensions());
    }

    public void cleanup() {
        try {
            Files.walk(outputDir)
                    .filter(p -> !p.equals(outputDir))
                    .forEach(p -> {
                        try { Files.deleteIfExists(p); } catch (IOException ignored) {}
                    });
        } catch (IOException e) {
            log.warn("Cleanup error: {}", e.getMessage());
        }
    }

    public Set<String> getSupportedExtensions() {
        Set<String> exts = new HashSet<>();
        for (ConverterEntry e : converters) {
            exts.add(e.sourceExt);
        }
        return exts;
    }

    public Path getOutputDir() {
        return outputDir;
    }

    private String getExtension(String name) {
        int dot = name.lastIndexOf('.');
        return dot >= 0 ? name.substring(dot + 1) : "";
    }

    public record ConverterEntry(
            String name,
            String sourceExt,
            String targetExt,
            DocumentConverter converter,
            String library,
            String category
    ) {}
}
