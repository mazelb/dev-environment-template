# Base Archetype

A minimal starting point for any project with essential development tools and structure.

## What's Included

- Basic directory structure (src/, tests/, docs/)
- Development container setup
- Common services (PostgreSQL, Redis)
- Essential configuration files

## Compatibility

This base archetype is compatible with all feature archetypes.

## Usage

```bash
./create-project.sh --name my-project --archetype base
```

## Structure

```
project-root/
├── src/               # Source code
├── tests/             # Test files
├── docs/              # Documentation
├── .vscode/           # VS Code configuration
├── .devcontainer/     # Dev container setup
├── scripts/           # Utility scripts
├── docker-compose.yml # Docker services
├── Dockerfile         # Container image definition
├── Makefile           # Build commands
├── .env               # Environment variables
└── README.md          # Project documentation
```

## Services

### PostgreSQL

- **Port:** 5432
- **User:** devuser
- **Password:** devpass
- **Database:** dev_db

### Redis

- **Port:** 6379
- **Persistence:** AOF enabled

## Next Steps

After creating a project with this archetype:

1. Review and customize the `.env` file
2. Update `README.md` with your project details
3. Add feature archetypes as needed:

   ```bash
   # Example: Add RAG capabilities
   ./create-project.sh --name my-project --archetype base --add-features rag-project
   ```

## Customization

To customize this archetype:

1. Edit `__archetype__.json` to modify services and configuration
2. Add template files to the archetype directory
3. Update dependencies as needed
