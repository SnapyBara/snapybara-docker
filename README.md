# 🐳 Configuration Docker - Guide Complet

## 📋 Vue d'ensemble

Cette configuration Docker fournit un environnement de développement et de production complet pour votre application NestJS avec MongoDB, Redis, et tous les services nécessaires.

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Nginx Proxy   │────│   NestJS API    │────│    MongoDB      │
│   (Production)  │    │  (Port 3000)    │    │  (Port 27017)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │                        │
                              │                ┌─────────────────┐
                              │                │     Redis       │
                              └────────────────│  (Port 6379)    │
                                              └─────────────────┘
```

## 🚀 Démarrage rapide

### 1. Configuration initiale

```bash
# Cloner le projet avec les submodules
git clone --recursive https://github.com/username/mon-projet-docker.git

# Ou si déjà cloné
git submodule update --init --recursive

# Copier le fichier d'environnement
cp .env.example .env

# Éditer les variables d'environnement
nano .env

# Initialiser le projet (avec submodules)
make init
```

### 2. Développement

```bash
# Démarrer en mode développement (avec hot reload)
make up

# Ou avec reconstruction des images
make up-build

# Suivre les logs
make logs
```

### 3. URLs d'accès

| Service | URL | Credentials |
|---------|-----|-------------|
| **API NestJS** | http://localhost:3000 | - |
| **MongoDB Express** | http://localhost:8081 | admin/admin123 |
| **Redis Commander** | http://localhost:8082 | admin/admin123 |
| **MailHog** | http://localhost:8025 | - |
| **Swagger UI** | http://localhost:8083 | - |

## 📁 Structure des fichiers

```
project/
├── backend/                         # Submodule NestJS
│   ├── src/
│   ├── package.json
│   └── ...
├── docker/
│   ├── mongodb/
│   │   └── init-scripts/
│   │       └── 01-init.js           # Script d'initialisation MongoDB
│   ├── nginx/
│   │   ├── nginx.conf               # Configuration Nginx
│   │   └── conf.d/                  # Configurations virtuelles
│   └── redis/
│       └── redis.conf               # Configuration Redis
├── docker-compose.yml               # Configuration principale
├── docker-compose.override.yml      # Overrides développement
├── Dockerfile                       # Image NestJS multi-stage
├── .env.example                     # Variables d'environnement exemple
├── .gitmodules                      # Configuration submodules
└── Makefile                        # Commandes simplifiées
```

## 🛠️ Commandes utiles

### Gestion générale
```bash
make help                   # Affiche toutes les commandes
make ps                     # État des conteneurs
make stats                  # Statistiques en temps réel
make restart                # Redémarre tous les services
make down                   # Arrête tous les services
```

### Submodules
```bash
make submodule-init         # Initialise les submodules
make submodule-update       # Met à jour les submodules
```

### Développement
```bash
make shell                  # Shell dans le conteneur API
make shell-db              # Shell MongoDB
make shell-redis           # Shell Redis
make logs-api              # Logs de l'API uniquement
```

### Tests
```bash
make test                   # Tests unitaires
make test-e2e              # Tests end-to-end
make test-cov              # Tests avec couverture
```

### Base de données
```bash
make db-seed               # Peupler avec des données de test
make db-backup             # Sauvegarder MongoDB
make db-restore BACKUP=... # Restaurer une sauvegarde
```

### Production
```bash
make prod-build            # Build pour production
make prod-up               # Démarrer en production
make monitoring-up         # Démarrer monitoring (Prometheus/Grafana)
```

## 🔧 Configuration détaillée

### Variables d'environnement importantes

```bash
# Base
PROJECT_NAME=myapp
NODE_ENV=development
API_PORT=3000

# MongoDB
MONGO_ROOT_USERNAME=admin
MONGO_ROOT_PASSWORD=your_secure_password
MONGO_DATABASE=myapp_db

# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key

# Firebase
FIREBASE_PROJECT_ID=your_project_id

# Google APIs
GOOGLE_MAPS_API_KEY=your_maps_key
```

### Profils Docker Compose

| Profil | Usage | Commande |
|--------|-------|----------|
| **Default** | Développement | `docker-compose up` |
| **production** | Production | `docker-compose --profile production up` |
| **monitoring** | Observabilité | `docker-compose --profile monitoring up` |

## 🏥 Health Checks

Tous les services ont des health checks configurés :

- **MongoDB** : Ping de la base de données
- **Redis** : Test de connexion
- **NestJS** : Endpoint `/health`
- **Nginx** : Test de configuration

```bash
# Vérifier l'état de santé
docker-compose ps
```

## 📊 Monitoring et observabilité

### Prometheus & Grafana

```bash
# Démarrer le monitoring
make monitoring-up

# Accès
# Prometheus: http://localhost:9090
# Grafana: http://localhost:3001 (admin/admin123)
```

### Logs centralisés

```bash
# Tous les logs
make logs

# Logs spécifiques
make logs-api
make logs-db
make logs-redis
```

## 🔒 Sécurité

### Production
- Nginx configuré avec headers de sécurité
- Rate limiting activé
- SSL ready (décommenter la section HTTPS)
- Utilisateur non-root dans les conteneurs

### Développement
- Variables d'environnement isolées
- Volumes protégés
- Réseaux Docker isolés

## 🧹 Maintenance

### Nettoyage régulier

```bash
make clean              # Conteneurs arrêtés
make clean-images       # Images inutilisées
make prune             # Nettoyage complet (ATTENTION!)
```

### Sauvegardes automatiques

```bash
# Script cron pour sauvegardes quotidiennes
0 2 * * * cd /path/to/project && make db-backup
```

## 🐛 Dépannage

### Problèmes courants

1. **Port déjà utilisé**
   ```bash
   # Changer les ports dans .env
   API_PORT=3001
   MONGO_PORT=27018
   ```

2. **Permissions de volumes**
   ```bash
   # Réparer les permissions
   sudo chown -R $USER:$USER ./uploads ./logs
   ```

3. **MongoDB ne démarre pas**
   ```bash
   # Vérifier les logs et réinitialiser
   make logs-db
   docker volume rm $(PROJECT_NAME)_mongodb_data
   ```

4. **Build échoue**
   ```bash
   # Build sans cache
   make build
   # ou
   docker-compose build --no-cache
   ```

### Debug avancé

```bash
# Inspecter un conteneur
docker inspect $(docker-compose ps -q nestjs_api)

# Ressources utilisées
docker stats

# Logs détaillés Docker
docker-compose logs --details
```

## 📚 Ressources additionnelles

- [Documentation Docker Compose](https://docs.docker.com/compose/)
- [Best practices Dockerfile](https://docs.docker.com/develop/dev-best-practices/)
- [Configuration Nginx](https://nginx.org/en/docs/)
- [MongoDB en Docker](https://hub.docker.com/_/mongo)

## 🤝 Contribution

Pour contribuer à cette configuration :

1. Testez vos modifications localement
2. Vérifiez que tous les health checks passent
3. Documentez les nouveaux services
4. Mettez à jour ce README si nécessaire

---

**🎯 Configuration optimisée pour développement rapide et déploiement production-ready !**