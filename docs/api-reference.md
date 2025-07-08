# Nexus AI Agent Framework - API Reference

## Overview

The Nexus AI Agent Framework provides a comprehensive RESTful API for interacting with the quantum-inspired AI system. This document details all available endpoints, request/response schemas, authentication, and usage examples.

## 🔐 Authentication

### JWT Token Authentication

All API endpoints require authentication using JWT tokens. Include the token in the Authorization header:

```http
Authorization: Bearer <your-jwt-token>
```

### Getting a Token

```http
POST /auth/login
Content-Type: application/json

{
  "username": "your_username",
  "password": "your_password"
}
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "expires_in": 3600,
  "user": {
    "id": "uuid",
    "username": "your_username",
    "email": "user@example.com",
    "role": "user"
  }
}
```

## 📊 Base URL

```
Production: https://api.nexus-ai.com
Development: http://localhost:8000
```

## 🎯 Decision Making Endpoints

### Create Decision

```http
POST /decisions
Content-Type: application/json
Authorization: Bearer <token>

{
  "input_data": {
    "context": "Investment decision for tech startup",
    "options": [
      {
        "id": "option_1",
        "description": "Invest $100K in Series A",
        "parameters": {
          "amount": 100000,
          "equity": 0.15,
          "risk_level": "medium"
        }
      },
      {
        "id": "option_2", 
        "description": "Invest $50K in convertible note",
        "parameters": {
          "amount": 50000,
          "interest_rate": 0.08,
          "risk_level": "low"
        }
      }
    ],
    "constraints": {
      "max_investment": 150000,
      "risk_tolerance": "moderate",
      "time_horizon": "5_years"
    }
  },
  "decision_type": "investment",
  "priority": "high"
}
```

**Response:**
```json
{
  "decision_id": "uuid",
  "result": {
    "selected_option": "option_1",
    "confidence": 0.87,
    "uncertainty": 0.13,
    "reasoning": "Based on quantum analysis, Option 1 provides optimal risk-adjusted returns",
    "quantum_state": {
      "superposition": [0.87, 0.13],
      "entanglement_score": 0.92
    }
  },
  "processing_time": 0.045,
  "created_at": "2024-01-15T10:30:00Z"
}
```

### Get Decision History

```http
GET /decisions?user_id=uuid&limit=10&offset=0
Authorization: Bearer <token>
```

**Response:**
```json
{
  "decisions": [
    {
      "id": "uuid",
      "input_data": {...},
      "result": {...},
      "confidence": 0.87,
      "uncertainty": 0.13,
      "processing_time": 0.045,
      "created_at": "2024-01-15T10:30:00Z"
    }
  ],
  "total_count": 150,
  "has_more": true
}
```

### Get Decision by ID

```http
GET /decisions/{decision_id}
Authorization: Bearer <token>
```

## 🧠 Learning Endpoints

### Submit Learning Task

```http
POST /learning/tasks
Content-Type: application/json
Authorization: Bearer <token>

{
  "task_type": "supervised",
  "model_type": "neural_network",
  "input_data": {
    "features": [[1, 2, 3], [4, 5, 6], ...],
    "labels": [0, 1, 0, ...],
    "validation_split": 0.2
  },
  "hyperparameters": {
    "learning_rate": 0.001,
    "batch_size": 32,
    "epochs": 100,
    "layers": [64, 32, 16]
  },
  "optimization_goal": "accuracy"
}
```

**Response:**
```json
{
  "task_id": "uuid",
  "status": "queued",
  "estimated_duration": 300,
  "created_at": "2024-01-15T10:30:00Z"
}
```

### Get Learning Task Status

```http
GET /learning/tasks/{task_id}
Authorization: Bearer <token>
```

**Response:**
```json
{
  "task_id": "uuid",
  "status": "completed",
  "progress": 100,
  "result": {
    "accuracy": 0.94,
    "loss": 0.12,
    "training_time": 245.6,
    "model_path": "/models/task_uuid.pkl"
  },
  "created_at": "2024-01-15T10:30:00Z",
  "completed_at": "2024-01-15T10:35:00Z"
}
```

### Get Learning History

```http
GET /learning/tasks?user_id=uuid&status=completed&limit=10
Authorization: Bearer <token>
```

## 🤝 Collaborative Endpoints

### Start Collaborative Session

```http
POST /collaborative/sessions
Content-Type: application/json
Authorization: Bearer <token>

{
  "problem_description": "Optimize supply chain for global manufacturing",
  "complexity_level": "high",
  "collaboration_mode": "interactive",
  "participants": ["user1", "user2"],
  "constraints": {
    "time_limit": 3600,
    "budget_limit": 1000000
  }
}
```

**Response:**
```json
{
  "session_id": "uuid",
  "status": "active",
  "ai_agent_id": "agent_uuid",
  "workspace_url": "/collaborative/workspace/uuid",
  "created_at": "2024-01-15T10:30:00Z"
}
```

