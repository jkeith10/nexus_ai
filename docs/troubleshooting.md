# Troubleshooting Guide

This guide helps you resolve common issues when working with the Nexus AI Agent Framework.

## Quick Diagnostics

### Check System Status
```bash
# Check if all services are running
docker-compose ps

# Check service logs
docker-compose logs

# Check system resources
docker stats --no-stream
```

### Health Check
```bash
# API health
curl http://localhost:8000/health

# UI health
curl http://localhost:3000

# Database connectivity
docker-compose exec postgres pg_isready
```

## Common Issues and Solutions

### 1. Docker Issues

#### Containers Won't Start
**Symptoms**: `docker-compose up` fails or containers exit immediately

**Solutions**:
```bash
# Check Docker daemon
docker info

# Clean up Docker system
docker system prune -f
docker volume prune -f

# Rebuild images
docker-compose build --no-cache

# Check available resources
docker system df
```

#### Port Conflicts
**Symptoms**: `Error: Port is already in use`

**Solutions**:
```bash
# Find process using port
netstat -ano | findstr :8000
netstat -ano | findstr :3000

# Kill process (replace PID with actual process ID)
taskkill /PID <PID> /F

# Or use different ports in docker-compose.yml
ports:
  - "8001:8000"  # Use port 8001 instead of 8000
```

#### Memory Issues
**Symptoms**: Containers crash with out-of-memory errors

**Solutions**:
```bash
# Increase Docker memory limit
# In Docker Desktop: Settings > Resources > Memory

# Or limit container memory usage
services:
  api:
    deploy:
      resources:
        limits:
          memory: 2G
```

### 2. Database Issues

#### Connection Refused
**Symptoms**: `psycopg2.OperationalError: could not connect to server`

**Solutions**:
```bash
# Check if PostgreSQL is running
docker-compose ps postgres

# Restart PostgreSQL
docker-compose restart postgres

# Check PostgreSQL logs
docker-compose logs postgres

# Verify connection settings in .env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=nexus_ai
DB_USER=nexus_user
DB_PASSWORD=your_password
```

#### Database Migration Issues
**Symptoms**: Schema errors or missing tables

**Solutions**:
```bash
# Reset database
docker-compose down -v
docker-compose up -d postgres
sleep 10

# Run migrations
python -m alembic upgrade head

# Or recreate database
docker-compose exec postgres psql -U nexus_user -d nexus_ai -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
```

### 3. Python Issues

#### Import Errors
**Symptoms**: `ModuleNotFoundError: No module named 'ai'`

**Solutions**:
```bash
# Install dependencies
pip install -r ai/requirements.txt
pip install -r api/requirements.txt

# Install in development mode
pip install -e .

# Check Python path
python -c "import sys; print(sys.path)"
```

#### Virtual Environment Issues
**Symptoms**: Wrong Python version or missing packages

**Solutions**:
```bash
# Create new virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows

# Install dependencies
pip install --upgrade pip
pip install -r ai/requirements.txt
pip install -r api/requirements.txt
```

#### Ray Cluster Issues
**Symptoms**: Ray workers not connecting or distributed training fails

**Solutions**:
```bash
# Start Ray cluster
ray start --head --port=10001

# Check Ray status
ray status

# Stop and restart Ray
ray stop
ray start --head --port=10001

# Check Ray logs
ray logs
```

### 4. Rust Issues

#### Build Failures
**Symptoms**: `cargo build` fails with compilation errors

**Solutions**:
```bash
# Update Rust toolchain
rustup update

# Clean and rebuild
cd core
cargo clean
cargo build

# Check Rust version
rustc --version
cargo --version
```

#### Dependency Issues
**Symptoms**: `error: failed to resolve dependencies`

**Solutions**:
```bash
# Update Cargo.lock
cargo update

# Check for outdated dependencies
cargo outdated

# Clean cargo cache
cargo clean
rm Cargo.lock
cargo build
```

### 5. Node.js/TypeScript Issues

#### npm Install Failures
**Symptoms**: `npm install` fails or hangs

**Solutions**:
```bash
# Clear npm cache
npm cache clean --force

# Delete node_modules and reinstall
cd ui
rm -rf node_modules package-lock.json
npm install

# Use yarn instead
yarn install
```

#### TypeScript Compilation Errors
**Symptoms**: TypeScript compilation fails

**Solutions**:
```bash
# Check TypeScript version
npx tsc --version

# Update TypeScript
npm install -g typescript@latest

# Check for type errors
npx tsc --noEmit

# Fix linting issues
npm run lint -- --fix
```

### 6. API Issues

#### Authentication Failures
**Symptoms**: `401 Unauthorized` or JWT token errors

**Solutions**:
```bash
# Check JWT configuration
echo $JWT_SECRET_KEY

# Generate new JWT secret
python -c "import secrets; print(secrets.token_urlsafe(32))"

# Update .env file
JWT_SECRET_KEY=your_new_secret_key

# Restart API service
docker-compose restart api
```

