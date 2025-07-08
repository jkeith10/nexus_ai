# Nexus AI Agent Framework - Deployment Script
# PowerShell script for deploying the complete framework

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("local", "dev", "staging", "prod")]
    [string]$Environment = "local",
    
    [Parameter(Mandatory=$false)]
    [string]$ConfigFile = ".env",
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipBuild,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipTests,
    
    [Parameter(Mandatory=$false)]
    [switch]$Force,
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun,
    
    [Parameter(Mandatory=$false)]
    [switch]$Help
)

# Script configuration
$ScriptVersion = "1.0.0"
$ProjectName = "Nexus AI Agent Framework"
$RequiredDockerVersion = "20.10.0"
$RequiredComposeVersion = "2.0.0"

# Color codes for output
$Colors = @{
    Red = "Red"
    Green = "Green"
    Yellow = "Yellow"
    Blue = "Blue"
    Cyan = "Cyan"
    White = "White"
}

# Function to write colored output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White",
        [switch]$NoNewline
    )
    
    if ($NoNewline) {
        Write-Host $Message -ForegroundColor $Colors[$Color] -NoNewline
    } else {
        Write-Host $Message -ForegroundColor $Colors[$Color]
    }
}

# Function to show help
function Show-Help {
    Write-ColorOutput "=== $ProjectName Deployment Script ===" "Cyan"
    Write-ColorOutput "Version: $ScriptVersion" "Blue"
    Write-ColorOutput ""
    Write-ColorOutput "Usage:" "Yellow"
    Write-ColorOutput "  .\deploy.ps1 [Options]" "White"
    Write-ColorOutput ""
    Write-ColorOutput "Options:" "Yellow"
    Write-ColorOutput "  -Environment <string>  Deployment environment (local, dev, staging, prod)" "White"
    Write-ColorOutput "  -ConfigFile <string>   Configuration file path (default: .env)" "White"
    Write-ColorOutput "  -SkipBuild             Skip building Docker images" "White"
    Write-ColorOutput "  -SkipTests             Skip running tests" "White"
    Write-ColorOutput "  -Force                 Force deployment without confirmation" "White"
    Write-ColorOutput "  -DryRun                Show what would be deployed without executing" "White"
    Write-ColorOutput "  -Help                  Show this help message" "White"
    Write-ColorOutput ""
    Write-ColorOutput "Examples:" "Yellow"
    Write-ColorOutput "  .\deploy.ps1 -Environment local" "White"
    Write-ColorOutput "  .\deploy.ps1 -Environment prod -ConfigFile .env.prod" "White"
    Write-ColorOutput "  .\deploy.ps1 -Environment dev -SkipTests -Force" "White"
    Write-ColorOutput "  .\deploy.ps1 -Environment staging -DryRun" "White"
}

# Function to check prerequisites
function Test-Prerequisites {
    Write-ColorOutput "Checking prerequisites..." "Blue"
    
    # Check PowerShell version
    $PSVersion = $PSVersionTable.PSVersion
    if ($PSVersion.Major -lt 5) {
        Write-ColorOutput "ERROR: PowerShell 5.0 or higher is required. Current version: $PSVersion" "Red"
        exit 1
    }
    Write-ColorOutput "✓ PowerShell version: $PSVersion" "Green"
    
    # Check Docker
    try {
        $DockerVersion = docker --version 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "Docker not found"
        }
        Write-ColorOutput "✓ Docker: $DockerVersion" "Green"
    } catch {
        Write-ColorOutput "ERROR: Docker is not installed or not running" "Red"
        Write-ColorOutput "Please install Docker Desktop and ensure it's running" "Yellow"
        exit 1
    }
    
    # Check Docker Compose
    try {
        $ComposeVersion = docker-compose --version 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "Docker Compose not found"
        }
        Write-ColorOutput "✓ Docker Compose: $ComposeVersion" "Green"
    } catch {
        Write-ColorOutput "ERROR: Docker Compose is not installed" "Red"
        Write-ColorOutput "Please install Docker Compose" "Yellow"
        exit 1
    }
    
    # Check Git
    try {
        $GitVersion = git --version 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "Git not found"
        }
        Write-ColorOutput "✓ Git: $GitVersion" "Green"
    } catch {
        Write-ColorOutput "ERROR: Git is not installed" "Red"
        Write-ColorOutput "Please install Git" "Yellow"
        exit 1
    }
    
    # Check if we're in the project directory
    if (-not (Test-Path "docker-compose.yml")) {
        Write-ColorOutput "ERROR: docker-compose.yml not found. Please run this script from the project root." "Red"
        exit 1
    }
    
    Write-ColorOutput "✓ All prerequisites satisfied" "Green"
}

