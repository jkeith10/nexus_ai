# Contributing to Nexus AI Agent Framework

Thank you for your interest in contributing to the Nexus AI Agent Framework! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

We welcome contributions from the community! Here are the main ways you can contribute:

- **🐛 Bug Reports**: Report bugs and issues
- **💡 Feature Requests**: Suggest new features and improvements
- **📝 Documentation**: Improve or add documentation
- **🔧 Code Contributions**: Submit code changes and improvements
- **🧪 Testing**: Help with testing and quality assurance
- **🌐 Community Support**: Help other users and contributors

## 📋 Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Code Style Guidelines](#code-style-guidelines)
- [Testing Guidelines](#testing-guidelines)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)
- [Community Guidelines](#community-guidelines)

## 🚀 Getting Started

### Prerequisites

Before contributing, ensure you have the following installed:

- **Git**: Version 2.30+
- **Docker**: Version 20.10+
- **Docker Compose**: Version 2.0+
- **PowerShell**: Version 5.0+ (Windows) or Bash (Linux/Mac)
- **Python**: Version 3.11+
- **Rust**: Version 1.70+
- **Node.js**: Version 18+

### Fork and Clone

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/nexus_ai.git
   cd nexus_ai
   ```
3. **Add the upstream remote**:
   ```bash
   git remote add upstream https://github.com/jkeith10/nexus_ai.git
   ```

## 🛠️ Development Setup

### 1. Environment Setup

```bash
# Copy environment configuration
cp .env.example .env

# Edit environment variables
nano .env  # or use your preferred editor
```

### 2. Install Dependencies

```bash
# Install Python dependencies
pip install -r ai/requirements.txt
pip install -r api/requirements.txt

# Install Rust dependencies
cd core
cargo build
cd ..

# Install Node.js dependencies
cd ui
npm install
cd ..
```

### 3. Start Development Environment

```bash
# Start all services
docker-compose up -d

# Or use the deployment script
./scripts/deploy.ps1 -Environment local
```

### 4. Verify Setup

```bash
# Check service health
./scripts/monitor.ps1 -Mode health

# Run tests
./scripts/test.ps1
```

## 📝 Code Style Guidelines

### General Principles

- **Readability**: Write code that is easy to read and understand
- **Consistency**: Follow established patterns and conventions
- **Documentation**: Document complex logic and public APIs
- **Testing**: Write tests for new features and bug fixes

### Python Code Style

Follow [PEP 8](https://www.python.org/dev/peps/pep-0008/) and use Black for formatting:

```bash
# Install development dependencies
pip install black flake8 mypy pytest

# Format code
black ai/ api/

# Lint code
flake8 ai/ api/

# Type checking
mypy ai/ api/
```

**Python Guidelines:**
- Use type hints for all function parameters and return values
- Write docstrings for all public functions and classes
- Use meaningful variable and function names
- Keep functions small and focused
- Use list comprehensions and generator expressions when appropriate

```python
# Good example
def calculate_quantum_state(
    superposition: List[float], 
    entanglement_matrix: np.ndarray
) -> QuantumState:
    """
    Calculate quantum state from superposition and entanglement.
    
    Args:
        superposition: List of superposition coefficients
        entanglement_matrix: Matrix representing entanglement
        
    Returns:
        QuantumState: Calculated quantum state
        
    Raises:
        ValueError: If superposition coefficients don't sum to 1
    """
    if not np.isclose(sum(superposition), 1.0):
        raise ValueError("Superposition coefficients must sum to 1")
    
    return QuantumState(superposition, entanglement_matrix)
```

### Rust Code Style

Follow Rust conventions and use `rustfmt` for formatting:

```bash
# Install Rust tools
rustup component add rustfmt clippy

# Format code
cargo fmt

# Lint code
cargo clippy
```

**Rust Guidelines:**
- Use meaningful variable and function names
- Write comprehensive documentation comments
- Handle errors properly with `Result` and `Option`
- Use appropriate data structures
- Follow Rust idioms and patterns

```rust
/// Calculates the quantum decision score based on superposition states.
///
/// # Arguments
///
/// * `superposition` - Vector of superposition coefficients
/// * `entanglement_matrix` - Matrix representing quantum entanglement
///
/// # Returns
///
/// Returns a `Result` containing the decision score or an error.
///
/// # Examples
///
/// ```
/// let superposition = vec![0.7, 0.3];
/// let matrix = Matrix::new(2, 2);
/// let score = calculate_quantum_score(&superposition, &matrix)?;
/// ```
pub fn calculate_quantum_score(
    superposition: &[f64],
    entanglement_matrix: &Matrix<f64>,
) -> Result<f64, QuantumError> {
    if superposition.is_empty() {
        return Err(QuantumError::EmptySuperposition);
    }
    
    let sum: f64 = superposition.iter().sum();
    if !sum.is_close(1.0, 1e-10) {
        return Err(QuantumError::InvalidSuperposition);
    }
    
    Ok(quantum_calculation(superposition, entanglement_matrix))
}
```

### TypeScript/React Code Style

Use ESLint and Prettier for formatting:

```bash
# Install development dependencies
cd ui
npm install --save-dev eslint prettier @typescript-eslint/eslint-plugin

# Format code
npm run format

# Lint code
npm run lint
```

**TypeScript/React Guidelines:**
- Use TypeScript for all new code
- Write meaningful component and function names
- Use proper TypeScript types and interfaces
- Follow React best practices and hooks
- Use functional components with hooks

```typescript
interface QuantumDecisionProps {
  superposition: number[];
  onDecision: (decision: DecisionResult) => void;
  isLoading?: boolean;
}

export const QuantumDecision: React.FC<QuantumDecisionProps> = ({
  superposition,
  onDecision,
  isLoading = false,
}) => {
  const [decision, setDecision] = useState<DecisionResult | null>(null);
  
  const handleCalculate = useCallback(async () => {
    try {
      const result = await calculateQuantumDecision(superposition);
      setDecision(result);
      onDecision(result);
    } catch (error) {
      console.error('Failed to calculate quantum decision:', error);
    }
  }, [superposition, onDecision]);
  
  return (
    <div className="quantum-decision">
      <button 
        onClick={handleCalculate}
        disabled={isLoading}
        className="btn btn-primary"
      >
        {isLoading ? 'Calculating...' : 'Calculate Decision'}
      </button>
      {decision && (
        <DecisionDisplay decision={decision} />
      )}
    </div>
  );
};
```

## 🧪 Testing Guidelines

### Test Structure

Organize tests in the following structure:

```
ai/
├── tests/
│   ├── test_distributed_neural_network.py
│   ├── test_adaptive_learning.py
│   └── test_self_healing.py
api/
├── tests/
│   ├── test_auth.py
│   ├── test_decisions.py
│   └── test_learning.py
core/
├── src/
└── tests/
    ├── test_quantum_engine.rs
    ├── test_security.rs
    └── test_agent_orchestration.rs
ui/
├── src/
└── __tests__/
    ├── components/
    └── utils/
```

### Python Testing

Use pytest for Python testing:

```python
import pytest
from unittest.mock import Mock, patch
from ai.distributed_neural_network import DistributedNeuralNetwork

class TestDistributedNeuralNetwork:
    @pytest.fixture
    def network(self):
        """Create a test network instance."""
        return DistributedNeuralNetwork(config={
            'layers': [64, 32, 16],
            'learning_rate': 0.001
        })
    
    def test_network_initialization(self, network):
        """Test network initialization."""
        assert network is not None
        assert len(network.layers) == 3
        assert network.learning_rate == 0.001
    
    @patch('ai.distributed_neural_network.Ray')
    def test_distributed_training(self, mock_ray, network):
        """Test distributed training functionality."""
        mock_ray.remote.return_value = Mock()
        
        result = network.train_distributed(test_data)
        
        assert result.accuracy > 0.8
        mock_ray.remote.assert_called()
```

### Rust Testing

Use Rust's built-in testing framework:

```rust
#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_quantum_decision_calculation() {
        let superposition = vec![0.7, 0.3];
        let matrix = Matrix::new(2, 2);
        
        let result = calculate_quantum_score(&superposition, &matrix);
        
        assert!(result.is_ok());
        let score = result.unwrap();
        assert!(score >= 0.0 && score <= 1.0);
    }
    
    #[test]
    fn test_invalid_superposition() {
        let superposition = vec![0.5, 0.3]; // Doesn't sum to 1.0
        let matrix = Matrix::new(2, 2);
        
        let result = calculate_quantum_score(&superposition, &matrix);
        
        assert!(result.is_err());
        assert!(matches!(result.unwrap_err(), QuantumError::InvalidSuperposition));
    }
}
```

### TypeScript/React Testing

Use Jest and React Testing Library:

```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import { QuantumDecision } from '../QuantumDecision';

