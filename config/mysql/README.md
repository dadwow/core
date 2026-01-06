# MySQL Configuration Files

This directory contains optimized MySQL configuration files for different deployment environments.

## Available Configurations

### 1. `rpi5.cnf` - Raspberry Pi 5 (Default)
**Hardware**: Raspberry Pi 5 with 8GB RAM  
**Use Case**: Home server, small production environment

**Key Settings**:
- Buffer Pool: 3GB (60% of 8GB RAM)
- Max Connections: 150
- Optimized for ARM architecture
- Conservative I/O settings for SD card/SSD

**Best For**: Running AzerothCore on a Raspberry Pi 5 with 8GB RAM

### 2. `dev.cnf` - Development Environment
**Hardware**: Local development machine (laptop/desktop)  
**Use Case**: Local development and testing

**Key Settings**:
- Buffer Pool: 512MB (lightweight)
- Max Connections: 100
- Verbose logging enabled
- Performance schema enabled for debugging

**Best For**: Local development with Docker on your workstation

### 3. `hetzner.cnf` - Hetzner VPS
**Hardware**: Cloud VPS with SSD storage (4-8GB+ RAM)  
**Use Case**: Production cloud deployment

**Key Settings**:
- Buffer Pool: 4GB (adjust based on VPS size)
- Max Connections: 200
- SSD-optimized I/O settings
- Higher I/O capacity for cloud SSDs

**Best For**: Production deployment on Hetzner or similar cloud VPS

## Usage

### Default Configuration (Raspberry Pi 5)

By default, the `rpi5.cnf` configuration is used:

```bash
docker compose up -d
```

### Override with Different Configuration

Use the `MYSQL_CONFIG` environment variable to select a different configuration:

**For local development:**
```bash
MYSQL_CONFIG=dev.cnf docker compose up -d
```

**For Hetzner VPS:**
```bash
MYSQL_CONFIG=hetzner.cnf docker compose up -d
```

### Persistent Configuration

Add to your `.env` file:

```bash
# .env file
MYSQL_CONFIG=dev.cnf
```

Then simply run:
```bash
docker compose up -d
```

### Using with deploy.sh script

```bash
# Development
MYSQL_CONFIG=dev.cnf ./deploy.sh up

# Production (Hetzner)
MYSQL_CONFIG=hetzner.cnf ./deploy.sh up
```

## Configuration Details

### Memory Allocation

| Configuration | Buffer Pool | Total MySQL RAM | Recommended Host RAM |
|--------------|-------------|-----------------|---------------------|
| dev.cnf      | 512MB       | ~1GB           | 4GB+                |
| rpi5.cnf     | 3GB         | ~4.5GB         | 8GB                 |
| hetzner.cnf  | 4GB         | ~6GB           | 8GB+                |

### Connection Limits

| Configuration | Max Connections | Use Case |
|--------------|----------------|----------|
| dev.cnf      | 100           | 1-5 players testing |
| rpi5.cnf     | 150           | 10-50 players |
| hetzner.cnf  | 200           | 50-200 players |

### I/O Performance

- **dev.cnf**: Basic I/O settings
- **rpi5.cnf**: Conservative I/O for SD card/SSD (io_capacity: 200)
- **hetzner.cnf**: Aggressive SSD optimization (io_capacity: 2000)

## Customization

### Adjusting Buffer Pool Size

The `innodb_buffer_pool_size` is the most important tuning parameter. As a rule of thumb:
- Use 50-70% of available RAM for MySQL
- Leave enough RAM for OS and other services

**Example for 4GB RAM VPS:**
```ini
innodb_buffer_pool_size = 2G
```

**Example for 16GB RAM VPS:**
```ini
innodb_buffer_pool_size = 10G
```

### Adjusting for SSD vs HDD

If using HDD instead of SSD, reduce I/O capacity:
```ini
innodb_io_capacity = 200
innodb_io_capacity_max = 400
innodb_flush_neighbors = 1  # Enable for HDD
```

## Monitoring Performance

### Check Buffer Pool Usage

```sql
SHOW ENGINE INNODB STATUS\G
-- Look for: Buffer pool hit rate (should be > 99%)
```

### Check Connection Usage

```sql
SHOW STATUS LIKE 'Threads_connected';
SHOW STATUS LIKE 'Max_used_connections';
```

### Check Slow Queries

```bash
# View slow query log
docker exec ac-database tail -f /var/log/mysql/slow-query.log
```

## Troubleshooting

### Database Won't Start

1. **Out of Memory**: Reduce `innodb_buffer_pool_size`
2. **Permission Issues**: Check volume mounts are correct
3. **Config Syntax Error**: Validate MySQL config syntax

### Poor Performance

1. **Check buffer pool hit rate** - should be > 99%
2. **Monitor disk I/O** - may need to adjust I/O settings
3. **Review slow query log** - optimize problematic queries
4. **Check connection count** - may need to increase `max_connections`

### Applying Changes

After modifying a config file:
```bash
docker compose restart ac-database
```

Or for a clean restart:
```bash
docker compose down
docker compose up -d
```

## Additional Resources

- [MySQL 8.4 Configuration Reference](https://dev.mysql.com/doc/refman/8.4/en/server-configuration.html)
- [InnoDB Configuration Guide](https://dev.mysql.com/doc/refman/8.4/en/innodb-configuration.html)
- [MySQL Performance Tuning](https://dev.mysql.com/doc/refman/8.4/en/optimization.html)