# Function to validate configuration
function Test-Configuration {
    param([string]$ConfigPath)
    
    Write-ColorOutput "Validating configuration..." "Blue"
    
    if (-not (Test-Path $ConfigPath)) {
        Write-ColorOutput "ERROR: Configuration file not found: $ConfigPath" "Red"
        exit 1
    }
    
    # Read and validate environment variables
    $Config = Get-Content $ConfigPath | Where-Object { $_ -match '^[^#].*=.*' }
    $RequiredVars = @(
        "POSTGRES_PASSWORD",
        "JWT_SECRET",
        "ENCRYPTION_KEY",
        "REDIS_PASSWORD"
    )
    
    $MissingVars = @()
    foreach ($Var in $RequiredVars) {
        if (-not ($Config | Where-Object { $_ -match "^$Var=" })) {
            $MissingVars += $Var
        }
    }
    
    if ($MissingVars.Count -gt 0) {
        Write-ColorOutput "ERROR: Missing required environment variables:" "Red"
        foreach ($Var in $MissingVars) {
            Write-ColorOutput "  - $Var" "Red"
        }
        Write-ColorOutput "Please update your configuration file: $ConfigPath" "Yellow"
        exit 1
    }
    
    Write-ColorOutput "✓ Configuration validated" "Green"
}

# Function to run tests
function Invoke-Tests {
    if ($SkipTests) {
        Write-ColorOutput "Skipping tests..." "Yellow"
        return
    }
    
    Write-ColorOutput "Running tests..." "Blue"
    
    # Run Python tests
    if (Test-Path "ai/tests") {
        Write-ColorOutput "Running AI module tests..." "Cyan"
        docker-compose run --rm nexus-ai python -m pytest ai/tests/ -v
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "ERROR: AI module tests failed" "Red"
            exit 1
        }
    }
    
    # Run API tests
    if (Test-Path "api/tests") {
        Write-ColorOutput "Running API tests..." "Cyan"
        docker-compose run --rm nexus-api python -m pytest api/tests/ -v
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "ERROR: API tests failed" "Red"
            exit 1
        }
    }
    
    # Run Rust tests
    if (Test-Path "core") {
        Write-ColorOutput "Running Core tests..." "Cyan"
        docker-compose run --rm nexus-core cargo test
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "ERROR: Core tests failed" "Red"
            exit 1
        }
    }
    
    Write-ColorOutput "✓ All tests passed" "Green"
}

# Function to build images
function Invoke-Build {
    if ($SkipBuild) {
        Write-ColorOutput "Skipping build..." "Yellow"
        return
    }
    
    Write-ColorOutput "Building Docker images..." "Blue"
    
    # Build all services
    docker-compose build --no-cache
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "ERROR: Docker build failed" "Red"
        exit 1
    }
    
    Write-ColorOutput "✓ All images built successfully" "Green"
}

# Function to deploy services
function Invoke-Deploy {
    param([string]$Env)
    
    Write-ColorOutput "Deploying to $Env environment..." "Blue"
    
    # Stop existing services
    Write-ColorOutput "Stopping existing services..." "Cyan"
    docker-compose down --remove-orphans
    
    # Start services
    Write-ColorOutput "Starting services..." "Cyan"
    docker-compose up -d
    
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "ERROR: Service deployment failed" "Red"
        exit 1
    }
    
    # Wait for services to be ready
    Write-ColorOutput "Waiting for services to be ready..." "Cyan"
    Start-Sleep -Seconds 30
    
    # Check service health
    Write-ColorOutput "Checking service health..." "Cyan"
    $Services = @("nexus-core", "nexus-ai", "nexus-api", "nexus-ui")
    $HealthyServices = 0
    
    foreach ($Service in $Services) {
        try {
            $HealthCheck = docker-compose exec -T $Service curl -f http://localhost/health 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "✓ $Service is healthy" "Green"
                $HealthyServices++
            } else {
                Write-ColorOutput "✗ $Service health check failed" "Red"
            }
        } catch {
            Write-ColorOutput "✗ $Service health check failed" "Red"
        }
    }
    
    if ($HealthyServices -eq $Services.Count) {
        Write-ColorOutput "✓ All services are healthy" "Green"
    } else {
        Write-ColorOutput "WARNING: Some services may not be fully ready" "Yellow"
    }
}

