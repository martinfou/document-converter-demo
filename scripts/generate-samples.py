#!/usr/bin/env python3
"""Generate sample documents for the document viewer demo."""

from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from pptx import Presentation
from pptx.util import Inches as PptInches, Pt as PptPt
from pptx.dml.color import RGBColor as PptRGB
from pptx.enum.text import PP_ALIGN
from pathlib import Path
import subprocess, os

SAMPLES = Path(__file__).parent

# ── Couleurs Desjardins ──
DZ_GREEN = '#00843D'
DZ_GREEN_RGB = 'FF00843D'
DZ_DARK = '#004d22'
DZ_GOLD = '#C8A951'

def generate_docx(path, title, paragraphs, is_report=False):
    doc = Document()
    style = doc.styles['Normal']
    style.font.name = 'Calibri'
    style.font.size = Pt(11)
    
    # Header
    h = doc.add_heading(title, level=0)
    for run in h.runs:
        run.font.color.rgb = RGBColor(0x00, 0x84, 0x3D)
    
    for p in paragraphs:
        doc.add_paragraph(p)
    
    if is_report:
        doc.add_heading('Section 1 : Résultats trimestriels', level=1)
        doc.add_paragraph(
            "Le premier trimestre 2026 démontre une croissance soutenue de nos activités. "
            "Les revenus totaux atteignent 12,4 M$, soit une augmentation de 8,3% par rapport "
            "à la même période l'an dernier. Cette performance s'explique principalement par "
            "l'expansion de notre offre de services API et l'acquisition de nouveaux partenaires "
            "institutionnels."
        )
        doc.add_heading('Section 2 : Projections', level=1)
        doc.add_paragraph(
            "Pour le deuxième trimestre, nous prévoyons une croissance supplémentaire de 5 à 7%, "
            "portée par le déploiement de notre nouvelle infrastructure cloud et l'optimisation "
            "de nos pipelines de données. Les investissements en R&D ont augmenté de 12% pour "
            "soutenir l'innovation dans nos produits."
        )
    
    doc.save(str(path))
    print(f"  ✓ {path.name}")

def generate_xlsx(path, title):
    wb = Workbook()
    ws = wb.active
    ws.title = title[:31]
    
    # Header style
    header_font = Font(bold=True, color='FFFFFF', size=12)
    header_fill = PatternFill(start_color=DZ_GREEN_RGB, end_color=DZ_GREEN_RGB, fill_type='solid')
    thin_border = Border(
        left=Side(style='thin'), right=Side(style='thin'),
        top=Side(style='thin'), bottom=Side(style='thin')
    )
    
    headers = ['Département', 'Budget 2026', 'Réel Q1', 'Écart', 'Statut']
    for col, h in enumerate(headers, 1):
        cell = ws.cell(row=1, column=col, value=h)
        cell.font = header_font
        cell.fill = header_fill
        cell.alignment = Alignment(horizontal='center')
        cell.border = thin_border
    
    data = [
        ['API Backend', '1 200 000', '312 000', '-2%', '✓'],
        ['Infrastructure', '850 000', '220 000', '+3%', '✓'],
        ['Sécurité', '600 000', '148 000', '-1%', '✓'],
        ['DevOps', '450 000', '115 000', '+2%', '✓'],
        ['Support', '350 000', '88 000', '0%', '✓'],
    ]
    
    for r, row_data in enumerate(data, 2):
        for c, val in enumerate(row_data, 1):
            cell = ws.cell(row=r, column=c, value=val)
            cell.border = thin_border
            if c == 1:
                cell.font = Font(bold=True)
    
    wb.save(str(path))
    print(f"  ✓ {path.name}")

