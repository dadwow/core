# PlusCraft Docker Images

This repository automatically builds and publishes Docker images to GitHub Container Registry (GHCR) for the PlusCraft AzerothCore server with Playerbots module.

## Quick Start for Production Deployment

Use the provided deployment script for easy management:

```bash
# Pull and start services with pre-built images
./deploy.sh up

# View logs
./deploy.sh logs

# Update to latest images
./deploy.sh update

# Stop services
./deploy.sh down
```

Or use Docker Compose directly:

```bash
docker compose -f docker-compose.yml -f docker-compose.deploy.yml up -d
```

## Available Images

All images are published to `ghcr.io/dadwow/pluscraft-*`:

- **pluscraft-worldserver** - World server with Playerbots support
- **pluscraft-authserver** - Authentication server
- **pluscraft-db-import** - Database initialization and migration tool
- **pluscraft-client-data** - Client data (maps, vmaps, mmaps, dbc)
- **pluscraft-tools** - Extraction tools for client data
- **pluscraft-dev-server** - Development server image

## Image Tags

Images are tagged with:
- `Playerbot` or `master` - Latest build from the main branch
- `<branch-name>` - Specific branch builds
- `<branch>-<sha>` - Specific commit builds
- `latest` - Latest Playerbot branch build
- `<version>` - Versioned releases

## Using Pre-built Images

### Quick Start

PlusCraft provides two Docker Compose configurations:

1. **docker-compose.yml** - Default configuration that builds images locally
2. **docker-compose.deploy.yml** - Deployment configuration using pre-built GHCR images

#### Option 1: Using deployment override file

```bash
# Pull pre-built images from GHCR
docker compose -f docker-compose.yml -f docker-compose.deploy.yml pull

# Start services with pre-built images
docker compose -f docker-compose.yml -f docker-compose.deploy.yml up -d
```

#### Option 2: Set COMPOSE_FILE environment variable

```bash
# Add to your .env file or export in shell
export COMPOSE_FILE=docker-compose.yml:docker-compose.deploy.yml

# Now you can use normal docker compose commands
docker compose pull
docker compose up -d
```

#### Option 3: Create an alias

```bash
# Add to your ~/.zshrc or ~/.bashrc
alias dcprod='docker compose -f docker-compose.yml -f docker-compose.deploy.yml'

# Then use it
dcprod pull
dcprod up -d
```

### Authentication

Public images can be pulled without authentication. For private repositories or to push images:

```bash
# Login to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
```

### Environment Variables

Set in `.env` file or shell:

```bash
# Use specific image tag (default: Playerbot)
export DOCKER_IMAGE_TAG=latest

# Or use a specific commit
export DOCKER_IMAGE_TAG=Playerbot-abc1234
```

## Building Images Locally

The default `docker-compose.yml` builds images locally:

```bash
# Build all images locally
docker compose build

# Build specific service
docker compose build ac-worldserver

# Build and start
docker compose up -d --build
```

To switch between local builds and pre-built images, simply use the appropriate compose file configuration.

## CI/CD Pipeline

The Docker images are automatically built and pushed by GitHub Actions when:

1. **Pushing to main branches** (`Playerbot` or `master`)
   - Builds and pushes all images
   - Tags with branch name, version, and latest

2. **Pull Requests** with `run-build` label
   - Builds images but doesn't push to registry
   - Validates build process

3. **Manual workflow dispatch**
   - Trigger builds on-demand via GitHub Actions UI

### Workflow Files

- `.github/workflows/docker_build.yml` - Main workflow for building images
- `.github/actions/docker-tag-and-build/action.yml` - Reusable action for building/tagging

## Image Contents

### worldserver & authserver
- Built from `apps/docker/Dockerfile`
- Based on Ubuntu 22.04 LTS
- Includes all required dependencies
- Pre-compiled binaries ready to run
- Includes mod-playerbots module

### db-import
- Initializes databases on first run
- Applies SQL updates automatically
- Creates: `acore_auth`, `acore_world`, `acore_characters`, `acore_playerbots`

### client-data
- Contains extracted game data files
- DBC, maps, vmaps, mmaps, Cameras
- Required for worldserver to function

## Troubleshooting

### Pull rate limits
If you hit Docker Hub rate limits, the images are now hosted on GHCR which has more generous limits.

### Image not found
Ensure you're authenticated with GHCR if the repository is private:
```bash
docker login ghcr.io
```

### Build failures in CI
Check the GitHub Actions logs for specific build errors. Common issues:
- Disk space (automatically cleaned in workflow)
- Module compilation errors
- Missing dependencies

## Development

For local development with live code changes, use the dev-server profile:

```bash
docker compose --profile dev up ac-dev-server
```

This mounts your local code directory into the container for rapid iteration.

## More Information

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [GHCR Documentation](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [AzerothCore Docker Guide](http://www.azerothcore.org/wiki/install-with-docker)