# Function to show deployment status
function Show-Status {
    Write-ColorOutput "Deployment Status:" "Blue"
    docker-compose ps
    
    Write-ColorOutput ""
    Write-ColorOutput "Service URLs:" "Blue"
    Write-ColorOutput "  UI: http://localhost:3000" "Cyan"
    Write-ColorOutput "  API: http://localhost:8000" "Cyan"
    Write-ColorOutput "  Core: http://localhost:8080" "Cyan"
    Write-ColorOutput "  AI Module: http://localhost:8081" "Cyan"
    Write-ColorOutput "  Grafana: http://localhost:3001" "Cyan"
    Write-ColorOutput "  Kibana: http://localhost:5601" "Cyan"
    
    Write-ColorOutput ""
    Write-ColorOutput "Logs:" "Blue"
    Write-ColorOutput "  docker-compose logs -f" "Cyan"
}

# Function to handle cleanup
function Invoke-Cleanup {
    Write-ColorOutput "Cleaning up..." "Blue"
    
    # Stop and remove containers
    docker-compose down --remove-orphans
    
    # Remove unused images
    docker image prune -f
    
    # Remove unused volumes
    docker volume prune -f
    
    Write-ColorOutput "✓ Cleanup completed" "Green"
}

# Function to handle errors
function Invoke-ErrorHandler {
    param([string]$ErrorMessage)
    
    Write-ColorOutput "ERROR: $ErrorMessage" "Red"
    Write-ColorOutput "Deployment failed. Rolling back..." "Yellow"
    
    # Stop all services
    docker-compose down --remove-orphans
    
    Write-ColorOutput "Rollback completed" "Yellow"
    exit 1
}

# Main execution
try {
    # Show help if requested
    if ($Help) {
        Show-Help
        exit 0
    }
    
    # Show banner
    Write-ColorOutput "=== $ProjectName Deployment Script ===" "Cyan"
    Write-ColorOutput "Version: $ScriptVersion" "Blue"
    Write-ColorOutput "Environment: $Environment" "Blue"
    Write-ColorOutput "Config File: $ConfigFile" "Blue"
    Write-ColorOutput ""
    
    # Check prerequisites
    Test-Prerequisites
    
    # Validate configuration
    Test-Configuration $ConfigFile
    
    # Show deployment plan
    Write-ColorOutput "Deployment Plan:" "Blue"
    Write-ColorOutput "  1. Run tests" "White"
    Write-ColorOutput "  2. Build Docker images" "White"
    Write-ColorOutput "  3. Deploy services" "White"
    Write-ColorOutput "  4. Verify deployment" "White"
    Write-ColorOutput ""
    
    if (-not $Force -and -not $DryRun) {
        $Confirmation = Read-Host "Do you want to continue? (y/N)"
        if ($Confirmation -ne "y" -and $Confirmation -ne "Y") {
            Write-ColorOutput "Deployment cancelled" "Yellow"
            exit 0
        }
    }
    
    if ($DryRun) {
        Write-ColorOutput "DRY RUN: Would execute the following commands:" "Yellow"
        Write-ColorOutput "  docker-compose build --no-cache" "Cyan"
        Write-ColorOutput "  docker-compose up -d" "Cyan"
        Write-ColorOutput "  docker-compose ps" "Cyan"
        exit 0
    }
    
    # Execute deployment steps
    Invoke-Tests
    Invoke-Build
    Invoke-Deploy $Environment
    
    # Show final status
    Write-ColorOutput ""
    Write-ColorOutput "=== Deployment Complete ===" "Green"
    Show-Status
    
    Write-ColorOutput ""
    Write-ColorOutput "Next steps:" "Blue"
    Write-ColorOutput "  1. Access the UI at http://localhost:3000" "White"
    Write-ColorOutput "  2. Check the API documentation at http://localhost:8000/docs" "White"
    Write-ColorOutput "  3. Monitor services with Grafana at http://localhost:3001" "White"
    Write-ColorOutput "  4. View logs with docker-compose logs -f" "White"
    
} catch {
    Invoke-ErrorHandler $_.Exception.Message
} finally {
    # Cleanup on exit
    if ($LASTEXITCODE -ne 0) {
        Invoke-Cleanup
    }
} 