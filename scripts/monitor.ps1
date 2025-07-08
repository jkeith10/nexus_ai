# Nexus AI Agent Framework - Monitoring Script
# PowerShell script for monitoring system health and performance

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("health", "performance", "logs", "alerts", "all")]
    [string]$Mode = "all",
    
    [Parameter(Mandatory=$false)]
    [int]$Interval = 30,
    
    [Parameter(Mandatory=$false)]
    [switch]$Continuous,
    
    [Parameter(Mandatory=$false)]
    [switch]$Export,
    
    [Parameter(Mandatory=$false)]
    [string]$ExportPath = "monitoring-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').json",
    
    [Parameter(Mandatory=$false)]
    [switch]$Help
)

# Script configuration
$ScriptVersion = "1.0.0"
$ProjectName = "Nexus AI Agent Framework"

# Color codes for output
$Colors = @{
    Red = "Red"
    Green = "Green"
    Yellow = "Yellow"
    Blue = "Blue"
    Cyan = "Cyan"
    White = "White"
    Magenta = "Magenta"
}

# Monitoring thresholds
$Thresholds = @{
    CPU_Warning = 70
    CPU_Critical = 90
    Memory_Warning = 80
    Memory_Critical = 95
    Disk_Warning = 85
    Disk_Critical = 95
    ResponseTime_Warning = 1000
    ResponseTime_Critical = 5000
    ErrorRate_Warning = 5
    ErrorRate_Critical = 10
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
    Write-ColorOutput "=== $ProjectName Monitoring Script ===" "Cyan"
    Write-ColorOutput "Version: $ScriptVersion" "Blue"
    Write-ColorOutput ""
    Write-ColorOutput "Usage:" "Yellow"
    Write-ColorOutput "  .\monitor.ps1 [Options]" "White"
    Write-ColorOutput ""
    Write-ColorOutput "Options:" "Yellow"
    Write-ColorOutput "  -Mode <string>         Monitoring mode (health, performance, logs, alerts, all)" "White"
    Write-ColorOutput "  -Interval <int>        Monitoring interval in seconds (default: 30)" "White"
    Write-ColorOutput "  -Continuous            Run monitoring continuously" "White"
    Write-ColorOutput "  -Export                Export monitoring data to JSON file" "White"
    Write-ColorOutput "  -ExportPath <string>   Export file path" "White"
    Write-ColorOutput "  -Help                  Show this help message" "White"
    Write-ColorOutput ""
    Write-ColorOutput "Examples:" "Yellow"
    Write-ColorOutput "  .\monitor.ps1 -Mode health" "White"
    Write-ColorOutput "  .\monitor.ps1 -Mode all -Continuous -Interval 60" "White"
    Write-ColorOutput "  .\monitor.ps1 -Mode performance -Export" "White"
}

# Function to get service health status
function Get-ServiceHealth {
    $Services = @("nexus-core", "nexus-ai", "nexus-api", "nexus-ui", "nexus-postgres", "nexus-redis")
    $HealthStatus = @{}
    
    foreach ($Service in $Services) {
        try {
            $ContainerStatus = docker-compose ps --format json $Service 2>$null | ConvertFrom-Json
            if ($ContainerStatus.State -eq "running") {
                # Try to get health check endpoint
                $HealthCheck = docker-compose exec -T $Service curl -f http://localhost/health 2>$null
                if ($LASTEXITCODE -eq 0) {
                    $HealthStatus[$Service] = @{
                        Status = "Healthy"
                        State = $ContainerStatus.State
                        Uptime = $ContainerStatus.Uptime
                        Color = "Green"
                    }
                } else {
                    $HealthStatus[$Service] = @{
                        Status = "Running"
                        State = $ContainerStatus.State
                        Uptime = $ContainerStatus.Uptime
                        Color = "Yellow"
                    }
                }
            } else {
                $HealthStatus[$Service] = @{
                    Status = "Stopped"
                    State = $ContainerStatus.State
                    Uptime = "N/A"
                    Color = "Red"
                }
            }
        } catch {
            $HealthStatus[$Service] = @{
                Status = "Unknown"
                State = "Unknown"
                Uptime = "N/A"
                Color = "Red"
            }
        }
    }
    
    return $HealthStatus
}

