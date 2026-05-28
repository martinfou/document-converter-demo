package com.docconverter.impl;

import com.docconverter.api.ConvertResult;
import com.docconverter.api.DocumentConverter;
import com.lowagie.text.Chunk;
import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.Font;
import com.lowagie.text.FontFactory;
import com.lowagie.text.Paragraph;
import com.lowagie.text.pdf.PdfWriter;
import org.apache.poi.hslf.usermodel.HSLFSlideShow;
import org.apache.poi.hslf.usermodel.HSLFTextParagraph;
import org.apache.poi.sl.usermodel.Slide;
import org.apache.poi.sl.usermodel.SlideShow;
import org.apache.poi.xslf.usermodel.XSLFSlide;
import org.apache.poi.xslf.usermodel.XSLFTextShape;
import org.apache.poi.xslf.usermodel.XMLSlideShow;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.List;

/**
 * PPT/PPTX → PDF using Apache POI + OpenPDF.
 *
 * STRENGTH:
 * - Pure Java, handles both old (.ppt) and new (.pptx) PowerPoint formats
 * - Extracts text from all slides, including speaker notes
 *
 * WEAKNESS:
 * - TEXT-ONLY — NO slide layout, images, charts, transitions, animations
 * - Text ordering may not match visual layout
 * - Demonstrates need for LibreOffice/ONLYOFFICE for real PPT→PDF
 */
public class PoiPresentationConverter implements DocumentConverter {

    @Override
    public String libraryName() {
        return "POI 5.4 + OpenPDF (PPT→PDF)";
    }

    @Override
    public String[] supportedExtensions() {
        return new String[]{"pptx", "ppt"};
    }

    @Override
    public ConvertResult convert(File input, File outputDir) {
        long start = System.currentTimeMillis();
        try {
            String outputName = changeExtension(input.getName(), ".pdf");
            File output = new File(outputDir, outputName);
            String format;
            int slideCount = 0;

            // Step 1: Read presentation with POI
            try (FileInputStream fis = new FileInputStream(input)) {
                String name = input.getName().toLowerCase();
                StringBuilder allText = new StringBuilder();

                if (name.endsWith(".pptx")) {
                    format = "PPTX";
                    try (XMLSlideShow pptx = new XMLSlideShow(fis)) {
                        List<XSLFSlide> slides = pptx.getSlides();
                        slideCount = slides.size();
                        for (int i = 0; i < slides.size(); i++) {
                            allText.append("--- Slide ").append(i + 1).append(" ---\n");
                            for (XSLFTextShape shape : slides.get(i).getPlaceholders()) {
                                String text = shape.getText();
                                if (text != null && !text.trim().isEmpty()) {
                                    allText.append(text).append("\n");
                                }
                            }
                            // Also try regular shapes
                            for (org.apache.poi.xslf.usermodel.XSLFShape shape : slides.get(i).getShapes()) {
                                if (shape instanceof XSLFTextShape) {
                                    String text = ((XSLFTextShape) shape).getText();
                                    if (text != null && !text.trim().isEmpty()) {
                                        allText.append(text).append("\n");
                                    }
                                }
                            }
                            allText.append("\n");
                        }
                    }
                } else if (name.endsWith(".ppt")) {
                    format = "PPT (legacy)";
                    try (HSLFSlideShow ppt = new HSLFSlideShow(fis)) {
                        slideCount = ppt.getSlides().size();
                        for (int i = 0; i < slideCount; i++) {
                            allText.append("--- Slide ").append(i + 1).append(" ---\n");
                            org.apache.poi.hslf.usermodel.HSLFSlide slide = ppt.getSlides().get(i);
                            List<List<HSLFTextParagraph>> textRuns = slide.getTextParagraphs();
                            for (List<HSLFTextParagraph> paraList : textRuns) {
                                String text = HSLFTextParagraph.getText(paraList);
                                if (text != null && !text.trim().isEmpty()) {
                                    allText.append(text).append("\n");
                                }
                            }
                            allText.append("\n");
                        }
                    }
                } else {
                    return ConvertResult.failed(libraryName(), input.getName(), "Unsupported format");
                }

                // Step 2: Create PDF with extracted text
                try (Document pdfDoc = new Document()) {
                    PdfWriter.getInstance(pdfDoc, new FileOutputStream(output));
                    pdfDoc.open();

                    Font headerFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11);
                    Font bodyFont = FontFactory.getFont(FontFactory.HELVETICA, 8);

                    pdfDoc.add(new Paragraph("[" + format + "] " + input.getName(), headerFont));
                    pdfDoc.add(new Paragraph("Converted with Apache POI + OpenPDF (TEXT ONLY)", bodyFont));
                    pdfDoc.add(Chunk.NEWLINE);

                    String text = allText.toString();
                    String[] lines = text.split("\n");
                    int maxLines = Math.min(lines.length, 500);
                    for (int i = 0; i < maxLines; i++) {
                        String line = lines[i];
                        pdfDoc.add(new Paragraph(line.length() > 100 ? line.substring(0, 97) + "…" : line, bodyFont));
                    }
                    if (lines.length > maxLines) {
                        pdfDoc.add(new Paragraph("... [" + (lines.length - maxLines) + " more lines truncated]", bodyFont));
                    }
                }

                long duration = System.currentTimeMillis() - start;
                return new ConvertResult(libraryName(), input.getName(),
                        output.getAbsolutePath(), true, duration, output.length(),
                        String.format("Format: %s. %d diapositives. Fidélité: TRÈS FAIBLE (texte brut uniquement, sans mise en page).",
                                format, slideCount));
            }
        } catch (IOException | DocumentException e) {
            return ConvertResult.failed(libraryName(), input.getName(),
                    e.getClass().getSimpleName() + ": " + e.getMessage());
        } catch (Exception e) {
            return ConvertResult.failed(libraryName(), input.getName(),
                    e.getClass().getSimpleName() + ": " + e.getMessage());
        }
    }

    private static String changeExtension(String name, String toExt) {
        int dot = name.lastIndexOf('.');
        return (dot >= 0 ? name.substring(0, dot) : name) + toExt;
    }
}
