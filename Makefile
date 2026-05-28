# ═══════════════════════════════════════════════════════════════
# Makefile — Document Converter Demo
# ═══════════════════════════════════════════════════════════════
#
# Commandes principales :
#   make run              →   Lance l'app (Spring Boot) + ODS (Docker)
#   make run-app          →   Lance l'app seulement (Maven, sans ODS)
#   make run-ods          →   Lance ODS seulement (Docker)
#   make build            →   Compile le WAR
#
#   make stop             →   Arrête tout (Docker Compose)
#   make logs             →   Logs des deux services
#
#   make deploy           →   Déploie sur Fly.io
#   make push             →   Push sur GitHub
# ═══════════════════════════════════════════════════════════════

.PHONY: run run-app run-app-oo run-ods build stop logs deploy push

# ─── Full stack (app + ODS) via Docker Compose ──────────────
run: build
	docker compose up -d --build app
	@echo ""
	@echo "═══════════════════════════════════════════"
	@echo "  App : http://localhost:8080"
	@echo "  ODS : http://localhost:3080"
	@echo "═══════════════════════════════════════════"
	@echo "  Première connexion ODS lente (téléchargement de l'image)"
	@echo ""

# ─── App + ODS local (Maven sur l'hôte, ODS en Docker) ───────
run-app-oo: run-ods
	@echo "Lancement Spring Boot pour ONLYOFFICE local..."
	@echo "  SERVER_URL=http://host.docker.internal:8080"
	SERVER_URL=http://host.docker.internal:8080 \
	ONLYOFFICE_DS_URL=http://localhost:3080 \
	ONLYOFFICE_DOCSERVICE_URL=http://localhost:3080 \
	mvn spring-boot:run

# ─── App seulement (Maven, pas d'ODS) ──────────────────────
# Utile pour tester les conversions Java sans ONLYOFFICE
run-app:
	@echo "Lancement de l'application (sans ODS)..."
	@echo "Les conversions Java fonctionnent, ONLYOFFICE désactivé"
	@echo "═══════════════════════════════════════════"
	@echo "  App : http://localhost:8080"
	@echo "═══════════════════════════════════════════"
	mvn spring-boot:run

# ─── ODS seulement (Docker) ─────────────────────────────────
run-ods:
	@echo "Lancement d'ONLYOFFICE Document Server..."
	docker compose up -d document-server
	@echo "═══════════════════════════════════════════"
	@echo "  ODS : http://localhost:3080"
	@echo "  (attendre ~30s le temps que ODS démarre)"
	@echo "  Puis lancer : make run-app"
	@echo "═══════════════════════════════════════════"

# ─── Build ──────────────────────────────────────────────────
build:
	mvn clean package -T 4 -q

# ─── Stop ───────────────────────────────────────────────────
stop:
	docker compose down

# ─── Logs ────────────────────────────────────────────────────
logs:
	docker compose logs -f

# ─── Déploiement Fly.io ──────────────────────────────────────
deploy: build
	flyctl deploy --ha=false --strategy immediate

# ─── GitHub ──────────────────────────────────────────────────
push:
	git push
