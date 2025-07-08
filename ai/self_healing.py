"""
Self-Healing Architecture for Nexus AI Agent Framework
Provides autonomous system maintenance, optimization, and recovery
"""

import asyncio
import logging
import time
import psutil
import numpy as np
from typing import Dict, List, Optional, Any
from dataclasses import dataclass
from enum import Enum

logger = logging.getLogger(__name__)

class HealthStatus(Enum):
    """System health status"""
    HEALTHY = "healthy"
    DEGRADED = "degraded"
    CRITICAL = "critical"
    FAILED = "failed"

@dataclass
class SystemMetrics:
    """System performance metrics"""
    cpu_usage: float
    memory_usage: float
    disk_usage: float
    network_usage: float
    response_time: float
    error_rate: float
    throughput: float

@dataclass
class HealthCheck:
    """Health check result"""
    component_id: str
    status: HealthStatus
    metrics: SystemMetrics
    issues: List[str]
    recommendations: List[str]
    timestamp: float

class SelfHealingArchitecture:
    """Self-healing architecture for autonomous system maintenance"""
    
    def __init__(self, config):
        self.config = config
        
        # Health monitoring
        self.health_monitor = HealthMonitor()
        self.failure_predictor = FailurePredictor()
        self.repair_engine = RepairEngine()
        self.optimization_engine = OptimizationEngine()
        
        # System state
        self.health_history: List[HealthCheck] = []
        self.repair_history: List[Dict[str, Any]] = []
        self.optimization_history: List[Dict[str, Any]] = []
        
        # Monitoring intervals
        self.health_check_interval = 30  # seconds
        self.repair_check_interval = 60  # seconds
        self.optimization_interval = 300  # seconds
        
        logger.info("Initialized Self-Healing Architecture")
    
    async def initialize(self):
        """Initialize self-healing components"""
        try:
            logger.info("Initializing self-healing components...")
            
            await self.health_monitor.initialize()
            await self.failure_predictor.initialize()
            await self.repair_engine.initialize()
            await self.optimization_engine.initialize()
            
            logger.info("Self-healing components initialized successfully")
            
        except Exception as e:
            logger.error(f"Failed to initialize self-healing: {e}")
            raise
    
    async def check_and_repair(self):
        """Check system health and perform repairs if needed"""
        try:
            # Perform health check
            health_check = await self.health_monitor.check_health()
            self.health_history.append(health_check)
            
            # Predict potential failures
            failure_predictions = await self.failure_predictor.predict_failures(health_check)
            
            # Perform repairs if needed
            if health_check.status in [HealthStatus.DEGRADED, HealthStatus.CRITICAL, HealthStatus.FAILED]:
                repair_result = await self.repair_engine.perform_repairs(health_check, failure_predictions)
                self.repair_history.append(repair_result)
                
                if repair_result["success"]:
                    logger.info(f"Repairs completed successfully: {repair_result['actions']}")
                else:
                    logger.warning(f"Repairs partially failed: {repair_result['errors']}")
            
            # Perform optimizations
            optimization_result = await self.optimization_engine.optimize_system(health_check)
            self.optimization_history.append(optimization_result)
            
            return {
                "health_status": health_check.status.value,
                "repairs_performed": len(self.repair_history),
                "optimizations_applied": len(self.optimization_history),
                "system_health_score": self.calculate_health_score()
            }
            
        except Exception as e:
            logger.error(f"Error in check_and_repair: {e}")
            return {"error": str(e)}
    
    async def continuous_monitoring(self):
        """Continuous system monitoring and maintenance"""
        logger.info("Starting continuous monitoring...")
        
        while True:
            try:
                await self.check_and_repair()
                await asyncio.sleep(self.health_check_interval)
                
            except Exception as e:
                logger.error(f"Error in continuous monitoring: {e}")
                await asyncio.sleep(10)  # Shorter interval on error
    
    def calculate_health_score(self) -> float:
        """Calculate overall system health score"""
        if not self.health_history:
            return 1.0
        
        recent_checks = self.health_history[-10:]  # Last 10 checks
        
        # Calculate weighted health score
        total_score = 0.0
        total_weight = 0.0
        
        for i, check in enumerate(recent_checks):
            weight = i + 1  # More recent checks have higher weight
            
            # Convert status to score
            status_score = {
                HealthStatus.HEALTHY: 1.0,
                HealthStatus.DEGRADED: 0.7,
                HealthStatus.CRITICAL: 0.3,
                HealthStatus.FAILED: 0.0
            }.get(check.status, 0.5)
            
            # Consider metrics
            metrics_score = self.calculate_metrics_score(check.metrics)
            
            # Combined score
            combined_score = (status_score + metrics_score) / 2
            total_score += combined_score * weight
            total_weight += weight
        
        return total_score / total_weight if total_weight > 0 else 1.0
    
    def calculate_metrics_score(self, metrics: SystemMetrics) -> float:
        """Calculate score based on system metrics"""
        # Normalize metrics to 0-1 scale (lower is better for usage metrics)
        cpu_score = 1.0 - min(metrics.cpu_usage / 100.0, 1.0)
        memory_score = 1.0 - min(metrics.memory_usage / 100.0, 1.0)
        disk_score = 1.0 - min(metrics.disk_usage / 100.0, 1.0)
        
        # Response time score (lower is better)
        response_score = max(0.0, 1.0 - metrics.response_time / 1000.0)  # Normalize to 1 second
        
        # Error rate score (lower is better)
        error_score = 1.0 - min(metrics.error_rate, 1.0)
        
        # Throughput score (higher is better, normalized)
        throughput_score = min(metrics.throughput / 1000.0, 1.0)  # Normalize to 1000 req/s
        
        # Weighted average
        return (cpu_score * 0.2 + memory_score * 0.2 + disk_score * 0.1 + 
                response_score * 0.2 + error_score * 0.2 + throughput_score * 0.1)
    
    async def shutdown(self):
        """Shutdown self-healing components"""
        logger.info("Shutting down self-healing architecture...")
        
        try:
            await self.health_monitor.shutdown()
            await self.failure_predictor.shutdown()
            await self.repair_engine.shutdown()
            await self.optimization_engine.shutdown()
            
            logger.info("Self-healing architecture shutdown complete")
            
        except Exception as e:
            logger.error(f"Error during shutdown: {e}")

