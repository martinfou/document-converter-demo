package com.docconverter.impl;

import com.docconverter.api.ConvertResult;
import com.docconverter.api.DocumentConverter;
import org.apache.commons.imaging.ImageFormats;
import org.apache.commons.imaging.Imaging;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.graphics.image.LosslessFactory;
import org.apache.pdfbox.pdmodel.graphics.image.PDImageXObject;

import java.awt.image.BufferedImage;
import java.io.File;

/**
 * JPEG, PNG, GIF, BMP → PDF using Apache Commons Imaging + PDFBox.
 *
 * STRENGTH:
 * - Pure Java, handles all common raster formats
 * - Lossless embedding (PDFBox wraps the image data, no recompression)
 * - Handles CMYK JPEGs (Commons Imaging) that ImageIO cannot
 *
 * WEAKNESS:
 * - GIF animation: only first frame is captured
 * - No text layers (OCR required for text extraction)
 * - No JPEG 2000 support (use ImageIO with jai-imageio for that)
 * - Alpha channel in PNG/GIF may not render in some PDF viewers
 */
public class CommonsImagingConverter implements DocumentConverter {

    @Override
    public String libraryName() {
        return "Commons Imaging 1.0-alpha6 (Image→PDF)";
    }

    @Override
    public String[] supportedExtensions() {
        return new String[]{"jpg", "jpeg", "png", "gif", "bmp", "wbmp"};
    }

    @Override
    public ConvertResult convert(File input, File outputDir) {
        long start = System.currentTimeMillis();
        String ext = getExtension(input.getName()).toLowerCase();

        try {
            String outputName = changeExtension(input.getName(), ".pdf");
            File output = new File(outputDir, outputName);

            // Step 1: Read image with Commons Imaging
            BufferedImage image;
            String formatName;

            switch (ext) {
                case "jpg":
                case "jpeg":
                    image = Imaging.getBufferedImage(input);
                    formatName = "JPEG";
                    break;
                case "png":
                    image = Imaging.getBufferedImage(input);
                    formatName = "PNG";
                    break;
                case "gif":
                    // GIF: attempt Commons Imaging first, fall back to ImageIO
                    try {
                        image = Imaging.getBufferedImage(input);
                    } catch (Exception e) {
                        image = javax.imageio.ImageIO.read(input);
                    }
                    formatName = "GIF";
                    break;
                case "bmp":
                    image = Imaging.getBufferedImage(input);
                    formatName = "BMP";
                    break;
                case "wbmp":
                    image = Imaging.getBufferedImage(input);
                    formatName = "WBMP";
                    break;
                default:
                    return ConvertResult.failed(libraryName(), input.getName(),
                            "Unsupported image format: " + ext);
            }

            if (image == null) {
                return ConvertResult.failed(libraryName(), input.getName(),
                        "Cannot decode image (null returned by decoder)");
            }

            int width = image.getWidth();
            int height = image.getHeight();

            // Step 2: Embed in PDF
            try (PDDocument pdf = new PDDocument()) {
                // Create page at image dimensions (fit within A4)
                PDRectangle pageSize = fitToPage(width, height);
                PDPage page = new PDPage(pageSize);
                pdf.addPage(page);

                PDImageXObject pdImage = LosslessFactory.createFromImage(pdf, image);
                try (PDPageContentStream cs = new PDPageContentStream(pdf, page)) {
                    // Center image on page, preserving aspect ratio
                    float scale = Math.min(
                            pageSize.getWidth() / width,
                            pageSize.getHeight() / height
                    );
                    float scaledW = width * scale;
                    float scaledH = height * scale;
                    float offsetX = (pageSize.getWidth() - scaledW) / 2;
                    float offsetY = (pageSize.getHeight() - scaledH) / 2;

                    cs.drawImage(pdImage, offsetX, offsetY, scaledW, scaledH);
                }

                pdf.save(output);
            }

            long duration = System.currentTimeMillis() - start;

            String details = String.format(
                    "Format: %s. Résolution: %dx%d px. Fidélité: parfaite (embedding lossless).",
                    formatName, width, height
            );

            return new ConvertResult(libraryName(), input.getName(),
                    output.getAbsolutePath(), true, duration, output.length(), details);

        } catch (Exception e) {
            long duration = System.currentTimeMillis() - start;
            return new ConvertResult(libraryName(), input.getName(),
                    null, false, duration, 0,
                    "FAILED: " + e.getClass().getSimpleName() + ": " + e.getMessage());
        }
    }

    /**
     * Fit image to page while preserving aspect ratio.
     * Max page size: A4 (595 x 842 points) in portrait orientation.
     * Landscape images are rotated to fit.
     */
    private static PDRectangle fitToPage(int imgW, int imgH) {
        float A4_W = PDRectangle.A4.getWidth();  // 595
        float A4_H = PDRectangle.A4.getHeight(); // 842

        // Determine best page orientation for this image
        float pageW, pageH;
        // If image is landscape and larger than portrait A4 in that dimension
        if (imgW > imgH && (float) imgW / imgH > A4_H / A4_W) {
            pageW = A4_H;
            pageH = A4_W;
        } else {
            pageW = A4_W;
            pageH = A4_H;
        }

        return new PDRectangle(pageW, pageH);
    }

    private static String getExtension(String name) {
        int dot = name.lastIndexOf('.');
        return dot >= 0 ? name.substring(dot + 1) : "";
    }

    private static String changeExtension(String name, String toExt) {
        int dot = name.lastIndexOf('.');
        return (dot >= 0 ? name.substring(0, dot) : name) + toExt;
    }
}
