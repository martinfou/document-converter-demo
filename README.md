# Document Converter Demo

**Showcase de 5 bibliothèques Java pures pour la conversion de documents → PDF, avec intégration ONLYOFFICE.**

> 🌐 **Démo live** : https://document-converter-demo.fly.dev  
> 💻 **Code source** : https://github.com/martinfou/document-converter-demo

---

## Résultat de la recherche : que peut-on faire en Java pur ?

Ce projet répond à une question simple : **quels formats de documents peut-on convertir en PDF sans serveur externe, uniquement avec des bibliothèques Java ?**

La réponse est nuancée — chaque bibliothèque a ses forces et ses limites. Voici la matrice complète.

### Matrice de conversion — Formats supportés

| Format | Visualisation native | Conversion Java → PDF | Bibliothèque | Fidélité |
|---|---|---|---|---|
| **PDF** | ✅ Navigateur (`<iframe>`) | — | — | ✅ Parfaite |
| **JPEG / PNG / GIF / BMP** | ✅ Navigateur (`<img>`) | ✅ Oui | Commons Imaging + PDFBox | ✅ Parfaite (embedding lossless) |
| **DOCX** | ❌ | ✅ Oui | **docx4j** 11.5 (FOP) | ✅ **Bonne** — mise en page, styles, tableaux |
| **DOCX** | ❌ | ✅ Oui (fallback) | **POI** 5.4 + OpenPDF | ❌ **Texte brut** — pas de mise en page |
| **DOC** (98-2003) | ❌ | ✅ Oui | POI HWPF + OpenPDF | ❌ Texte brut |
| **XLSX / XLS** | ❌ | ✅ Oui | **POI** 5.4 + OpenPDF | ❌ **Texte brut** — pas de formules, graphiques, cellules fusionnées |
| **PPTX / PPT** | ❌ | ✅ Oui | **POI** 5.4 (HSLF/XSLF) + OpenPDF | ❌ **Texte brut** — pas de diapositives visuelles, images, transitions |
| **TIFF** (multi-page) | ❌ | ✅ Oui | **PDFBox** 3.0 | ✅ **Bonne** — chaque page → page PDF |
| **EML** | ❌ | ✅ Oui | **Tika** 3.1 + PDFBox | ✅ Bonne — en-têtes + corps |
| **MSG** (Outlook) | ❌ | ✅ Oui | **Tika** 3.1 + PDFBox | ✅ Bonne |
| **MBOX** | ❌ | ✅ Oui | **Tika** 3.1 + PDFBox | ✅ Bonne |

### Verdict de la recherche

| Catégorie | Faisabilité Java pur | Recommandation |
|---|---|---|
| **Images → PDF** | ✅ Excellent | Commons Imaging gère tous les formats courants, y compris CMYK JPEG |
| **DOCX → PDF** | ✅ Satisfaisant | docx4j donne une bonne fidélité pour des documents simples à modérés |
| **Email → PDF** | ✅ Bon | Tika extrait en-têtes et contenu proprement |
| **TIFF → PDF** | ✅ Bon | PDFBox gère les documents multi-pages |
| **XLSX → PDF** | ⚠️ Limité | POI extrait les valeurs texte uniquement — pas de formatage, graphiques, formules |
| **PPTX → PDF** | ⚠️ Limité | POI extrait le texte des diapos — pas de rendu visuel |
| **DOC legacy → PDF** | ⚠️ Limité | HWPF fonctionne mais pour du texte seulement |

> **Conclusion** : Pour Word (DOCX), Email et Images, les bibliothèques Java pures sont suffisantes. Pour les classeurs (XLSX) et présentations (PPTX), ONLYOFFICE ou LibreOffice en backend sont **fortement recommandés** si vous avez besoin de la mise en page réelle.

---

## Architecture