### Submit Collaborative Input

```http
POST /collaborative/sessions/{session_id}/input
Content-Type: application/json
Authorization: Bearer <token>

{
  "input_type": "constraint",
  "content": "Must maintain 99.9% uptime during transition",
  "priority": "high",
  "source": "human"
}
```

**Response:**
```json
{
  "input_id": "uuid",
  "processed": true,
  "ai_response": {
    "acknowledgment": "Constraint registered",
    "impact_assessment": "High impact on timeline",
    "suggested_adjustments": ["Increase buffer time", "Add redundancy"]
  },
  "created_at": "2024-01-15T10:32:00Z"
}
```

### Get Session Status

```http
GET /collaborative/sessions/{session_id}
Authorization: Bearer <token>
```

**Response:**
```json
{
  "session_id": "uuid",
  "status": "active",
  "problem_description": "Optimize supply chain for global manufacturing",
  "progress": 65,
  "participants": ["user1", "user2"],
  "ai_agent_id": "agent_uuid",
  "collaboration_score": 0.89,
  "inputs": [
    {
      "id": "uuid",
      "type": "constraint",
      "content": "Must maintain 99.9% uptime",
      "source": "human",
      "timestamp": "2024-01-15T10:32:00Z"
    }
  ],
  "solutions": [
    {
      "id": "uuid",
      "description": "Phased rollout with redundancy",
      "confidence": 0.92,
      "created_at": "2024-01-15T10:35:00Z"
    }
  ]
}
```

## 📈 Monitoring Endpoints

### Get System Health

```http
GET /monitoring/health
Authorization: Bearer <token>
```

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00Z",
  "components": {
    "core": {
      "status": "healthy",
      "uptime": 86400,
      "memory_usage": 0.45,
      "cpu_usage": 0.32
    },
    "ai_module": {
      "status": "healthy",
      "uptime": 86400,
      "gpu_usage": 0.78,
      "active_models": 5
    },
    "database": {
      "status": "healthy",
      "connections": 12,
      "query_time": 0.015
    }
  },
  "overall_health_score": 0.95
}
```

### Get Performance Metrics

```http
GET /monitoring/metrics?time_range=1h&interval=5m
Authorization: Bearer <token>
```

**Response:**
```json
{
  "time_range": "1h",
  "interval": "5m",
  "metrics": {
    "decision_latency": {
      "p50": 0.045,
      "p95": 0.089,
      "p99": 0.156,
      "mean": 0.052
    },
    "throughput": {
      "requests_per_second": 1250,
      "decisions_per_second": 890,
      "learning_tasks_per_hour": 45
    },
    "accuracy": {
      "decision_accuracy": 0.94,
      "learning_accuracy": 0.91,
      "collaboration_score": 0.89
    },
    "resource_usage": {
      "cpu_utilization": 0.32,
      "memory_utilization": 0.45,
      "gpu_utilization": 0.78,
      "disk_usage": 0.23
    }
  },
  "data_points": [
    {
      "timestamp": "2024-01-15T10:25:00Z",
      "decision_latency": 0.045,
      "throughput": 1250,
      "accuracy": 0.94
    }
  ]
}
```

### Get Error Logs

```http
GET /monitoring/errors?severity=error&limit=50
Authorization: Bearer <token>
```

**Response:**
```json
{
  "errors": [
    {
      "id": "uuid",
      "timestamp": "2024-01-15T10:28:00Z",
      "severity": "error",
      "component": "ai_module",
      "message": "GPU memory allocation failed",
      "stack_trace": "...",
      "resolved": true,
      "resolution_time": "2024-01-15T10:29:00Z"
    }
  ],
  "total_count": 3,
  "error_rate": 0.001
}
```

## 🔧 Configuration Endpoints

### Get System Configuration

```http
GET /config/system
Authorization: Bearer <token>
```

**Response:**
```json
{
  "quantum_engine": {
    "enabled": true,
    "max_superposition_states": 1000,
    "entanglement_threshold": 0.8
  },
  "ai_module": {
    "max_concurrent_tasks": 10,
    "gpu_memory_limit": "8GB",
    "model_cache_size": "2GB"
  },
  "security": {
    "rate_limit_per_minute": 100,
    "max_session_duration": 3600,
    "encryption_level": "quantum_resistant"
  },
  "monitoring": {
    "metrics_retention_days": 30,
    "alert_thresholds": {
      "cpu_usage": 0.8,
      "memory_usage": 0.85,
      "error_rate": 0.01
    }
  }
}
```

### Update Configuration

```http
PUT /config/system
Content-Type: application/json
Authorization: Bearer <token>