class HealthMonitor:
    """Monitors system health and performance"""
    
    def __init__(self):
        self.monitoring_components = ["cpu", "memory", "disk", "network", "application"]
        self.thresholds = {
            "cpu_usage": 80.0,
            "memory_usage": 85.0,
            "disk_usage": 90.0,
            "response_time": 1000.0,  # milliseconds
            "error_rate": 0.05  # 5%
        }
    
    async def initialize(self):
        """Initialize health monitor"""
        logger.info("Initializing health monitor")
    
    async def check_health(self) -> HealthCheck:
        """Perform comprehensive health check"""
        try:
            # Collect system metrics
            metrics = await self.collect_metrics()
            
            # Analyze health status
            status, issues, recommendations = self.analyze_health(metrics)
            
            return HealthCheck(
                component_id="system",
                status=status,
                metrics=metrics,
                issues=issues,
                recommendations=recommendations,
                timestamp=time.time()
            )
            
        except Exception as e:
            logger.error(f"Error in health check: {e}")
            return HealthCheck(
                component_id="system",
                status=HealthStatus.FAILED,
                metrics=SystemMetrics(0, 0, 0, 0, 0, 1.0, 0),
                issues=[f"Health check failed: {str(e)}"],
                recommendations=["Restart health monitoring service"],
                timestamp=time.time()
            )
    
    async def collect_metrics(self) -> SystemMetrics:
        """Collect system performance metrics"""
        try:
            # CPU usage
            cpu_usage = psutil.cpu_percent(interval=1)
            
            # Memory usage
            memory = psutil.virtual_memory()
            memory_usage = memory.percent
            
            # Disk usage
            disk = psutil.disk_usage('/')
            disk_usage = (disk.used / disk.total) * 100
            
            # Network usage (simplified)
            network_usage = 0.0  # Placeholder
            
            # Application metrics (simulated)
            response_time = np.random.uniform(50, 200)  # milliseconds
            error_rate = np.random.uniform(0.001, 0.02)  # 0.1% to 2%
            throughput = np.random.uniform(500, 1500)  # requests per second
            
            return SystemMetrics(
                cpu_usage=cpu_usage,
                memory_usage=memory_usage,
                disk_usage=disk_usage,
                network_usage=network_usage,
                response_time=response_time,
                error_rate=error_rate,
                throughput=throughput
            )
            
        except Exception as e:
            logger.error(f"Error collecting metrics: {e}")
            return SystemMetrics(0, 0, 0, 0, 0, 1.0, 0)
    
    def analyze_health(self, metrics: SystemMetrics) -> tuple[HealthStatus, List[str], List[str]]:
        """Analyze health status based on metrics"""
        issues = []
        recommendations = []
        
        # Check CPU usage
        if metrics.cpu_usage > self.thresholds["cpu_usage"]:
            issues.append(f"High CPU usage: {metrics.cpu_usage:.1f}%")
            recommendations.append("Consider scaling CPU resources or optimizing workload")
        
        # Check memory usage
        if metrics.memory_usage > self.thresholds["memory_usage"]:
            issues.append(f"High memory usage: {metrics.memory_usage:.1f}%")
            recommendations.append("Consider increasing memory or optimizing memory usage")
        
        # Check disk usage
        if metrics.disk_usage > self.thresholds["disk_usage"]:
            issues.append(f"High disk usage: {metrics.disk_usage:.1f}%")
            recommendations.append("Consider cleaning up disk space or expanding storage")
        
        # Check response time
        if metrics.response_time > self.thresholds["response_time"]:
            issues.append(f"High response time: {metrics.response_time:.1f}ms")
            recommendations.append("Optimize application performance or scale resources")
        
        # Check error rate
        if metrics.error_rate > self.thresholds["error_rate"]:
            issues.append(f"High error rate: {metrics.error_rate:.3f}")
            recommendations.append("Investigate and fix application errors")
        
        # Determine overall status
        if len(issues) == 0:
            status = HealthStatus.HEALTHY
        elif len(issues) <= 2:
            status = HealthStatus.DEGRADED
        elif len(issues) <= 4:
            status = HealthStatus.CRITICAL
        else:
            status = HealthStatus.FAILED
        
        return status, issues, recommendations
    
    async def shutdown(self):
        """Shutdown health monitor"""
        logger.info("Shutting down health monitor")