#### CORS Issues
**Symptoms**: Browser shows CORS errors

**Solutions**:
```bash
# Check CORS configuration in .env
CORS_ORIGINS=http://localhost:3000,http://127.0.0.1:3000

# Update API CORS settings
# In api/main.py, ensure CORS is properly configured

# Restart API service
docker-compose restart api
```

### 7. Performance Issues

#### Slow Response Times
**Symptoms**: API calls take too long

**Solutions**:
```bash
# Check system resources
docker stats

# Monitor API performance
curl -w "@curl-format.txt" -o /dev/null -s http://localhost:8000/health

# Enable API profiling
# Set DEBUG=true in .env

# Check database performance
docker-compose exec postgres psql -U nexus_user -d nexus_ai -c "SELECT * FROM pg_stat_activity;"
```

#### Memory Leaks
**Symptoms**: Memory usage keeps increasing

**Solutions**:
```bash
# Monitor memory usage
docker stats --format "table {{.Container}}\t{{.MemUsage}}\t{{.MemPerc}}"

# Check for memory leaks in Python
pip install memory-profiler
python -m memory_profiler your_script.py

# Restart services periodically
docker-compose restart
```

### 8. Network Issues

#### Service Communication
**Symptoms**: Services can't communicate with each other

**Solutions**:
```bash
# Check Docker network
docker network ls
docker network inspect nexus_ai_default

# Verify service discovery
docker-compose exec api ping postgres
docker-compose exec api ping redis

# Check DNS resolution
docker-compose exec api nslookup postgres
```

#### External API Calls
**Symptoms**: Can't connect to external APIs (OpenAI, etc.)

**Solutions**:
```bash
# Check internet connectivity
docker-compose exec api curl -I https://api.openai.com

# Verify API keys
echo $OPENAI_API_KEY
echo $ANTHROPIC_API_KEY

# Test API connectivity
curl -H "Authorization: Bearer $OPENAI_API_KEY" https://api.openai.com/v1/models
```

## Debugging Tools

### Log Analysis
```bash
# Follow logs in real-time
docker-compose logs -f

# Filter logs by service
docker-compose logs -f api
docker-compose logs -f ui

# Search logs for errors
docker-compose logs | grep -i error
docker-compose logs | grep -i exception
```

### Performance Monitoring
```bash
# Monitor system resources
htop
iotop
nethogs

# Monitor Docker resources
docker stats

# Monitor API performance
ab -n 1000 -c 10 http://localhost:8000/health
```

### Database Debugging
```bash
# Connect to database
docker-compose exec postgres psql -U nexus_user -d nexus_ai

# Check slow queries
SELECT query, mean_time, calls FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;

# Check table sizes
SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size FROM pg_tables WHERE schemaname = 'public' ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

## Recovery Procedures

### Complete Reset
```bash
# Stop all services
docker-compose down

# Remove all data
docker-compose down -v
docker system prune -f

# Rebuild everything
docker-compose build --no-cache
docker-compose up -d

# Wait for services to be ready
sleep 30

# Run health checks
curl http://localhost:8000/health
curl http://localhost:3000
```

### Data Backup and Restore
```bash
# Backup database
docker-compose exec postgres pg_dump -U nexus_user nexus_ai > backup.sql

# Restore database
docker-compose exec -T postgres psql -U nexus_user nexus_ai < backup.sql

# Backup configuration
cp .env .env.backup
cp docker-compose.yml docker-compose.yml.backup
```

### Emergency Recovery
```bash
# Emergency stop
docker-compose down --remove-orphans

# Clean slate
docker system prune -a -f
docker volume prune -f

# Fresh start
git checkout -- .
cp env.example .env
docker-compose up -d
```

## Getting Help

### Before Asking for Help
1. Check this troubleshooting guide
2. Search existing issues on GitHub
3. Check the logs for error messages
4. Try the recovery procedures above

### When Reporting Issues
Include the following information:
- Operating system and version
- Docker version
- Python/Rust/Node.js versions
- Complete error messages
- Steps to reproduce
- Log files
- Environment configuration (without sensitive data)

### Community Resources
- [GitHub Issues](https://github.com/jkeith10/nexus_ai/issues)
- [GitHub Discussions](https://github.com/jkeith10/nexus_ai/discussions)
- [Documentation](https://github.com/jkeith10/nexus_ai/tree/main/docs)

## Prevention Tips

### Regular Maintenance
```bash
# Weekly cleanup
docker system prune -f
docker image prune -f

# Monthly updates
docker-compose pull
pip install --upgrade -r ai/requirements.txt
pip install --upgrade -r api/requirements.txt
npm update

# Monitor disk space
df -h
docker system df
```

### Monitoring Setup
```bash
# Set up monitoring
docker-compose -f docker-compose.monitoring.yml up -d

# Configure alerts
# Set up email/Slack notifications for critical errors
```

### Backup Strategy
```bash
# Automated backups
# Set up cron job for daily database backups
# Store backups in S3 or other cloud storage
# Test restore procedures regularly
``` 