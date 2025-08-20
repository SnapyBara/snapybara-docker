# SnapyBara - Docker Infrastructure

<div align="center">

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![NestJS](https://img.shields.io/badge/NestJS-E0234E?style=for-the-badge&logo=nestjs&logoColor=white)
![Kotlin](https://img.shields.io/badge/Kotlin-7F52FF?style=for-the-badge&logo=kotlin&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-DC382D?style=for-the-badge&logo=redis&logoColor=white)
![GraphQL](https://img.shields.io/badge/GraphQL-E10098?style=for-the-badge&logo=graphql&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)

</div>

## Table of Contents

- [Technical Architecture](#technical-architecture)
- [Prerequisites](#prerequisites)
- [Quick Installation](#quick-installation)
- [Configuration](#configuration)
- [Make Commands](#make-commands)
- [Project Structure](#project-structure)
- [Available Services](#available-services)
- [Development](#development)
- [Production](#production)
- [Troubleshooting](#troubleshooting)

## Technical Architecture

### Technology Stack

#### Backend (NestJS)
- **Framework**: NestJS (Node.js)
- **Database**: MongoDB
- **Cache**: Redis
- **API**: REST + GraphQL
- **Authentication**: Supabase Auth
- **Notifications**: Firebase Cloud Messaging

#### Mobile Frontend (Android)
- **Language**: Kotlin
- **UI**: Jetpack Compose
- **Maps**: Google Maps SDK

#### External Services
- **Maps**: Google Maps API
- **Places**: Google Places API
- **Photos**: Cloudinary / Unsplash / Wikimedia
- **Data**: Data.gouv.fr API

## Prerequisites

- **Docker** >= 20.10
- **Docker Compose** >= 2.0
- **Git** >= 2.25
- **Make** (optional but recommended)
- **8GB RAM minimum** (recommended for development)

## Quick Installation

### 1. Clone the project with submodules

```bash
# Clone the main repository
git clone --recursive https://github.com/your-username/snapybara-docker.git
cd snapybara-docker

# If you already cloned without --recursive
git submodule update --init --recursive
```

### 2. Environment setup

```bash
# Copy the example environment file
cp .env.example .env

# Edit the .env file with your API keys
nano .env
```

### 3. Initialize with Make

```bash
# Complete project initialization (first use)
make init

# OR if you don't have Make, use Docker Compose directly
docker-compose build
docker-compose up -d
```

## Configuration

### Essential Environment Variables

Edit the `.env` file with your own values:

#### Supabase Authentication
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_KEY=your_service_key
```

#### Google APIs
```env
GOOGLE_MAPS_API_KEY=your_google_maps_key
GOOGLE_PLACES_API_KEY=your_google_places_key
GOOGLE_CLIENT_ID=your_client_id
GOOGLE_CLIENT_SECRET=your_client_secret
```

#### Firebase (Notifications)
```env
FIREBASE_PROJECT_ID=your_firebase_project
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n..."
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@project.iam.gserviceaccount.com
```

#### Photo Services
```env
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
UNSPLASH_ACCESS_KEY=your_unsplash_key
```

## Make Commands

### Essential Commands

| Command | Description |
|---------|-------------|
| `make help` | Display all available commands |
| `make init` | Initialize the project (first use) |
| `make up` | Start all services |
| `make down` | Stop all services |
| `make restart` | Restart all services |
| `make logs` | Display real-time logs |
| `make build` | Rebuild Docker images |

### Development

| Command | Description |
|---------|-------------|
| `make shell` | Access API container shell |
| `make shell-db` | Access MongoDB shell |
| `make shell-redis` | Access Redis CLI |
| `make logs-api` | NestJS API logs only |
| `make test` | Run unit tests |
| `make test-e2e` | Run E2E tests |

### Database

| Command | Description |
|---------|-------------|
| `make db-up` | Start MongoDB only |
| `make db-seed` | Populate DB with test data |
| `make db-backup` | Backup the database |
| `make db-restore BACKUP=backup_name` | Restore a backup |

### Maintenance

| Command | Description |
|---------|-------------|
| `make clean` | Clean stopped containers |
| `make clean-images` | Clean unused images |
| `make prune` | Clean all Docker (destructive) |
| `make ps` | Display container status |
| `make stats` | Display container stats |

## Project Structure

```
snapybara-docker/
├── docker/                    # Docker configuration
│   ├── mongodb/              # MongoDB init scripts
│   ├── redis/                # Redis configuration
│   └── nginx/                # Nginx configuration (prod)
├── snapybara-back/           # Backend NestJS submodule
│   ├── src/                  # Source code
│   ├── test/                 # Tests
│   └── Dockerfile            # API Docker image
├── snapybara-admin/          # Admin React submodule
│   ├── src/                  # Source code
│   └── Dockerfile            # Admin Docker image
├── SnapyBara/                # Android app (Kotlin)
│   ├── app/                  # Android source code
│   └── gradle/               # Gradle configuration
├── uploads/                  # Uploads folder
├── logs/                     # Application logs
├── docker-compose.yml        # Service orchestration
├── docker-compose.override.yml # Local overrides
├── Makefile                  # Make commands
├── .env                      # Environment variables
└── README.md                 # This file
```

## Available Services

Once the application is started, the following services are available:

| Service | URL | Description |
|---------|-----|-------------|
| **REST API** | http://localhost:3000 | NestJS Backend |
| **GraphQL Playground** | http://localhost:3000/graphql | GraphQL Interface |
| **Admin Panel** | http://localhost:3005 | Administration Interface |
| **MongoDB Express** | http://localhost:8081 | MongoDB Interface |
| **Redis Commander** | http://localhost:8082 | Redis Interface |
| **API Documentation** | http://localhost:3000/api | Swagger/OpenAPI |

### Monitoring Services (optional profile)

| Service | URL | Description |
|---------|-----|-------------|
| **Prometheus** | http://localhost:9090 | Metrics |
| **Grafana** | http://localhost:3001 | Dashboards |

To enable monitoring:
```bash
make monitoring-up
```

## Development

### Development Workflow

1. **Start services**
   ```bash
   make up
   ```

2. **Check logs**
   ```bash
   make logs-api  # For API
   make logs      # For all services
   ```

3. **Hot reload**
   - NestJS backend supports hot reload automatically
   - Changes are detected and reloaded

4. **Testing**
   ```bash
   make test       # Unit tests
   make test-e2e   # End-to-end tests
   make test-cov   # Code coverage
   ```

### Adding New Features

1. **Backend (NestJS)**
   ```bash
   make shell
   npm run generate:module module-name
   ```

2. **Database**
   ```bash
   make shell-db
   # Use mongosh for queries
   ```

### Debugging

To debug the NestJS API:
1. Attach your IDE to port `9229` (debug port)
2. Set your breakpoints
3. The API restarts automatically with changes

## Production

### Production Build

```bash
# Optimized build
make prod-build

# Start in production mode
make prod-up
```

### Nginx Configuration (Reverse Proxy)

The Nginx service is configured for:
- Serving the application on port 80/443
- Load balancing
- SSL certificate management
- Gzip compression
- Security headers

### Deployment

1. **Build images**
   ```bash
   docker-compose build --target production
   ```

2. **Push to registry**
   ```bash
   docker tag snapybara_api:latest registry.com/snapybara_api:latest
   docker push registry.com/snapybara_api:latest
   ```

3. **Deploy on server**
   ```bash
   docker-compose -f docker-compose.prod.yml up -d
   ```

## Troubleshooting

### Common Issues

#### Port Already in Use
```bash
# Check used ports
netstat -tulpn | grep LISTEN

# Modify ports in .env
API_PORT=3001
```

#### MongoDB Won't Start
```bash
# Check logs
make logs-db

# Reset volume
docker volume rm snapybara-docker_mongodb_data
make db-up
```

#### Permission Error
```bash
# Grant permissions to uploads folder
chmod -R 777 uploads/

# For logs
chmod -R 777 logs/
```

#### Redis Connection Issue
```bash
# Check Redis
make shell-redis
PING
# Should return PONG
```

### Complete Reset

**WARNING**: This will delete all data!

```bash
# Stop all services
make down

# Clean Docker completely
make prune

# Reinitialize
make init
```

## Additional Documentation

- [Complete API Documentation](./docs/back/API_DOCUMENTATION.md)
- [Testing Guide](./docs/back/TEST_GUIDE.md)
- [Security Guide](./docs/back/SECURITY.md)
- [Google APIs Configuration](./docs/google-oauth-setup.md)
- [Supabase Configuration](./docs/supabase-oauth-setup.md)

## Support

In case of issues:

1. Check logs: `make logs`
2. Review documentation in `/docs`
3. Open a GitHub issue
4. Contact the development team

## License

This project is under proprietary license. All rights reserved.

---

<div align="center">
Made with love by SnapyBara Team
</div>
