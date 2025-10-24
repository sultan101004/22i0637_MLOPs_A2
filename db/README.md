# Database Service

PostgreSQL database with initialization scripts for the authentication system.

## Schema

### Users Table

| Column | Type | Description |
|--------|------|-------------|
| id | SERIAL | Primary key |
| name | VARCHAR(255) | User's full name |
| email | VARCHAR(255) | User's email (unique) |
| password | VARCHAR(255) | Hashed password (bcrypt) |
| reset_token | VARCHAR(255) | Password reset token |
| reset_token_expiry | TIMESTAMP | Reset token expiration |
| created_at | TIMESTAMP | Account creation time |
| updated_at | TIMESTAMP | Last update time |

## Indexes

- `idx_users_email` - Fast email lookups
- `idx_users_reset_token` - Fast token verification

## Initial Data

The `init.sql` script creates a demo user:
- **Email**: demo@example.com
- **Password**: Test123!

## Usage

### Local Development

```bash
# Connect to PostgreSQL
psql -h localhost -U postgres -d authdb

# Run initialization script
psql -h localhost -U postgres -d authdb -f init.sql
```

### Docker

The init script is automatically executed when the database container starts for the first time.

```bash
docker run -d \
  --name postgres \
  -e POSTGRES_DB=authdb \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -v $(pwd)/init.sql:/docker-entrypoint-initdb.d/init.sql \
  postgres:15-alpine
```

### Kubernetes

The init script is mounted as a ConfigMap and executed on first startup via PersistentVolume.

## Migrations

For production, consider using a migration tool like:
- **node-pg-migrate**
- **Flyway**
- **Liquibase**

## Backup & Restore

```bash
# Backup
pg_dump -h localhost -U postgres authdb > backup.sql

# Restore
psql -h localhost -U postgres authdb < backup.sql
```

## Security Notes

1. Change default password in production
2. Use connection pooling for better performance
3. Enable SSL/TLS connections
4. Implement regular backups
5. Use read replicas for scaling
6. Monitor slow queries and optimize indexes