def generate_pptx(path, title):
    prs = Presentation()
    prs.slide_width = PptInches(13.333)
    prs.slide_height = PptInches(7.5)
    
    # Slide 1 - Title
    slide = prs.slides.add_slide(prs.slide_layouts[6])  # Blank
    txBox = slide.shapes.add_textbox(PptInches(1), PptInches(2), PptInches(11), PptInches(3))
    tf = txBox.text_frame
    p = tf.paragraphs[0]
    p.text = title
    p.font.size = PptPt(44)
    p.font.bold = True
    p.font.color.rgb = PptRGB(0x00, 0x84, 0x3D)
    p.alignment = PP_ALIGN.CENTER
    
    # Slide 2 - Content
    slide2 = prs.slides.add_slide(prs.slide_layouts[6])
    txBox2 = slide2.shapes.add_textbox(PptInches(1), PptInches(1), PptInches(11), PptInches(5))
    tf2 = txBox2.text_frame
    tf2.word_wrap = True
    
    items = [
        ('📈 Croissance des revenus', '+8,3% ce trimestre'),
        ('🔐 Sécurité renforcée', 'Certification ISO 27001 obtenue'),
        ('☁️ Migration cloud', '60% des services migrés'),
        ('🤖 Automatisation', '45 processus automatisés'),
    ]
    
    p = tf2.paragraphs[0]
    p.text = 'Faits saillants'
    p.font.size = PptPt(36)
    p.font.bold = True
    p.font.color.rgb = PptRGB(0x00, 0x84, 0x3D)
    
    for label, value in items:
        p = tf2.add_paragraph()
        p.text = f'{label} — {value}'
        p.font.size = PptPt(24)
        p.space_before = PptPt(20)
    
    prs.save(str(path))
    print(f"  ✓ {path.name}")

def generate_pdf(path, title, text):
    """Generate a simple PDF using reportlab."""
    from reportlab.lib.pagesizes import letter
    from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer
    from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
    from reportlab.lib.colors import HexColor
    
    doc = SimpleDocTemplate(str(path), pagesize=letter)
    styles = getSampleStyleSheet()
    
    title_style = ParagraphStyle(
        'CustomTitle', parent=styles['Heading1'],
        textColor=HexColor(DZ_GREEN), fontSize=24, spaceAfter=20
    )
    body_style = ParagraphStyle(
        'CustomBody', parent=styles['Normal'],
        fontSize=11, leading=14, spaceAfter=12
    )
    
    story = []
    story.append(Paragraph(title, title_style))
    for line in text:
        story.append(Paragraph(line, body_style))
        story.append(Spacer(1, 6))
    
    doc.build(story)
    print(f"  ✓ {path.name}")

def main():
    print("Génération des échantillons de documents...")
    
    # DOCX samples
    generate_docx(
        SAMPLES / 'rapport-q1-2026.docx',
        'Rapport financier Q1 2026',
        ['Document confidentiel — Direction générale', 'Période : 1er janvier au 31 mars 2026'],
        is_report=True
    )
    
    generate_docx(
        SAMPLES / 'guide-integration.docx',
        'Guide d\'intégration — Nouveaux employés',
        [
            'Bienvenue chez Desjardins ! Ce guide vous accompagnera dans vos premières semaines.',
            'Au programme : rencontre avec l\'équipe, configuration de votre poste, et formation aux outils.'
        ]
    )
    
    # XLSX sample
    generate_xlsx(SAMPLES / 'budget-2026.xlsx', 'Budget 2026')
    
    # PPTX sample
    generate_pptx(SAMPLES / 'presentation-ca.pptx', 'Conseil d\'administration — Revue stratégique 2026')
    
    # PDF samples
    generate_pdf(
        SAMPLES / 'politique-confidentialite.pdf',
        'Politique de confidentialité',
        [
            'La protection de vos renseignements personnels est une priorité pour Desjardins.',
            'Cette politique décrit comment nous collectons, utilisons et protégeons vos données.',
            '1. Collecte des renseignements — Nous collectons uniquement les données nécessaires.',
            '2. Utilisation — Vos données sont utilisées pour vous offrir nos services.',
            '3. Conservation — Nous conservons vos données selon les délais légaux.',
        ]
    )
    
    generate_pdf(
        SAMPLES / 'pv-ca-mars-2026.pdf',
        'Procès-verbal — Conseil d\'administration',
        [
            'Réunion du 15 mars 2026 — Présidé par Martin Fournier',
            'Ordre du jour :',
            '• Approbation du procès-verbal précédent',
            '• Rapport financier Q1 2026',
            '• Mise à jour des projets stratégiques',
            '• Planification budgétaire 2027',
            '• Varia et prochaine rencontre',
        ]
    )
    
    print(f"\n✅ {len(list(SAMPLES.glob('*')))} fichiers générés dans samples/")

if __name__ == '__main__':
    main()