# Function to get performance metrics
function Get-PerformanceMetrics {
    $Metrics = @{}
    
    try {
        # Get container stats
        $Stats = docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}"
        
        # Parse stats for our services
        $ServiceStats = @{}
        $StatsLines = $Stats -split "`n" | Select-Object -Skip 1
        
        foreach ($Line in $StatsLines) {
            $Parts = $Line -split "\s+"
            if ($Parts.Count -ge 6) {
                $ContainerName = $Parts[0]
                $CPUPercent = [double]($Parts[1] -replace '%', '')
                $MemoryPercent = [double]($Parts[3] -replace '%', '')
                
                $ServiceStats[$ContainerName] = @{
                    CPU = $CPUPercent
                    Memory = $MemoryPercent
                }
            }
        }
        
        $Metrics["ContainerStats"] = $ServiceStats
        
        # Get system resource usage
        $SystemInfo = Get-Counter "\Processor(_Total)\% Processor Time", "\Memory\Available MBytes", "\PhysicalDisk(_Total)\% Disk Time"
        $Metrics["System"] = @{
            CPU = [math]::Round($SystemInfo.CounterSamples[0].CookedValue, 2)
            MemoryAvailable = [math]::Round($SystemInfo.CounterSamples[1].CookedValue, 2)
            DiskUsage = [math]::Round($SystemInfo.CounterSamples[2].CookedValue, 2)
        }
        
        # Get disk usage
        $DiskInfo = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
        $DiskUsage = @{}
        foreach ($Disk in $DiskInfo) {
            $UsagePercent = [math]::Round((($Disk.Size - $Disk.FreeSpace) / $Disk.Size) * 100, 2)
            $DiskUsage[$Disk.DeviceID] = $UsagePercent
        }
        $Metrics["DiskUsage"] = $DiskUsage
        
    } catch {
        Write-ColorOutput "Warning: Could not retrieve performance metrics" "Yellow"
    }
    
    return $Metrics
}

# Function to get recent logs
function Get-RecentLogs {
    param([int]$Lines = 50)
    
    $Logs = @{}
    
    try {
        # Get logs for each service
        $Services = @("nexus-core", "nexus-ai", "nexus-api", "nexus-ui")
        
        foreach ($Service in $Services) {
            try {
                $ServiceLogs = docker-compose logs --tail=$Lines $Service 2>$null
                $Logs[$Service] = $ServiceLogs
            } catch {
                $Logs[$Service] = "No logs available"
            }
        }
        
        # Get error logs specifically
        $ErrorLogs = docker-compose logs --tail=20 2>&1 | Where-Object { $_ -match "ERROR|FATAL|Exception" }
        $Logs["Errors"] = $ErrorLogs
        
    } catch {
        Write-ColorOutput "Warning: Could not retrieve logs" "Yellow"
    }
    
    return $Logs
}

