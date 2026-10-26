package com.pathseek.backend.report;

import com.lowagie.text.Document;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.FontFactory;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/**
 * Reporte PDF de sostenibilidad (US-009 / RF-006).
 * Las métricas provienen de los totales estimados registrados en {@code rutas};
 * no se inventan líneas base de ahorro ni créditos de carbono sin datos.
 */
@Service
public class SustainabilityReportService {

    private static final DateTimeFormatter PERIOD = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final Font TITLE = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 16);
    private static final Font HEADING = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11);
    private static final Font BODY = FontFactory.getFont(FontFactory.HELVETICA, 9);
    private static final Font SMALL = FontFactory.getFont(FontFactory.HELVETICA, 8);

    private final JdbcTemplate jdbc;

    public SustainabilityReportService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @Transactional(readOnly = true)
    public byte[] generate(LocalDate desde, LocalDate hasta) {
        List<Row> rows = queryRows(desde, hasta);
        return render(desde, hasta, rows);
    }

    private List<Row> queryRows(LocalDate desde, LocalDate hasta) {
        StringBuilder sql = new StringBuilder("""
                SELECT r.fecha, r.estado, r.distancia_km, r.co2_kg, r.combustible_l,
                       v.placa, c.nombre AS conductor,
                       (SELECT COUNT(*) FROM ruta_pedidos p WHERE p.ruta_id = r.ruta_id) AS entregas,
                       (SELECT COUNT(*) FROM ruta_pedidos p WHERE p.ruta_id = r.ruta_id AND p.cumplio_ventana = TRUE) AS a_tiempo
                FROM rutas r
                JOIN vehiculos v ON v.vehiculo_id = r.vehiculo_id
                JOIN conductores c ON c.conductor_id = r.conductor_id
                """);
        List<Object> params = new ArrayList<>();
        if (desde != null) {
            sql.append(" WHERE r.fecha >= ?");
            params.add(desde);
        }
        if (hasta != null) {
            sql.append(desde == null ? " WHERE r.fecha <= ?" : " AND r.fecha <= ?");
            params.add(hasta);
        }
        sql.append(" ORDER BY r.fecha, r.ruta_id");
        return jdbc.query(sql.toString(), (rs, i) -> new Row(
                rs.getObject("fecha", LocalDate.class),
                rs.getString("estado"),
                rs.getBigDecimal("distancia_km"),
                rs.getBigDecimal("co2_kg"),
                rs.getBigDecimal("combustible_l"),
                rs.getString("placa"),
                rs.getString("conductor"),
                rs.getLong("entregas"),
                rs.getLong("a_tiempo")), params.toArray());
    }

    private byte[] render(LocalDate desde, LocalDate hasta, List<Row> rows) {
        try (ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            Document document = new Document(PageSize.A4.rotate(), 36, 36, 36, 36);
            PdfWriter.getInstance(document, out);
            document.open();

            Paragraph title = new Paragraph("PathSeek — Reporte de Sostenibilidad", TITLE);
            title.setAlignment(Element.ALIGN_CENTER);
            document.add(title);

            String period = (desde != null || hasta != null)
                    ? "Período: " + formatDate(desde) + " a " + formatDate(hasta)
                    : "Período: todos los datos registrados";
            Paragraph subtitle = new Paragraph(period + "\nGenerado: "
                    + LocalDate.now().format(PERIOD), SMALL);
            subtitle.setAlignment(Element.ALIGN_CENTER);
            document.add(subtitle);
            document.add(new Paragraph(" "));

            BigDecimal totalKm = BigDecimal.ZERO;
            BigDecimal totalCo2 = BigDecimal.ZERO;
            BigDecimal totalFuel = BigDecimal.ZERO;
            long totalDeliveries = 0;
            long totalOnTime = 0;
            for (Row row : rows) {
                totalKm = totalKm.add(row.distanciaKm());
                totalCo2 = totalCo2.add(row.co2Kg());
                totalFuel = totalFuel.add(row.combustibleL());
                totalDeliveries += row.entregas();
                totalOnTime += row.aTiempo();
            }
            String compliance = totalDeliveries == 0 ? "—"
                    : BigDecimal.valueOf(totalOnTime * 100.0 / totalDeliveries)
                    .setScale(1, RoundingMode.HALF_UP) + " %";

            document.add(new Paragraph("Resumen del período", HEADING));
            PdfPTable summary = new PdfPTable(2);
            summary.setWidthPercentage(100);
            addSummaryCell(summary, "Rutas registradas", String.valueOf(rows.size()));
            addSummaryCell(summary, "Distancia total estimada (km)", totalKm.setScale(2, RoundingMode.HALF_UP).toPlainString());
            addSummaryCell(summary, "Emisiones totales estimadas (kg CO₂)", totalCo2.setScale(2, RoundingMode.HALF_UP).toPlainString());
            addSummaryCell(summary, "Combustible total estimado (L)", totalFuel.setScale(2, RoundingMode.HALF_UP).toPlainString());
            addSummaryCell(summary, "Entregas incluidas", String.valueOf(totalDeliveries));
            addSummaryCell(summary, "Cumplimiento de ventanas", compliance);
            document.add(summary);
            document.add(new Paragraph(" "));

            document.add(new Paragraph("Detalle por ruta", HEADING));
            if (rows.isEmpty()) {
                document.add(new Paragraph("Sin datos en el rango seleccionado.", BODY));
            } else {
                PdfPTable table = new PdfPTable(9);
                table.setWidthPercentage(100);
                addHeader(table, "Fecha", "Placa", "Conductor", "Estado", "Distancia (km)",
                        "CO₂ (kg)", "Combustible (L)", "Entregas", "A tiempo");
                for (Row row : rows) {
                    table.addCell(cell(row.fecha().format(PERIOD)));
                    table.addCell(cell(row.placa()));
                    table.addCell(cell(row.conductor()));
                    table.addCell(cell(row.estado()));
                    table.addCell(cell(row.distanciaKm().setScale(2, RoundingMode.HALF_UP).toPlainString()));
                    table.addCell(cell(row.co2Kg().setScale(2, RoundingMode.HALF_UP).toPlainString()));
                    table.addCell(cell(row.combustibleL().setScale(2, RoundingMode.HALF_UP).toPlainString()));
                    table.addCell(cell(String.valueOf(row.entregas())));
                    table.addCell(cell(String.valueOf(row.aTiempo())));
                }
                document.add(table);
            }

            document.add(new Paragraph(" "));
            document.add(new Paragraph(
                    "Nota: distancia, combustible y emisiones son valores estimados del optimizador; "
                            + "no corresponden a recorrido vial real ni a tráfico observado. "
                            + "El cumplimiento de ventanas se registra contra la hora estimada de llegada.",
                    SMALL));
            document.close();
            return out.toByteArray();
        } catch (Exception e) {
            throw new IllegalStateException("No se pudo generar el reporte PDF", e);
        }
    }

    private void addSummaryCell(PdfPTable table, String label, String value) {
        table.addCell(cell(label, HEADING));
        table.addCell(cell(value));
    }

    private void addHeader(PdfPTable table, String... headers) {
        for (String header : headers) {
            table.addCell(cell(header, HEADING));
        }
    }

    private com.lowagie.text.pdf.PdfPCell cell(String text) {
        return cell(text, BODY);
    }

    private com.lowagie.text.pdf.PdfPCell cell(String text, Font font) {
        com.lowagie.text.pdf.PdfPCell pdfPCell = new com.lowagie.text.pdf.PdfPCell(new Phrase(text == null ? "" : text, font));
        pdfPCell.setPadding(3);
        return pdfPCell;
    }

    private String formatDate(LocalDate date) {
        return date == null ? "—" : date.format(PERIOD);
    }

    private record Row(LocalDate fecha, String estado, BigDecimal distanciaKm, BigDecimal co2Kg,
                       BigDecimal combustibleL, String placa, String conductor, long entregas, long aTiempo) {
    }
}
