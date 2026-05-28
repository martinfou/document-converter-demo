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
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

/**
 * XLS/XLSX → PDF using Apache POI + OpenPDF.
 *
 * STRENGTH:
 * - Pure Java, handles both old (.xls) and new (.xlsx) Excel formats
 * - Extracts cell values row by row, sheet by sheet
 *
 * WEAKNESS:
 * - TEXT-ONLY extraction — NO formatting, formulas, charts, images, merged cells
 * - Formula results extracted, not formulas themselves
 * - Demonstrates the limit of pure Java for spreadsheet→PDF conversion
 */
public class PoiExcelConverter implements DocumentConverter {

    @Override
    public String libraryName() {
        return "POI 5.4 + OpenPDF (XLS→PDF)";
    }

    @Override
    public String[] supportedExtensions() {
        return new String[]{"xlsx", "xls"};
    }

    @Override
    public ConvertResult convert(File input, File outputDir) {
        long start = System.currentTimeMillis();
        try {
            String outputName = changeExtension(input.getName(), ".pdf");
            File output = new File(outputDir, outputName);
            String format;

            // Step 1: Read workbook with POI
            try (FileInputStream fis = new FileInputStream(input)) {
                Workbook wb;
                String name = input.getName().toLowerCase();
                if (name.endsWith(".xlsx")) {
                    wb = new XSSFWorkbook(fis);
                    format = "XLSX";
                } else if (name.endsWith(".xls")) {
                    wb = new HSSFWorkbook(fis);
                    format = "XLS (legacy)";
                } else {
                    return ConvertResult.failed(libraryName(), input.getName(), "Unsupported format");
                }

                // Step 2: Create PDF with extracted text
                try (Document pdfDoc = new Document()) {
                    PdfWriter.getInstance(pdfDoc, new FileOutputStream(output));
                    pdfDoc.open();

                    Font headerFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11);
                    Font sheetFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10);
                    Font cellFont = FontFactory.getFont(FontFactory.HELVETICA, 8);

                    pdfDoc.add(new Paragraph("[" + format + "] " + input.getName(), headerFont));
                    pdfDoc.add(new Paragraph("Converted with Apache POI + OpenPDF (TEXT ONLY)", cellFont));
                    pdfDoc.add(Chunk.NEWLINE);

                    int sheetCount = wb.getNumberOfSheets();
                    int totalRows = 0;

                    for (int s = 0; s < sheetCount; s++) {
                        Sheet sheet = wb.getSheetAt(s);
                        if (sheet == null) continue;

                        pdfDoc.add(new Paragraph("Sheet: " + sheet.getSheetName(), sheetFont));
                        pdfDoc.add(Chunk.NEWLINE);

                        StringBuilder sb = new StringBuilder();
                        int rowsInSheet = 0;

                        for (Row row : sheet) {
                            StringBuilder rowStr = new StringBuilder();
                            for (Cell cell : row) {
                                String val = getCellValue(cell);
                                rowStr.append(val).append(" | ");
                            }
                            if (rowStr.length() > 0) {
                                String line = rowStr.substring(0, rowStr.length() - 3);
                                if (line.length() > 120) line = line.substring(0, 117) + "…";
                                sb.append(line).append("\n");
                                rowsInSheet++;
                            }
                        }

                        pdfDoc.add(new Paragraph(sb.length() > 0 ? sb.toString() : "(empty sheet)", cellFont));
                        pdfDoc.add(Chunk.NEWLINE);
                        totalRows += rowsInSheet;
                    }

                    wb.close();

                    long duration = System.currentTimeMillis() - start;
                    return new ConvertResult(libraryName(), input.getName(),
                            output.getAbsolutePath(), true, duration, output.length(),
                            String.format("Format: %s. %d feuilles, %d lignes. Fidélité: TRÈS FAIBLE (texte brut uniquement).",
                                    format, sheetCount, totalRows));
                }
            }
        } catch (IOException | DocumentException e) {
            return ConvertResult.failed(libraryName(), input.getName(),
                    e.getClass().getSimpleName() + ": " + e.getMessage());
        } catch (Exception e) {
            return ConvertResult.failed(libraryName(), input.getName(),
                    e.getClass().getSimpleName() + ": " + e.getMessage());
        }
    }

    private static String getCellValue(Cell cell) {
        if (cell == null) return "";
        return switch (cell.getCellType()) {
            case STRING -> cell.getStringCellValue();
            case NUMERIC -> {
                double val = cell.getNumericCellValue();
                if (val == Math.floor(val) && !Double.isInfinite(val))
                    yield String.valueOf((long) val);
                yield String.format("%.2f", val);
            }
            case BOOLEAN -> String.valueOf(cell.getBooleanCellValue());
            case FORMULA -> {
                try {
                    yield String.valueOf(cell.getNumericCellValue());
                } catch (Exception e) {
                    try {
                        yield cell.getStringCellValue();
                    } catch (Exception e2) {
                        yield cell.getCellFormula();
                    }
                }
            }
            case BLANK -> "";
            default -> "?";
        };
    }

    private static String changeExtension(String name, String toExt) {
        int dot = name.lastIndexOf('.');
        return (dot >= 0 ? name.substring(0, dot) : name) + toExt;
    }
}