describe('QuantumDecision', () => {
  const mockOnDecision = jest.fn();
  const defaultProps = {
    superposition: [0.7, 0.3],
    onDecision: mockOnDecision,
  };
  
  beforeEach(() => {
    jest.clearAllMocks();
  });
  
  it('renders calculate button', () => {
    render(<QuantumDecision {...defaultProps} />);
    
    expect(screen.getByText('Calculate Decision')).toBeInTheDocument();
  });
  
  it('calls onDecision when calculation completes', async () => {
    render(<QuantumDecision {...defaultProps} />);
    
    fireEvent.click(screen.getByText('Calculate Decision'));
    
    await screen.findByText('Decision Result');
    expect(mockOnDecision).toHaveBeenCalledWith(
      expect.objectContaining({
        confidence: expect.any(Number),
        decision: expect.any(String),
      })
    );
  });
});
```

### Running Tests

```bash
# Run all tests
./scripts/test.ps1

# Run specific test suites
cd ai && python -m pytest tests/ -v
cd core && cargo test
cd ui && npm test

# Run tests with coverage
cd ai && python -m pytest tests/ --cov=ai --cov-report=html
cd core && cargo tarpaulin --out Html
cd ui && npm run test:coverage
```

## 🔄 Pull Request Process

### 1. Create a Feature Branch

```bash
# Update your fork
git fetch upstream
git checkout main
git merge upstream/main

