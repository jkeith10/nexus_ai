#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Comprehensive test suite for Nexus AI Agent Framework

.DESCRIPTION
    Runs all tests across Python, Rust, and TypeScript components with coverage reporting.

.PARAMETER Component
    Specific component to test: "python", "rust", "typescript", "all" (default)

.PARAMETER Coverage
    Generate coverage reports (default: true)

.PARAMETER Verbose
    Enable verbose output (default: false)

.PARAMETER Parallel
    Run tests in parallel (default: false)

.EXAMPLE
    .\scripts\test.ps1
    .\scripts\test.ps1 -Component python -Coverage
    .\scripts\test.ps1 -Component all -Verbose -Parallel
#>

param(
    [Parameter(Position=0)]
    [ValidateSet("python", "rust", "typescript", "all")]
    [string]$Component = "all",
    
    [Parameter()]
    [bool]$Coverage = $true,
    
    [Parameter()]
    [bool]$Verbose = $false,
    
    [Parameter()]
    [bool]$Parallel = $false
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Reset = "`e[0m"
$Bold = "`e[1m"

# Test results tracking
$TestResults = @{
    Python = $false
    Rust = $false
    TypeScript = $false
    Integration = $false
}

# Function to write colored output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = $Reset
    )
    Write-Host "$Color$Message$Reset"
}

# Function to check if command exists
function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Function to run Python tests
function Test-Python {
    Write-ColorOutput "`n$Bold🐍 Running Python Tests$Reset" $Blue
    
    if (-not (Test-Command "python")) {
        Write-ColorOutput "❌ Python not found" $Red
        return $false
    }
    
    try {
        # Install test dependencies
        Write-ColorOutput "📦 Installing Python test dependencies..." $Yellow
        pip install pytest pytest-cov pytest-asyncio pytest-mock black flake8 mypy
        
        # Run linting
        Write-ColorOutput "🔍 Running Python linting..." $Yellow
        if ($Verbose) {
            flake8 ai/ api/ --max-line-length=100 --ignore=E203,W503
            mypy ai/ api/ --ignore-missing-imports
        } else {
            flake8 ai/ api/ --max-line-length=100 --ignore=E203,W503 --quiet
            mypy ai/ api/ --ignore-missing-imports --quiet
        }
        
        # Run tests for AI module
        Write-ColorOutput "🧪 Testing AI module..." $Yellow
        $aiArgs = @("python", "-m", "pytest", "ai/tests/", "-v")
        if ($Coverage) {
            $aiArgs += @("--cov=ai", "--cov-report=html", "--cov-report=term")
        }
        if (-not $Verbose) {
            $aiArgs += @("--tb=short")
        }
        & $aiArgs[0] $aiArgs[1..($aiArgs.Length-1)]
        
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "❌ AI module tests failed" $Red
            return $false
        }
        
        # Run tests for API module
        Write-ColorOutput "🧪 Testing API module..." $Yellow
        $apiArgs = @("python", "-m", "pytest", "api/tests/", "-v")
        if ($Coverage) {
            $apiArgs += @("--cov=api", "--cov-report=html", "--cov-report=term")
        }
        if (-not $Verbose) {
            $apiArgs += @("--tb=short")
        }
        & $apiArgs[0] $apiArgs[1..($apiArgs.Length-1)]
        
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "❌ API module tests failed" $Red
            return $false
        }
        
        Write-ColorOutput "✅ Python tests completed successfully" $Green
        return $true
    }
    catch {
        Write-ColorOutput "❌ Python tests failed: $($_.Exception.Message)" $Red
        return $false
    }
}

# Function to run Rust tests
function Test-Rust {
    Write-ColorOutput "`n$Bold🦀 Running Rust Tests$Reset" $Blue
    
    if (-not (Test-Command "cargo")) {
        Write-ColorOutput "❌ Rust/Cargo not found" $Red
        return $false
    }
    
    try {
        Push-Location "core"
        
        # Run clippy (linting)
        Write-ColorOutput "🔍 Running Rust linting..." $Yellow
        if ($Verbose) {
            cargo clippy -- -D warnings
        } else {
            cargo clippy -- -D warnings --quiet
        }
        
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "❌ Rust linting failed" $Red
            return $false
        }
        
        # Check formatting
        Write-ColorOutput "🎨 Checking code formatting..." $Yellow
        cargo fmt -- --check
        
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "❌ Rust formatting check failed" $Red
            return $false
        }
        
        # Run tests
        Write-ColorOutput "🧪 Running Rust tests..." $Yellow
        $testArgs = @("cargo", "test")
        if ($Verbose) {
            $testArgs += @("--verbose")
        }
        & $testArgs[0] $testArgs[1..($testArgs.Length-1)]
        
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "❌ Rust tests failed" $Red
            return $false
        }
        
        # Run coverage if requested
        if ($Coverage) {
            Write-ColorOutput "📊 Generating Rust coverage..." $Yellow
            if (Test-Command "cargo-tarpaulin") {
                cargo tarpaulin --out Html --out Xml
            } else {
                Write-ColorOutput "⚠️  cargo-tarpaulin not installed, skipping coverage" $Yellow
            }
        }
        
        Pop-Location
        Write-ColorOutput "✅ Rust tests completed successfully" $Green
        return $true
    }
    catch {
        Pop-Location
        Write-ColorOutput "❌ Rust tests failed: $($_.Exception.Message)" $Red
        return $false
    }
}

