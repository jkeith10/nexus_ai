# Multi-stage build for Nexus AI Agent Framework
FROM rust:1.88-slim as rust-builder

WORKDIR /app
COPY core/ .
RUN cargo build --release

FROM python:3.11-slim as python-builder

WORKDIR /app
COPY ai/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY ai/ .
RUN python -m compileall .

FROM node:18-alpine as node-builder

WORKDIR /app
COPY ui/package*.json ./
RUN npm ci --only=production

COPY ui/ .
RUN npm run build

# Final stage
FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create app user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set working directory
WORKDIR /app

# Copy Rust binary
COPY --from=rust-builder /app/target/release/nexus-core /usr/local/bin/

# Copy Python dependencies and code
COPY --from=python-builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=python-builder /app /app/ai

# Copy Node.js build
COPY --from=node-builder /app/build /app/ui/build

# Copy API code
COPY api/ /app/api/

# Install API dependencies
RUN pip install --no-cache-dir -r /app/api/requirements.txt

# Copy configuration and scripts
COPY docker-compose.yml .
COPY scripts/ /app/scripts/
COPY docs/ /app/docs/

# Set permissions
RUN chown -R appuser:appuser /app
USER appuser

# Expose ports
EXPOSE 8000 3000 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Default command
CMD ["python", "-m", "uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8000"] 