{
  "quantum_engine": {
    "max_superposition_states": 1500
  },
  "monitoring": {
    "alert_thresholds": {
      "cpu_usage": 0.85
    }
  }
}
```

## 👥 User Management Endpoints

### Get User Profile

```http
GET /users/profile
Authorization: Bearer <token>
```

**Response:**
```json
{
  "id": "uuid",
  "username": "john_doe",
  "email": "john@example.com",
  "role": "user",
  "preferences": {
    "theme": "dark",
    "language": "en",
    "notifications": {
      "email": true,
      "push": false
    }
  },
  "statistics": {
    "total_decisions": 150,
    "average_confidence": 0.87,
    "collaboration_sessions": 25,
    "learning_tasks": 45
  },
  "created_at": "2024-01-01T00:00:00Z",
  "last_login": "2024-01-15T10:00:00Z"
}
```

### Update User Profile

```http
PUT /users/profile
Content-Type: application/json
Authorization: Bearer <token>

{
  "preferences": {
    "theme": "light",
    "notifications": {
      "email": false,
      "push": true
    }
  }
}
```

## 📊 Analytics Endpoints

### Get User Analytics

```http
GET /analytics/user?time_range=30d
Authorization: Bearer <token>
```

**Response:**
```json
{
  "time_range": "30d",
  "decisions": {
    "total": 150,
    "by_type": {
      "investment": 45,
      "strategic": 35,
      "operational": 70
    },
    "accuracy_trend": [
      {"date": "2024-01-01", "accuracy": 0.85},
      {"date": "2024-01-15", "accuracy": 0.94}
    ]
  },
  "learning": {
    "tasks_completed": 45,
    "average_accuracy": 0.91,
    "models_trained": 12
  },
  "collaboration": {
    "sessions": 25,
    "average_score": 0.89,
    "time_spent": 18000
  }
}
```

### Get System Analytics

```http
GET /analytics/system?time_range=7d
Authorization: Bearer <token>
```

**Response:**
```json
{
  "time_range": "7d",
  "performance": {
    "average_response_time": 0.052,
    "throughput": 1250,
    "availability": 0.999
  },
  "usage": {
    "active_users": 150,
    "total_decisions": 2500,
    "learning_tasks": 180,
    "collaboration_sessions": 75
  },
  "resource_utilization": {
    "cpu_average": 0.32,
    "memory_average": 0.45,
    "gpu_average": 0.78
  }
}
```

## 🚨 Error Handling

### Error Response Format

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": {
      "field": "input_data",
      "issue": "Missing required field 'context'"
    },
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "uuid"
  }
}
```

### Common Error Codes

| Code | Description | HTTP Status |
|------|-------------|-------------|
| `AUTHENTICATION_ERROR` | Invalid or expired token | 401 |
| `AUTHORIZATION_ERROR` | Insufficient permissions | 403 |
| `VALIDATION_ERROR` | Invalid request data | 400 |
| `RESOURCE_NOT_FOUND` | Requested resource not found | 404 |
| `RATE_LIMIT_EXCEEDED` | Too many requests | 429 |
| `INTERNAL_ERROR` | Server error | 500 |
| `SERVICE_UNAVAILABLE` | Service temporarily unavailable | 503 |

## 📝 Rate Limiting

The API implements rate limiting to ensure fair usage:

- **Standard users**: 100 requests per minute
- **Premium users**: 500 requests per minute
- **Enterprise users**: 2000 requests per minute

Rate limit headers are included in responses:

```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1642234560
```

## 🔄 Webhooks

### Configure Webhook

```http
POST /webhooks
Content-Type: application/json
Authorization: Bearer <token>

{
  "url": "https://your-app.com/webhook",
  "events": ["decision.completed", "learning.task.finished"],
  "secret": "your-webhook-secret"
}
```

### Webhook Payload Example

```json
{
  "event": "decision.completed",
  "timestamp": "2024-01-15T10:30:00Z",
  "data": {
    "decision_id": "uuid",
    "user_id": "uuid",
    "result": {
      "selected_option": "option_1",
      "confidence": 0.87
    }
  },
  "signature": "sha256=..."
}
```

## 📚 SDK Examples

### Python SDK

```python
from nexus_ai import NexusClient

client = NexusClient(api_key="your-api-key")

# Create decision
decision = client.decisions.create(
    input_data={
        "context": "Investment decision",
        "options": [...],
        "constraints": {...}
    }
)

# Get decision result
result = client.decisions.get(decision.id)
print(f"Confidence: {result.confidence}")
```

### JavaScript SDK

```javascript
import { NexusClient } from '@nexus-ai/sdk';

const client = new NexusClient({ apiKey: 'your-api-key' });

// Create decision
const decision = await client.decisions.create({
  inputData: {
    context: 'Investment decision',
    options: [...],
    constraints: {...}
  }
});

// Get decision result
const result = await client.decisions.get(decision.id);
console.log(`Confidence: ${result.confidence}`);
```

## 🔗 Additional Resources

- [Authentication Guide](./authentication.md)
- [Webhook Documentation](./webhooks.md)
- [SDK Documentation](./sdk.md)
- [Error Codes Reference](./error-codes.md)
- [Rate Limiting Guide](./rate-limiting.md) 