# Create a new branch
git checkout -b feature/your-feature-name
```

### 2. Make Your Changes

- Write your code following the style guidelines
- Add tests for new functionality
- Update documentation as needed
- Ensure all tests pass

### 3. Commit Your Changes

```bash
# Stage your changes
git add .

# Commit with a descriptive message
git commit -m "feat: add quantum decision optimization

- Implement new quantum algorithm for decision making
- Add comprehensive test coverage
- Update API documentation
- Fix performance issues in distributed training

Closes #123"
```

**Commit Message Format:**
```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### 4. Push and Create Pull Request

```bash
# Push your branch
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub with:

- **Clear title**: Describe the change concisely
- **Detailed description**: Explain what, why, and how
- **Related issues**: Link to any related issues
- **Screenshots**: For UI changes
- **Test results**: Show that tests pass

### 5. Pull Request Template

```markdown
## Description
Brief description of the changes made.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Performance impact assessed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] No breaking changes (or documented)

## Screenshots (if applicable)
Add screenshots for UI changes.

## Additional Notes
Any additional information or context.
```

## 🐛 Issue Reporting

### Before Creating an Issue

1. **Search existing issues** to avoid duplicates
2. **Check documentation** for solutions
3. **Try the latest version** of the framework

### Issue Template

```markdown
## Bug Report

### Environment
- **OS**: [e.g., Windows 11, Ubuntu 20.04, macOS 12]
- **Framework Version**: [e.g., 0.1.0]
- **Docker Version**: [e.g., 20.10.0]
- **Python Version**: [e.g., 3.11.0]

### Description
Clear and concise description of the bug.

### Steps to Reproduce
1. Go to '...'
2. Click on '...'
3. Scroll down to '...'
4. See error

### Expected Behavior
What you expected to happen.

### Actual Behavior
What actually happened.

### Additional Context
- Screenshots
- Logs
- Error messages
- Configuration files
```

## 📚 Documentation Guidelines

### Documentation Structure

```
docs/
├── architecture.md          # System architecture
├── api-reference.md         # API documentation
├── deployment.md           # Deployment guide
├── security.md             # Security guide
├── contributing.md         # This file
├── troubleshooting.md      # Common issues and solutions
└── examples/               # Code examples
    ├── basic-usage.md
    ├── advanced-features.md
    └── integration-guides.md
```

### Writing Documentation

- **Clear and concise**: Use simple, direct language
- **Examples**: Include code examples and use cases
- **Structure**: Use headers, lists, and code blocks
- **Accuracy**: Ensure all information is current and correct
- **Completeness**: Cover all aspects of the feature

## 🤝 Community Guidelines

### Code of Conduct

We are committed to providing a welcoming and inclusive environment for all contributors. Please:

- **Be respectful**: Treat others with respect and kindness
- **Be constructive**: Provide helpful, constructive feedback
- **Be inclusive**: Welcome contributors from all backgrounds
- **Be patient**: Give others time to respond and learn

### Communication Channels

- **GitHub Issues**: For bug reports and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Pull Requests**: For code contributions
- **Documentation**: For improvements and clarifications

### Recognition

Contributors will be recognized in:

- **README.md**: List of contributors
- **Release notes**: Credit for significant contributions
- **Documentation**: Attribution for documentation contributions

## 🚀 Getting Help

If you need help contributing:

1. **Check the documentation**: Start with the README and docs
2. **Search existing issues**: Look for similar questions
3. **Create a discussion**: Use GitHub Discussions for questions
4. **Join the community**: Connect with other contributors

## 📄 License

By contributing to Nexus AI Agent Framework, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to Nexus AI Agent Framework! 🎉 