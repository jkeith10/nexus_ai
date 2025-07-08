# Basic Usage Guide

This guide will help you get started with the Nexus AI Agent Framework quickly.

## Quick Start

### 1. Prerequisites

Ensure you have the following installed:
- Docker and Docker Compose
- Python 3.11+
- Node.js 18+
- Rust 1.70+

### 2. Clone and Setup

```bash
git clone https://github.com/jkeith10/nexus_ai.git
cd nexus_ai
cp env.example .env
# Edit .env with your configuration
```

### 3. Start the Framework

```bash
# Using Docker (recommended)
docker-compose up -d

# Or using Makefile
make docker-run
```

### 4. Access the Dashboard

Open your browser and navigate to:
- **UI Dashboard**: http://localhost:3000
- **API Documentation**: http://localhost:8000/docs
- **Health Check**: http://localhost:8000/health

## Basic Examples

### Python AI Module

```python
from ai.distributed_neural_network import DistributedNeuralNetwork
from ai.adaptive_learning import AdaptiveLearning

# Initialize the neural network
network = DistributedNeuralNetwork(
    layers=[64, 32, 16],
    learning_rate=0.001
)

# Train the network
training_data = [
    {"input": [1, 0, 1, 0], "output": [1]},
    {"input": [0, 1, 0, 1], "output": [0]}
]

result = network.train_distributed(training_data)
print(f"Training accuracy: {result.accuracy}")

# Use adaptive learning
learner = AdaptiveLearning()
learner.adapt_to_new_data(new_data)
```

### Rust Core Integration

```rust
use nexus_ai::quantum_substrate::QuantumEngine;
use nexus_ai::agent_orchestration::AgentOrchestrator;

// Initialize quantum engine
let mut engine = QuantumEngine::new();
engine.set_superposition(vec![0.7, 0.3]);

// Make quantum-inspired decision
let decision = engine.calculate_decision(&input_data)?;
println!("Decision confidence: {}", decision.confidence);

// Orchestrate agents
let mut orchestrator = AgentOrchestrator::new();
orchestrator.add_agent("decision_agent", decision_agent);
orchestrator.add_agent("learning_agent", learning_agent);
orchestrator.coordinate_agents(&task);
```

### API Usage

```python
import requests

# Authentication
auth_response = requests.post("http://localhost:8000/auth/login", json={
    "username": "admin",
    "password": "password"
})
token = auth_response.json()["access_token"]
headers = {"Authorization": f"Bearer {token}"}

# Make a decision
decision_response = requests.post(
    "http://localhost:8000/api/v1/decisions",
    json={
        "input_data": [1, 0, 1, 0],
        "context": "classification_task"
    },
    headers=headers
)

decision = decision_response.json()
print(f"Decision: {decision['result']}")
print(f"Confidence: {decision['confidence']}")
```

### React UI Integration

```typescript
import React, { useState, useEffect } from 'react';
import { useNexusAI } from '../hooks/useNexusAI';

const DecisionComponent: React.FC = () => {
  const [input, setInput] = useState('');
  const [decision, setDecision] = useState(null);
  const { makeDecision, isLoading } = useNexusAI();

  const handleSubmit = async () => {
    const result = await makeDecision({
      input_data: input.split(',').map(Number),
      context: 'user_decision'
    });
    setDecision(result);
  };

  return (
    <div className="decision-component">
      <input
        type="text"
        value={input}
        onChange={(e) => setInput(e.target.value)}
        placeholder="Enter input data (comma-separated)"
      />
      <button onClick={handleSubmit} disabled={isLoading}>
        {isLoading ? 'Processing...' : 'Get Decision'}
      </button>
      {decision && (
        <div className="result">
          <h3>Decision Result</h3>
          <p>Result: {decision.result}</p>
          <p>Confidence: {decision.confidence}%</p>
        </div>
      )}
    </div>
  );
};
```

## Configuration Examples

### Environment Variables

```bash
# Basic configuration
APP_ENV=development
DEBUG=true
LOG_LEVEL=INFO

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=nexus_ai
DB_USER=nexus_user
DB_PASSWORD=secure_password

# AI Models
OPENAI_API_KEY=your_openai_key
ANTHROPIC_API_KEY=your_anthropic_key

# Security
JWT_SECRET_KEY=your_jwt_secret
PASSWORD_SALT_ROUNDS=12
```

### Docker Compose Customization

```yaml
version: '3.8'
services:
  nexus-ai:
    build: .
    ports:
      - "8000:8000"
    environment:
      - APP_ENV=production
      - DB_HOST=postgres
    depends_on:
      - postgres
      - redis

  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: nexus_ai
      POSTGRES_USER: nexus_user
      POSTGRES_PASSWORD: secure_password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    command: redis-server --requirepass redis_password
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

## Common Use Cases

### 1. Classification Task

```python
# Train a classifier
classifier = DistributedNeuralNetwork(
    layers=[100, 50, 25, 10],
    learning_rate=0.001
)

# Prepare training data
training_data = [
    {"input": features, "output": [class_label]}
    for features, class_label in dataset
]

# Train and evaluate
result = classifier.train_distributed(training_data)
print(f"Classification accuracy: {result.accuracy}")

# Make predictions
predictions = classifier.predict(new_data)
```

### 2. Decision Making

```python
# Use quantum-inspired decision making
from ai.quantum_decision import QuantumDecisionMaker

decision_maker = QuantumDecisionMaker()

# Define decision options
options = [
    {"id": "option_a", "weight": 0.6},
    {"id": "option_b", "weight": 0.4}
]

# Make decision with context
decision = decision_maker.make_decision(
    options=options,
    context={"risk_tolerance": "medium", "time_constraint": "high"}
)

print(f"Recommended option: {decision.recommended_option}")
print(f"Confidence: {decision.confidence}")
```

### 3. Adaptive Learning

```python
# Implement adaptive learning
from ai.adaptive_learning import AdaptiveLearning

learner = AdaptiveLearning()

# Initial training
learner.train(initial_data)

# Adapt to new patterns
for new_batch in streaming_data:
    learner.adapt(new_batch)
    
    # Check if retraining is needed
    if learner.needs_retraining():
        learner.retrain()
```

## Troubleshooting

### Common Issues

1. **Docker containers not starting**
   ```bash
   # Check logs
   docker-compose logs
   
   # Restart services
   docker-compose down && docker-compose up -d
   ```

2. **Database connection issues**
   ```bash
   # Check database status
   docker-compose ps postgres
   
   # Reset database
   docker-compose down -v && docker-compose up -d
   ```

3. **API authentication errors**
   ```bash
   # Check JWT configuration
   echo $JWT_SECRET_KEY
   
   # Verify token format
   curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:8000/health
   ```

### Performance Optimization

```python
# Enable distributed training
network = DistributedNeuralNetwork(
    distributed=True,
    num_workers=4,
    batch_size=32
)

# Use GPU acceleration (if available)
network.enable_gpu()

# Optimize memory usage
network.set_memory_limit("4GB")
```

## Next Steps

After mastering the basics:

1. **Explore Advanced Features**: Check out the advanced usage guide
2. **Customize Models**: Learn how to create custom neural network architectures
3. **Deploy to Production**: Follow the deployment guide for production setup
4. **Contribute**: Read the contributing guidelines to help improve the framework

For more detailed information, refer to the [API Reference](api-reference.md) and [Architecture Guide](architecture.md). 