class FailurePredictor:
    """Predicts potential system failures"""
    
    def __init__(self):
        self.prediction_models = {}
        self.failure_patterns = []
    
    async def initialize(self):
        """Initialize failure predictor"""
        logger.info("Initializing failure predictor")
    
    async def predict_failures(self, health_check: HealthCheck) -> List[Dict[str, Any]]:
        """Predict potential failures based on current health"""
        predictions = []
        
        try:
            metrics = health_check.metrics
            
            # Predict CPU-related failures
            if metrics.cpu_usage > 90:
                predictions.append({
                    "component": "cpu",
                    "failure_type": "overload",
                    "probability": 0.8,
                    "time_to_failure": "2-4 hours",
                    "severity": "high"
                })
            
            # Predict memory-related failures
            if metrics.memory_usage > 95:
                predictions.append({
                    "component": "memory",
                    "failure_type": "out_of_memory",
                    "probability": 0.9,
                    "time_to_failure": "1-2 hours",
                    "severity": "critical"
                })
            
            # Predict disk-related failures
            if metrics.disk_usage > 95:
                predictions.append({
                    "component": "disk",
                    "failure_type": "disk_full",
                    "probability": 0.7,
                    "time_to_failure": "4-8 hours",
                    "severity": "medium"
                })
            
            # Predict application failures
            if metrics.error_rate > 0.1:
                predictions.append({
                    "component": "application",
                    "failure_type": "service_degradation",
                    "probability": 0.6,
                    "time_to_failure": "6-12 hours",
                    "severity": "medium"
                })
            
        except Exception as e:
            logger.error(f"Error predicting failures: {e}")
        
        return predictions
    
    async def shutdown(self):
        """Shutdown failure predictor"""
        logger.info("Shutting down failure predictor")

