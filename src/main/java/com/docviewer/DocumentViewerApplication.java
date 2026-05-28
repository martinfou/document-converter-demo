package com.docviewer;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

/**
 * Document Converter Demo — Showcase of pure Java document converters.
 *
 * Features:
 * - docx4j: DOCX → PDF (layout fidelity)
 * - Apache POI: DOC/DOCX → text, XLS/XLSX → text, PPT/PPTX → text
 * - Apache PDFBox: TIFF → PDF (multi-page)
 * - Apache Tika: EML/MSG → PDF
 * - Apache Commons Imaging: JPEG/PNG/GIF/BMP → PDF
 * - ONLYOFFICE: Interactive viewer for Office documents
 *
 * Couleurs Desjardins : #00843D
 */
@SpringBootApplication
public class DocumentViewerApplication extends SpringBootServletInitializer {

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder builder) {
        return builder.sources(DocumentViewerApplication.class);
    }

    public static void main(String[] args) {
        SpringApplication.run(DocumentViewerApplication.class, args);
    }
}