```
┌─────────────────────────────────────────────────┐
│               Spring Boot 3.4 (WAR)              │
│                                                   │
│  ┌─────────────────────────────────────────────┐ │
│  │           Contrôleur (DocumentController)   │ │
│  │  / → liste, /convert → Java, /viewer → OO  │ │
│  └──────────────┬──────────────────────────────┘ │
│                  │                                │
│  ┌───────────────┴──────────────────────────────┐ │
│  │           ConverterService                    │ │
│  │   Délègue au bon convertisseur selon l'ext.  │ │
│  └───────┬──────────┬──────────┬──────────┬────┘  │
│          │          │          │          │       │
│  ┌───────┴─┐ ┌──────┴──┐ ┌────┴───┐ ┌───┴────┐  │
│  │ docx4j  │ │ Apache  │ │Commons │ │ Tika   │  │
│  │ (DOCX)  │ │  POI    │ │Imaging │ │(EML,   │  │
│  │         │ │DOC/XLS/ │ │JPG/PNG │ │ MSG,   │  │
│  │         │ │  PPT    │ │ /GIF   │ │ MBOX)  │  │
│  └─────────┘ └─────────┘ └────────┘ └────────┘  │
│                        │                         │
│                  ┌─────┴─────┐                   │
│                  │  PDFBox   │                   │
│                  │ (TIFF)    │                   │
│                  └───────────┘                   │
│                                                   │
│  ┌─────────────────────────────────────────────┐ │
│  │   ONLYOFFICE Document Server (DS)           │ │
│  │   Intégré via API JavaScript                │ │
│  │   DOCX, XLSX, PPTX en mode view-only        │ │
│  └─────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

### Technologies

- **Java 17** — langage
- **Spring Boot 3.4.3** — framework
- **JSP + Tag Files** — vues (dans `WEB-INF/tags/`)
- **WAR packaging** — déploiement sur conteneur Java standard
- **Maven** — build
- **Desjardins** — thème visuel (`#00843D`)
- **ONLYOFFICE Document Server 8.2** — visionneuse interactive (optionnelle)

---

## Bibliothèques de conversion — analyse détaillée

### 📄 docx4j 11.5 — DOCX → PDF
- **Dépendances** : docx4j-JAXB-ReferenceImpl + docx4j-export-fo + Apache FOP
- **Force** : Meilleure fidélité de mise en page en Java pur pour DOCX
- **Limite** : Documents complexes (images floating, en-têtes/pieds de page avancés) peuvent perdre en fidélité
- **Usage** : Conversion DOCX prioritaire (premier convertisseur essayé pour .docx)

### 📊 Apache POI 5.4 — DOC/XLS/PPT → texte
- **Dépendances** : poi, poi-ooxml, poi-scratchpad + OpenPDF
- **Force** : Couvre 3 familles de formats (Word, Excel, PowerPoint) avec une seule bibliothèque
- **Limite** : **Extraction texte uniquement** — pas de formatage, graphiques, tableaux, cellules fusionnées, transitions
- **Usage** : Fallback texte pour DOCX, convertisseur principal pour XLS/XLSX/PPT/PPTX