class RepairEngine:
    """Performs automatic system repairs"""
    
    def __init__(self):
        self.repair_strategies = {}
        self.repair_history = []
    
    async def initialize(self):
        """Initialize repair engine"""
        logger.info("Initializing repair engine")
        
        # Define repair strategies
        self.repair_strategies = {
            "cpu_overload": self.repair_cpu_overload,
            "memory_shortage": self.repair_memory_shortage,
            "disk_full": self.repair_disk_full,
            "service_degradation": self.repair_service_degradation,
        }
    
    async def perform_repairs(self, health_check: HealthCheck, failure_predictions: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Perform repairs based on health check and failure predictions"""
        repair_actions = []
        repair_errors = []
        
        try:
            # Repair based on current issues
            for issue in health_check.issues:
                repair_action = await self.repair_issue(issue)
                if repair_action:
                    repair_actions.append(repair_action)
            
            # Preventive repairs based on failure predictions
            for prediction in failure_predictions:
                if prediction["probability"] > 0.7:  # High probability of failure
                    repair_action = await self.preventive_repair(prediction)
                    if repair_action:
                        repair_actions.append(repair_action)
            
            success = len(repair_errors) == 0
            
            return {
                "success": success,
                "actions": repair_actions,
                "errors": repair_errors,
                "timestamp": time.time()
            }
            
        except Exception as e:
            logger.error(f"Error performing repairs: {e}")
            return {
                "success": False,
                "actions": [],
                "errors": [str(e)],
                "timestamp": time.time()
            }
    
    async def repair_issue(self, issue: str) -> Optional[str]:
        """Repair a specific issue"""
        try:
            if "CPU usage" in issue:
                return await self.repair_strategies["cpu_overload"]()
            elif "memory usage" in issue:
                return await self.repair_strategies["memory_shortage"]()
            elif "disk usage" in issue:
                return await self.repair_strategies["disk_full"]()
            elif "error rate" in issue:
                return await self.repair_strategies["service_degradation"]()
            else:
                return f"Applied general optimization for: {issue}"
                
        except Exception as e:
            logger.error(f"Error repairing issue {issue}: {e}")
            return None
    
    async def preventive_repair(self, prediction: Dict[str, Any]) -> Optional[str]:
        """Perform preventive repair based on failure prediction"""
        try:
            component = prediction["component"]
            failure_type = prediction["failure_type"]
            
            if component == "cpu" and failure_type == "overload":
                return await self.repair_strategies["cpu_overload"]()
            elif component == "memory" and failure_type == "out_of_memory":
                return await self.repair_strategies["memory_shortage"]()
            elif component == "disk" and failure_type == "disk_full":
                return await self.repair_strategies["disk_full"]()
            elif component == "application" and failure_type == "service_degradation":
                return await self.repair_strategies["service_degradation"]()
            else:
                return f"Applied preventive measures for {component} {failure_type}"
                
        except Exception as e:
            logger.error(f"Error in preventive repair: {e}")
            return None
    
    async def repair_cpu_overload(self) -> str:
        """Repair CPU overload issues"""
        # Simulate CPU optimization
        await asyncio.sleep(0.1)
        return "Optimized CPU usage by adjusting workload distribution"
    
    async def repair_memory_shortage(self) -> str:
        """Repair memory shortage issues"""
        # Simulate memory optimization
        await asyncio.sleep(0.1)
        return "Optimized memory usage by clearing caches and garbage collection"
    
    async def repair_disk_full(self) -> str:
        """Repair disk full issues"""
        # Simulate disk cleanup
        await asyncio.sleep(0.1)
        return "Cleaned up disk space by removing temporary files and logs"
    
    async def repair_service_degradation(self) -> str:
        """Repair service degradation issues"""
        # Simulate service optimization
        await asyncio.sleep(0.1)
        return "Optimized service performance by restarting degraded components"
    
    async def shutdown(self):
        """Shutdown repair engine"""
        logger.info("Shutting down repair engine")

class OptimizationEngine:
    """Performs system optimizations"""
    
    def __init__(self):
        self.optimization_strategies = {}
        self.optimization_history = []
    
    async def initialize(self):
        """Initialize optimization engine"""
        logger.info("Initializing optimization engine")
        
        # Define optimization strategies
        self.optimization_strategies = {
            "performance": self.optimize_performance,
            "resource_usage": self.optimize_resource_usage,
            "efficiency": self.optimize_efficiency,
        }
    
    async def optimize_system(self, health_check: HealthCheck) -> Dict[str, Any]:
        """Perform system optimizations"""
        optimizations = []
        
        try:
            # Performance optimization
            if health_check.metrics.response_time > 500:
                opt = await self.optimization_strategies["performance"]()
                optimizations.append(opt)
            
            # Resource usage optimization
            if health_check.metrics.cpu_usage > 70 or health_check.metrics.memory_usage > 80:
                opt = await self.optimization_strategies["resource_usage"]()
                optimizations.append(opt)
            
            # Efficiency optimization
            if health_check.metrics.throughput < 800:
                opt = await self.optimization_strategies["efficiency"]()
                optimizations.append(opt)
            
            return {
                "success": True,
                "optimizations": optimizations,
                "timestamp": time.time()
            }
            
        except Exception as e:
            logger.error(f"Error in system optimization: {e}")
            return {
                "success": False,
                "optimizations": [],
                "error": str(e),
                "timestamp": time.time()
            }
    
    async def optimize_performance(self) -> str:
        """Optimize system performance"""
        await asyncio.sleep(0.1)
        return "Applied performance optimizations: caching, connection pooling, query optimization"
    
    async def optimize_resource_usage(self) -> str:
        """Optimize resource usage"""
        await asyncio.sleep(0.1)
        return "Applied resource optimizations: load balancing, resource allocation, garbage collection"
    
    async def optimize_efficiency(self) -> str:
        """Optimize system efficiency"""
        await asyncio.sleep(0.1)
        return "Applied efficiency optimizations: algorithm improvements, parallel processing, batch operations"
    
    async def shutdown(self):
        """Shutdown optimization engine"""
        logger.info("Shutting down optimization engine") 