# Function to check for alerts
function Get-Alerts {
    $Alerts = @()
    
    try {
        # Get performance metrics
        $Metrics = Get-PerformanceMetrics
        
        # Check CPU usage
        if ($Metrics.System.CPU -gt $Thresholds.CPU_Critical) {
            $Alerts += @{
                Level = "Critical"
                Service = "System"
                Message = "CPU usage is critically high: $($Metrics.System.CPU)%"
                Color = "Red"
            }
        } elseif ($Metrics.System.CPU -gt $Thresholds.CPU_Warning) {
            $Alerts += @{
                Level = "Warning"
                Service = "System"
                Message = "CPU usage is high: $($Metrics.System.CPU)%"
                Color = "Yellow"
            }
        }
        
        # Check memory usage
        $MemoryUsage = 100 - ($Metrics.System.MemoryAvailable / (Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory * 100)
        if ($MemoryUsage -gt $Thresholds.Memory_Critical) {
            $Alerts += @{
                Level = "Critical"
                Service = "System"
                Message = "Memory usage is critically high: $([math]::Round($MemoryUsage, 2))%"
                Color = "Red"
            }
        } elseif ($MemoryUsage -gt $Thresholds.Memory_Warning) {
            $Alerts += @{
                Level = "Warning"
                Service = "System"
                Message = "Memory usage is high: $([math]::Round($MemoryUsage, 2))%"
                Color = "Yellow"
            }
        }
        
        # Check disk usage
        foreach ($Disk in $Metrics.DiskUsage.Keys) {
            $Usage = $Metrics.DiskUsage[$Disk]
            if ($Usage -gt $Thresholds.Disk_Critical) {
                $Alerts += @{
                    Level = "Critical"
                    Service = "Disk"
                    Message = "Disk $Disk usage is critically high: $Usage%"
                    Color = "Red"
                }
            } elseif ($Usage -gt $Thresholds.Disk_Warning) {
                $Alerts += @{
                    Level = "Warning"
                    Service = "Disk"
                    Message = "Disk $Disk usage is high: $Usage%"
                    Color = "Yellow"
                }
            }
        }
        
        # Check container health
        $HealthStatus = Get-ServiceHealth
        foreach ($Service in $HealthStatus.Keys) {
            if ($HealthStatus[$Service].Status -eq "Stopped") {
                $Alerts += @{
                    Level = "Critical"
                    Service = $Service
                    Message = "Service $Service is stopped"
                    Color = "Red"
                }
            } elseif ($HealthStatus[$Service].Status -eq "Unknown") {
                $Alerts += @{
                    Level = "Warning"
                    Service = $Service
                    Message = "Service $Service status is unknown"
                    Color = "Yellow"
                }
            }
        }
        
    } catch {
        Write-ColorOutput "Warning: Could not check for alerts" "Yellow"
    }
    
    return $Alerts
}

# Function to display health status
function Show-HealthStatus {
    param($HealthStatus)
    
    Write-ColorOutput "=== Service Health Status ===" "Blue"
    Write-ColorOutput ""
    
    foreach ($Service in $HealthStatus.Keys) {
        $Status = $HealthStatus[$Service]
        Write-ColorOutput "$Service`: " -NoNewline
        Write-ColorOutput $Status.Status $Status.Color
        Write-ColorOutput "  State: $($Status.State)" "White"
        Write-ColorOutput "  Uptime: $($Status.Uptime)" "White"
    }
    
    Write-ColorOutput ""
}

# Function to display performance metrics
function Show-PerformanceMetrics {
    param($Metrics)
    
    Write-ColorOutput "=== Performance Metrics ===" "Blue"
    Write-ColorOutput ""
    
    # System metrics
    Write-ColorOutput "System Resources:" "Cyan"
    Write-ColorOutput "  CPU Usage: $($Metrics.System.CPU)%" "White"
    Write-ColorOutput "  Memory Available: $($Metrics.System.MemoryAvailable) MB" "White"
    Write-ColorOutput "  Disk Usage: $($Metrics.System.DiskUsage)%" "White"
    Write-ColorOutput ""
    
    # Container metrics
    Write-ColorOutput "Container Performance:" "Cyan"
    foreach ($Container in $Metrics.ContainerStats.Keys) {
        $Stats = $Metrics.ContainerStats[$Container]
        Write-ColorOutput "  $Container`:" "White"
        Write-ColorOutput "    CPU: $($Stats.CPU)%" "White"
        Write-ColorOutput "    Memory: $($Stats.Memory)%" "White"
    }
    Write-ColorOutput ""
    
    # Disk usage
    Write-ColorOutput "Disk Usage:" "Cyan"
    foreach ($Disk in $Metrics.DiskUsage.Keys) {
        $Usage = $Metrics.DiskUsage[$Disk]
        $Color = if ($Usage -gt $Thresholds.Disk_Critical) { "Red" } elseif ($Usage -gt $Thresholds.Disk_Warning) { "Yellow" } else { "Green" }
        Write-ColorOutput "  $Disk`: $Usage%" $Color
    }
    Write-ColorOutput ""
}

# Function to display logs
function Show-Logs {
    param($Logs)
    
    Write-ColorOutput "=== Recent Logs ===" "Blue"
    Write-ColorOutput ""
    
            # Show error logs first
        if ($Logs.Errors -and $Logs.Errors.Count -gt 0) {
            Write-ColorOutput "Recent Errors:" "Red"
            foreach ($ErrorLog in $Logs.Errors) {
                Write-ColorOutput "  $ErrorLog" "Red"
            }
            Write-ColorOutput ""
        }
    
    # Show service logs
    foreach ($Service in $Logs.Keys) {
        if ($Service -ne "Errors") {
            Write-ColorOutput "$Service Logs:" "Cyan"
            $ServiceLogs = $Logs[$Service]
            if ($ServiceLogs -is [array]) {
                foreach ($Log in $ServiceLogs[-5..-1]) {
                    Write-ColorOutput "  $Log" "White"
                }
            } else {
                Write-ColorOutput "  $ServiceLogs" "White"
            }
            Write-ColorOutput ""
        }
    }
}

# Function to display alerts
function Show-Alerts {
    param($Alerts)
    
    Write-ColorOutput "=== Alerts ===" "Blue"
    Write-ColorOutput ""
    
    if ($Alerts.Count -eq 0) {
        Write-ColorOutput "No alerts at this time" "Green"
    } else {
        foreach ($Alert in $Alerts) {
            Write-ColorOutput "[$($Alert.Level)] $($Alert.Service): $($Alert.Message)" $Alert.Color
        }
    }
    
    Write-ColorOutput ""
}

# Function to export monitoring data
function Export-MonitoringData {
    param(
        $HealthStatus,
        $Metrics,
        $Logs,
        $Alerts,
        [string]$FilePath
    )
    
    $ExportData = @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        HealthStatus = $HealthStatus
        PerformanceMetrics = $Metrics
        Alerts = $Alerts
        Logs = $Logs
    }
    
    try {
        $ExportData | ConvertTo-Json -Depth 10 | Out-File -FilePath $FilePath -Encoding UTF8
        Write-ColorOutput "Monitoring data exported to: $FilePath" "Green"
    } catch {
        Write-ColorOutput "Error exporting monitoring data: $($_.Exception.Message)" "Red"
    }
}