# Function to run TypeScript tests
function Test-TypeScript {
    Write-ColorOutput "`n$Bold⚛️  Running TypeScript Tests$Reset" $Blue
    
    if (-not (Test-Command "npm")) {
        Write-ColorOutput "❌ Node.js/npm not found" $Red
        return $false
    }
    
    try {
        Push-Location "ui"
        
        # Install dependencies if needed
        if (-not (Test-Path "node_modules")) {
            Write-ColorOutput "📦 Installing Node.js dependencies..." $Yellow
            npm ci
        }
        
        # Run linting
        Write-ColorOutput "🔍 Running TypeScript linting..." $Yellow
        if ($Verbose) {
            npm run lint
        } else {
            npm run lint --silent
        }
        
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "❌ TypeScript linting failed" $Red
            return $false
        }
        
        # Type checking
        Write-ColorOutput "🔍 Running type checking..." $Yellow
        npm run type-check
        
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "❌ TypeScript type checking failed" $Red
            return $false
        }
        
        # Run tests
        Write-ColorOutput "🧪 Running TypeScript tests..." $Yellow
        $testArgs = @("npm", "test")
        if (-not $Verbose) {
            $testArgs += @("--silent")
        }
        & $testArgs[0] $testArgs[1..($testArgs.Length-1)]
        
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "❌ TypeScript tests failed" $Red
            return $false
        }
        
        # Run coverage if requested
        if ($Coverage) {
            Write-ColorOutput "📊 Generating TypeScript coverage..." $Yellow
            npm run test:coverage
        }
        
        Pop-Location
        Write-ColorOutput "✅ TypeScript tests completed successfully" $Green
        return $true
    }
    catch {
        Pop-Location
        Write-ColorOutput "❌ TypeScript tests failed: $($_.Exception.Message)" $Red
        return $false
    }
}

# Function to run integration tests
function Test-Integration {
    Write-ColorOutput "`n$Bold🔗 Running Integration Tests$Reset" $Blue
    
    try {
        # Check if Docker is running
        if (-not (Test-Command "docker")) {
            Write-ColorOutput "❌ Docker not found" $Red
            return $false
        }
        
        # Start services for integration testing
        Write-ColorOutput "🚀 Starting services for integration testing..." $Yellow
        docker-compose up -d postgres redis
        
        # Wait for services to be ready
        Write-ColorOutput "⏳ Waiting for services to be ready..." $Yellow
        Start-Sleep -Seconds 10
        
        # Run integration tests
        Write-ColorOutput "🧪 Running integration tests..." $Yellow
        $integrationArgs = @("python", "-m", "pytest", "tests/integration/", "-v")
        if (-not $Verbose) {
            $integrationArgs += @("--tb=short")
        }
        & $integrationArgs[0] $integrationArgs[1..($integrationArgs.Length-1)]
        
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "❌ Integration tests failed" $Red
            return $false
        }
        
        # Cleanup
        docker-compose down
        
        Write-ColorOutput "✅ Integration tests completed successfully" $Green
        return $true
    }
    catch {
        Write-ColorOutput "❌ Integration tests failed: $($_.Exception.Message)" $Red
        return $false
    }
}

# Function to generate test report
function Write-TestReport {
    Write-ColorOutput "`n$Bold📊 Test Report$Reset" $Blue
    Write-ColorOutput "================================" $Blue
    
    $allPassed = $true
    
    foreach ($component in $TestResults.Keys) {
        $status = if ($TestResults[$component]) { "✅ PASS" } else { "❌ FAIL" }
        $color = if ($TestResults[$component]) { $Green } else { $Red; $allPassed = $false }
        Write-ColorOutput "$component`: $status" $color
    }
    
    Write-ColorOutput "================================" $Blue
    
    if ($allPassed) {
        Write-ColorOutput "🎉 All tests passed!" $Green
        exit 0
    } else {
        Write-ColorOutput "💥 Some tests failed!" $Red
        exit 1
    }
}

# Main execution
Write-ColorOutput "$Bold🧪 Nexus AI Agent Framework - Test Suite$Reset" $Blue
Write-ColorOutput "Component: $Component" $Yellow
Write-ColorOutput "Coverage: $Coverage" $Yellow
Write-ColorOutput "Verbose: $Verbose" $Yellow
Write-ColorOutput "Parallel: $Parallel" $Yellow

# Check prerequisites
Write-ColorOutput "`n🔍 Checking prerequisites..." $Yellow
$prerequisites = @{
    "Python" = Test-Command "python"
    "Rust" = Test-Command "cargo"
    "Node.js" = Test-Command "npm"
    "Docker" = Test-Command "docker"
}

foreach ($prereq in $prerequisites.Keys) {
    $status = if ($prerequisites[$prereq]) { "✅" } else { "❌" }
    Write-ColorOutput "$prereq`: $status" $(if ($prerequisites[$prereq]) { $Green } else { $Red })
}

# Run tests based on component selection
switch ($Component) {
    "python" {
        $TestResults.Python = Test-Python
    }
    "rust" {
        $TestResults.Rust = Test-Rust
    }
    "typescript" {
        $TestResults.TypeScript = Test-TypeScript
    }
    "all" {
        if ($Parallel) {
            # Run tests in parallel (simplified version)
            $TestResults.Python = Test-Python
            $TestResults.Rust = Test-Rust
            $TestResults.TypeScript = Test-TypeScript
        } else {
            # Run tests sequentially
            $TestResults.Python = Test-Python
            $TestResults.Rust = Test-Rust
            $TestResults.TypeScript = Test-TypeScript
        }
        
        # Integration tests only for "all"
        $TestResults.Integration = Test-Integration
    }
}

# Generate report
Write-TestReport 