### 🖼️ Apache Commons Imaging 1.0-alpha6 — Images → PDF
- **Dépendances** : commons-imaging + PDFBox (pour l'écriture PDF)
- **Formats** : JPEG, PNG, GIF, BMP, WBMP
- **Force** : Gère les CMYK JPEG (que ImageIO ne supporte pas), embedding lossless
- **Limite** : GIF animé → seulement la première image, pas de JPEG 2000
- **Usage** : Toutes les conversions image → PDF

### 📑 Apache PDFBox 3.0 — TIFF → PDF
- **Dépendances** : pdfbox
- **Force** : Multi-page TIFF → PDF (chaque page TIFF devient une page PDF)
- **Usage** : Conversion TIFF/TIF uniquement

### ✉️ Apache Tika 3.1 — Email → PDF
- **Dépendances** : tika-core + tika-parsers-standard-package + PDFBox
- **Formats** : EML, MSG (Outlook), MBOX
- **Force** : Détection automatique du format, extraction propre des en-têtes et du corps
- **Usage** : Toutes les conversions email → PDF

### 🪟 ONLYOFFICE Document Server — Visualisation interactive
- **Dépendances** : Conteneur Docker séparé (image 1.5 GB)
- **Formats** : DOCX, XLSX, PPTX
- **Force** : **Rendu identique à Microsoft Office** — mise en page, graphiques, tableaux, images, formules, transitions
- **Limite** : Nécessite un serveur dédié (~4 GB RAM), pas une bibliothèque Java
- **Usage** : Visionneuse interactive onglet séparé

---

## Démarrage local

### Prérequis

- JDK 17+
- Docker (optionnel, pour ONLYOFFICE)

### Option 1 : Application seule (sans ONLYOFFICE)

```bash
# Build + run
make run-app
# ou
mvn spring-boot:run

# Accès : http://localhost:8080
```

### Option 2 : Full stack (app + ONLYOFFICE)

```bash
# Build l'app, démarre ODS + l'app
make run

# Accès :
#   App : http://localhost:8080
#   ODS : http://localhost:3080
```

### Option 3 : ODS seul + app séparée

```bash
# Terminal 1 : ONLYOFFICE
make run-ods

# Terminal 2 (après ~30s) : App
make run-app
```

### Autres commandes

```bash
make build    # Compile le WAR
make stop     # Arrête les conteneurs Docker
make logs     # Logs Docker Compose
make deploy   # Déploie sur Fly.io
make push     # Push GitHub
```

---

## Déploiement

### Fly.io

L'application est déployée en continu sur **document-converter-demo.fly.dev** (région YYZ).

Configuration clé dans `fly.toml` :
- **Toujours actif** : `auto_stop_machines = false`, `min_machines_running = 1`
- **512 MB RAM** — suffisant pour Spring Boot + 7 convertisseurs
- ONLYOFFICE DS déployé séparément (ods-document-server.fly.dev), configuré via variables d'environnement

### Docker Compose (local)

`docker-compose.yml` orchestre les deux services :
- `document-server` — ONLYOFFICE Document Server (port 3080)
- `app` — Spring Boot (port 8080)

JWT désactivé pour le développement local.

### Kubernetes (OpenShift / Tanzu)

Un manifest `k8s/onlyoffice-ds.yaml` est disponible pour déploiement sur :
- OpenShift (SCC, Route)
- Tanzu (ServiceAccount, Ingress)
- PVC 40 Gi, probes de santé, toujours actif

---

## Structure du projet

```
document-converter-demo/
├── pom.xml                        # Maven — Spring Boot 3.4, WAR, Java 17
├── Dockerfile                     # Image Docker pour Fly.io
├── docker-compose.yml             # App + ODS
├── docker-compose.onlyoffice.yml  # ODS seulement
├── fly.toml                       # Config Fly.io (yyz, always-on)
├── Makefile                       # Commandes pratiques
├── k8s/                           # Manifest Kubernetes (optionnel)
│   └── onlyoffice-ds.yaml
└── src/
    ├── main/
    │   ├── java/com/
    │   │   ├── docviewer/         # Application Spring Boot
    │   │   │   ├── DocumentViewerApplication.java
    │   │   │   ├── config/WebConfig.java
    │   │   │   ├── controller/DocumentController.java
    │   │   │   └── service/
    │   │   │       ├── ConverterService.java
    │   │   │       └── SampleGenerator.java
    │   │   └── docconverter/      # API & implémentations
    │   │       ├── api/
    │   │       │   ├── DocumentConverter.java    # Interface
    │   │       │   └── ConvertResult.java
    │   │       └── impl/
    │   │           ├── Docx4jWordConverter.java       # DOCX → PDF
    │   │           ├── PoiWordConverter.java          # DOC/DOCX → texte
    │   │           ├── PoiExcelConverter.java          # XLS/XLSX → texte
    │   │           ├── PoiPresentationConverter.java  # PPT/PPTX → texte
    │   │           ├── CommonsImagingConverter.java   # JPG/PNG/GIF → PDF
    │   │           ├── PdfBoxTiffConverter.java       # TIFF → PDF
    │   │           └── TikaEmailConverter.java        # EML/MSG → PDF
    │   ├── resources/
    │   │   ├── application.yml
    │   │   ├── documents.json       # Catalogue des 15 documents
    │   │   ├── samples/             # 14 fichiers échantillons
    │   │   ├── static/css/desjardins.css
    │   │   └── static/img/
    │   └── webapp/WEB-INF/
    │       ├── index.jsp            # Accueil — grille des documents
    │       ├── convertView.jsp      # Conversion + progrès bar
    │       ├── onlyoffice.jsp       # Liste ODS
    │       ├── viewer.jsp           # Visionneuse ONLYOFFICE
    │       └── tags/                # JSP Tag files (auto-discover)
    │           ├── header.tag
    │           ├── footer.tag
    │           ├── docCard.tag
    │           └── onlyofficeViewer.tag
    └── test/
```

---

## Échantillons disponibles

| ID | Document | Format | Bibliothèque |
|---|---|---|---|
| docx4j-docx | DOCX → docx4j | docx | docx4j 11.5 |
| poi-docx | DOCX → POI (texte) | docx | Apache POI 5.4 |
| poi-xlsx | Budget 2026 | xlsx | Apache POI 5.4 |
| poi-pptx | Présentation CA | pptx | Apache POI 5.4 |
| pdfbox-tiff | TIFF multi-page | tiff | Apache PDFBox 3.0 |
| imaging-jpeg | Sample JPEG | jpg | Commons Imaging |
| imaging-png | Sample PNG | png | Commons Imaging |
| imaging-gif | Sample GIF | gif | Commons Imaging |
| imaging-bmp | Sample BMP | bmp | Commons Imaging |
| tika-eml | Email EML | eml | Apache Tika 3.1 |
| tika-mbox | Boîte MBOX | mbox | Apache Tika 3.1 |
| sample-pdf | Politique de confidentialité | pdf | Viewer natif navigateur |

**7 convertisseurs Java → PDF + 1 visionneuse interactive ONLYOFFICE + 3 formats visibles nativement.**

---

## Licence

MIT — Projet de démonstration, librement réutilisable.
