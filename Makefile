# ==========================================
# MAKEFILE POUR GESTION DOCKER
# ==========================================

# Variables
PROJECT_NAME ?= myapp
DOCKER_COMPOSE = docker-compose
DOCKER_COMPOSE_FILE = docker-compose.yml
ENV_FILE = .env

# Couleurs pour l'affichage
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m
NC = \033[0m # No Color

.PHONY: help build up down restart logs shell test clean prune

# ==========================================
# AIDE
# ==========================================
help: ## Affiche cette aide
	@echo "$(GREEN)Commandes disponibles:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'

# ==========================================
# DÉVELOPPEMENT
# ==========================================
submodule-init: ## Initialise les submodules
	@echo "$(GREEN)📦 Initialisation des submodules...$(NC)"
	git submodule update --init --recursive

submodule-update: ## Met à jour les submodules
	@echo "$(GREEN)🔄 Mise à jour des submodules...$(NC)"
	git submodule update --remote --merge

build: ## Construit les images Docker
	@echo "$(GREEN)🔨 Construction des images...$(NC)"
	$(DOCKER_COMPOSE) build --no-cache

up: ## Lance l'application en mode développement
	@echo "$(GREEN)🚀 Démarrage de l'application...$(NC)"
	$(DOCKER_COMPOSE) up -d
	@echo "$(GREEN)✅ Application démarrée!$(NC)"
	@echo "$(YELLOW)API: http://localhost:3000$(NC)"
	@echo "$(YELLOW)MongoDB Express: http://localhost:8081$(NC)"
	@echo "$(YELLOW)Redis Commander: http://localhost:8082$(NC)"
	@echo "$(YELLOW)MailHog: http://localhost:8025$(NC)"

up-build: ## Lance l'application en reconstruisant les images
	@echo "$(GREEN)🔨 Construction et démarrage...$(NC)"
	$(DOCKER_COMPOSE) up -d --build

down: ## Arrête l'application
	@echo "$(YELLOW)🛑 Arrêt de l'application...$(NC)"
	$(DOCKER_COMPOSE) down

restart: ## Redémarre l'application
	@echo "$(YELLOW)🔄 Redémarrage...$(NC)"
	$(DOCKER_COMPOSE) restart

# ==========================================
# PRODUCTION
# ==========================================
prod-up: ## Lance l'application en mode production
	@echo "$(GREEN)🚀 Démarrage en production...$(NC)"
	$(DOCKER_COMPOSE) --profile production up -d

prod-build: ## Build pour la production
	@echo "$(GREEN)🔨 Build production...$(NC)"
	$(DOCKER_COMPOSE) build --target production nestjs_api

# ==========================================
# MONITORING
# ==========================================
monitoring-up: ## Lance les outils de monitoring
	@echo "$(GREEN)📊 Démarrage du monitoring...$(NC)"
	$(DOCKER_COMPOSE) --profile monitoring up -d
	@echo "$(YELLOW)Prometheus: http://localhost:9090$(NC)"
	@echo "$(YELLOW)Grafana: http://localhost:3001$(NC)"

# ==========================================
# LOGS ET DEBUG
# ==========================================
logs: ## Affiche les logs de tous les services
	$(DOCKER_COMPOSE) logs -f

logs-api: ## Affiche les logs de l'API NestJS
	$(DOCKER_COMPOSE) logs -f nestjs_api

logs-db: ## Affiche les logs de MongoDB
	$(DOCKER_COMPOSE) logs -f mongodb

logs-redis: ## Affiche les logs de Redis
	$(DOCKER_COMPOSE) logs -f redis

# ==========================================
# SHELL ET ACCÈS AUX CONTENEURS
# ==========================================
shell: ## Accède au shell du conteneur API
	$(DOCKER_COMPOSE) exec nestjs_api sh

shell-db: ## Accède au shell MongoDB
	$(DOCKER_COMPOSE) exec mongodb mongosh

shell-redis: ## Accède au shell Redis
	$(DOCKER_COMPOSE) exec redis redis-cli

# ==========================================
# TESTS
# ==========================================
test: ## Lance les tests
	@echo "$(GREEN)🧪 Lancement des tests...$(NC)"
	$(DOCKER_COMPOSE) run --rm nestjs_api npm run test

test-e2e: ## Lance les tests end-to-end
	@echo "$(GREEN)🧪 Tests E2E...$(NC)"
	$(DOCKER_COMPOSE) run --rm nestjs_api npm run test:e2e

test-cov: ## Lance les tests avec couverture
	@echo "$(GREEN)🧪 Tests avec couverture...$(NC)"
	$(DOCKER_COMPOSE) run --rm nestjs_api npm run test:cov

# ==========================================
# BASE DE DONNÉES
# ==========================================
db-seed: ## Peuple la base de données avec des données de test
	@echo "$(GREEN)🌱 Seed de la base de données...$(NC)"
	$(DOCKER_COMPOSE) exec nestjs_api npm run seed

db-migrate: ## Lance les migrations
	@echo "$(GREEN)🔄 Migrations...$(NC)"
	$(DOCKER_COMPOSE) exec nestjs_api npm run migration:run

db-backup: ## Sauvegarde la base de données
	@echo "$(GREEN)💾 Sauvegarde MongoDB...$(NC)"
	docker exec $$(docker-compose ps -q mongodb) mongodump --out /tmp/backup
	docker cp $$(docker-compose ps -q mongodb):/tmp/backup ./backups/$(shell date +%Y%m%d_%H%M%S)

db-restore: ## Restaure la base de données (usage: make db-restore BACKUP=backup_folder)
	@echo "$(GREEN)📥 Restauration MongoDB...$(NC)"
	docker cp ./backups/$(BACKUP) $$(docker-compose ps -q mongodb):/tmp/restore
	docker exec $$(docker-compose ps -q mongodb) mongorestore /tmp/restore

# ==========================================
# MAINTENANCE
# ==========================================
clean: ## Nettoie les conteneurs arrêtés
	@echo "$(YELLOW)🧹 Nettoyage des conteneurs...$(NC)"
	docker container prune -f

clean-images: ## Nettoie les images inutilisées
	@echo "$(YELLOW)🧹 Nettoyage des images...$(NC)"
	docker image prune -f

clean-volumes: ## Nettoie les volumes inutilisés
	@echo "$(RED)⚠️  Nettoyage des volumes (ATTENTION: perte de données!)$(NC)"
	@read -p "Êtes-vous sûr? [y/N]: " confirm && [ "$$confirm" = "y" ]
	docker volume prune -f

prune: ## Nettoie tout Docker (ATTENTION: destructif)
	@echo "$(RED)⚠️  Nettoyage complet Docker (ATTENTION!)$(NC)"
	@read -p "Êtes-vous sûr? [y/N]: " confirm && [ "$$confirm" = "y" ]
	docker system prune -af --volumes

# ==========================================
# OUTILS
# ==========================================
ps: ## Affiche l'état des conteneurs
	$(DOCKER_COMPOSE) ps

stats: ## Affiche les statistiques des conteneurs
	docker stats $$(docker-compose ps -q)

check-env: ## Vérifie la configuration environnement
	@echo "$(GREEN)🔍 Vérification de l'environnement...$(NC)"
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "$(RED)❌ Fichier .env manquant! Copiez .env.example vers .env$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)✅ Fichier .env trouvé$(NC)"

init: check-env submodule-init ## Initialise le projet (première utilisation)
	@echo "$(GREEN)🎯 Initialisation du projet...$(NC)"
	$(DOCKER_COMPOSE) build
	$(DOCKER_COMPOSE) up -d
	@echo "$(GREEN)✅ Projet initialisé avec succès!$(NC)"

# ==========================================
# CI/CD
# ==========================================
ci-test: ## Tests pour CI/CD
	$(DOCKER_COMPOSE) -f docker-compose.yml -f docker-compose.test.yml up --build --abort-on-container-exit

lint: ## Lance le linter
	$(DOCKER_COMPOSE) run --rm nestjs_api npm run lint

format: ## Formate le code
	$(DOCKER_COMPOSE) run --rm nestjs_api npm run format