# Function to run monitoring cycle
function Invoke-MonitoringCycle {
    param([string]$Mode)
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-ColorOutput "=== Monitoring Cycle - $Timestamp ===" "Magenta"
    Write-ColorOutput ""
    
    $MonitoringData = @{}
    
    if ($Mode -eq "all" -or $Mode -eq "health") {
        $HealthStatus = Get-ServiceHealth
        $MonitoringData["HealthStatus"] = $HealthStatus
        Show-HealthStatus $HealthStatus
    }
    
    if ($Mode -eq "all" -or $Mode -eq "performance") {
        $Metrics = Get-PerformanceMetrics
        $MonitoringData["PerformanceMetrics"] = $Metrics
        Show-PerformanceMetrics $Metrics
    }
    
    if ($Mode -eq "all" -or $Mode -eq "logs") {
        $Logs = Get-RecentLogs
        $MonitoringData["Logs"] = $Logs
        Show-Logs $Logs
    }
    
    if ($Mode -eq "all" -or $Mode -eq "alerts") {
        $Alerts = Get-Alerts
        $MonitoringData["Alerts"] = $Alerts
        Show-Alerts $Alerts
    }
    
    return $MonitoringData
}

# Main execution
try {
    # Show help if requested
    if ($Help) {
        Show-Help
        exit 0
    }
    
    # Show banner
    Write-ColorOutput "=== $ProjectName Monitoring Script ===" "Cyan"
    Write-ColorOutput "Version: $ScriptVersion" "Blue"
    Write-ColorOutput "Mode: $Mode" "Blue"
    Write-ColorOutput "Interval: $Interval seconds" "Blue"
    Write-ColorOutput ""
    
    # Check if Docker Compose is available
    if (-not (Test-Path "docker-compose.yml")) {
        Write-ColorOutput "ERROR: docker-compose.yml not found. Please run this script from the project root." "Red"
        exit 1
    }
    
    # Run monitoring
    if ($Continuous) {
        Write-ColorOutput "Starting continuous monitoring..." "Blue"
        Write-ColorOutput "Press Ctrl+C to stop" "Yellow"
        Write-ColorOutput ""
        
        while ($true) {
            $MonitoringData = Invoke-MonitoringCycle $Mode
            
            if ($Export) {
                Export-MonitoringData $MonitoringData.HealthStatus $MonitoringData.PerformanceMetrics $MonitoringData.Logs $MonitoringData.Alerts $ExportPath
            }
            
            Start-Sleep -Seconds $Interval
            Clear-Host
        }
    } else {
        $MonitoringData = Invoke-MonitoringCycle $Mode
        
        if ($Export) {
            Export-MonitoringData $MonitoringData.HealthStatus $MonitoringData.PerformanceMetrics $MonitoringData.Logs $MonitoringData.Alerts $ExportPath
        }
    }
    
} catch {
    Write-ColorOutput "ERROR: $($_.Exception.Message)" "Red"
    exit 1
} 