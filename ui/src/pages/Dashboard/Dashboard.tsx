import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { 
  Brain, 
  Zap, 
  Users, 
  TrendingUp, 
  Activity, 
  Shield, 
  Cpu, 
  Database,
  ArrowRight,
  Play,
  BookOpen,
  MessageSquare
} from 'lucide-react';
import { useQuery } from 'react-query';
import { useNavigate } from 'react-router-dom';

// Components
import MetricCard from '../../components/Dashboard/MetricCard';
import QuickActionCard from '../../components/Dashboard/QuickActionCard';
import SystemStatusWidget from '../../components/Dashboard/SystemStatusWidget';
import RecentActivityWidget from '../../components/Dashboard/RecentActivityWidget';
import PerformanceChart from '../../components/Dashboard/PerformanceChart';

// Services
import { dashboardService } from '../../services/dashboardService';
import { systemService } from '../../services/systemService';

// Types
import { DashboardMetrics, SystemStatus, RecentActivity } from '../../types/dashboard';

// Styles
import './Dashboard.css';

const Dashboard: React.FC = () => {
  const navigate = useNavigate();
  const [refreshInterval, setRefreshInterval] = useState(30000); // 30 seconds

  // Fetch dashboard data
  const { data: metrics, isLoading: metricsLoading } = useQuery<DashboardMetrics>(
    'dashboard-metrics',
    dashboardService.getMetrics,
    {
      refetchInterval: refreshInterval,
      staleTime: 10000,
    }
  );

  // Fetch system status
  const { data: systemStatus, isLoading: statusLoading } = useQuery<SystemStatus>(
    'system-status',
    systemService.getStatus,
    {
      refetchInterval: refreshInterval,
      staleTime: 5000,
    }
  );

  // Fetch recent activity
  const { data: recentActivity, isLoading: activityLoading } = useQuery<RecentActivity[]>(
    'recent-activity',
    dashboardService.getRecentActivity,
    {
      refetchInterval: refreshInterval * 2,
      staleTime: 30000,
    }
  );

  const quickActions = [
    {
      id: 'decisions',
      title: 'Make Decision',
      description: 'Use quantum-inspired decision making',
      icon: Brain,
      color: 'blue',
      action: () => navigate('/decisions'),
    },
    {
      id: 'learning',
      title: 'Learning Center',
      description: 'Explore AI learning capabilities',
      icon: BookOpen,
      color: 'green',
      action: () => navigate('/learning'),
    },
    {
      id: 'collaborative',
      title: 'Collaborative Workspace',
      description: 'Work together with AI agents',
      icon: Users,
      color: 'purple',
      action: () => navigate('/collaborative'),
    },
    {
      id: 'monitor',
      title: 'System Monitor',
      description: 'Monitor system performance',
      icon: Activity,
      color: 'orange',
      action: () => navigate('/monitor'),
    },
  ];

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        duration: 0.5,
        staggerChildren: 0.1,
      },
    },
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: {
        duration: 0.5,
      },
    },
  };

  if (metricsLoading || statusLoading || activityLoading) {
    return (
      <div className="dashboard-loading">
        <div className="loading-spinner" />
        <p>Loading dashboard...</p>
      </div>
    );
  }

  return (
    <div className="dashboard">
      <motion.div
        className="dashboard-header"
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
      >
        <div className="dashboard-title">
          <h1>Nexus AI Dashboard</h1>
          <p>Welcome to the next generation of AI agent interactions</p>
        </div>
        <div className="dashboard-actions">
          <button 
            className="btn btn-primary"
            onClick={() => navigate('/decisions')}
          >
            <Play size={16} />
            Start Decision
          </button>
        </div>
      </motion.div>

      <motion.div
        className="dashboard-content"
        variants={containerVariants}
        initial="hidden"
        animate="visible"
      >
        {/* Key Metrics */}
        <motion.div className="metrics-section" variants={itemVariants}>
          <h2>System Overview</h2>
          <div className="metrics-grid">
            <MetricCard
              title="AI Agents Active"
              value={metrics?.activeAgents || 0}
              icon={Brain}
              color="blue"
              trend={metrics?.agentTrend || 0}
            />
            <MetricCard
              title="Decisions Made"
              value={metrics?.decisionsMade || 0}
              icon={Zap}
              color="green"
              trend={metrics?.decisionTrend || 0}
            />
            <MetricCard
              title="Learning Tasks"
              value={metrics?.learningTasks || 0}
              icon={BookOpen}
              color="purple"
              trend={metrics?.learningTrend || 0}
            />
            <MetricCard
              title="System Health"
              value={`${metrics?.systemHealth || 0}%`}
              icon={Shield}
              color="orange"
              trend={metrics?.healthTrend || 0}
            />
          </div>
        </motion.div>

        {/* Quick Actions */}
        <motion.div className="quick-actions-section" variants={itemVariants}>
          <h2>Quick Actions</h2>
          <div className="quick-actions-grid">
            {quickActions.map((action) => (
              <QuickActionCard
                key={action.id}
                title={action.title}
                description={action.description}
                icon={action.icon}
                color={action.color}
                onClick={action.action}
              />
            ))}
          </div>
        </motion.div>

        {/* System Status and Performance */}
        <motion.div className="status-performance-section" variants={itemVariants}>
          <div className="status-performance-grid">
            <div className="status-widget">
              <SystemStatusWidget status={systemStatus} />
            </div>
            <div className="performance-widget">
              <PerformanceChart data={metrics?.performanceData} />
            </div>
          </div>
        </motion.div>

        {/* Recent Activity */}
        <motion.div className="activity-section" variants={itemVariants}>
          <div className="activity-header">
            <h2>Recent Activity</h2>
            <button 
              className="btn btn-text"
              onClick={() => navigate('/monitor')}
            >
              View All
              <ArrowRight size={16} />
            </button>
          </div>
          <RecentActivityWidget activities={recentActivity || []} />
        </motion.div>

        {/* System Resources */}
        <motion.div className="resources-section" variants={itemVariants}>
          <h2>System Resources</h2>
          <div className="resources-grid">
            <div className="resource-card">
              <div className="resource-header">
                <Cpu size={20} />
                <span>CPU Usage</span>
              </div>
              <div className="resource-value">
                {metrics?.cpuUsage || 0}%
              </div>
              <div className="resource-bar">
                <div 
                  className="resource-bar-fill"
                  style={{ width: `${metrics?.cpuUsage || 0}%` }}
                />
              </div>
            </div>
            <div className="resource-card">
              <div className="resource-header">
                <Database size={20} />
                <span>Memory Usage</span>
              </div>
              <div className="resource-value">
                {metrics?.memoryUsage || 0}%
              </div>
              <div className="resource-bar">
                <div 
                  className="resource-bar-fill"
                  style={{ width: `${metrics?.memoryUsage || 0}%` }}
                />
              </div>
            </div>
            <div className="resource-card">
              <div className="resource-header">
                <TrendingUp size={20} />
                <span>Network</span>
              </div>
              <div className="resource-value">
                {metrics?.networkUsage || 0} Mbps
              </div>
              <div className="resource-bar">
                <div 
                  className="resource-bar-fill"
                  style={{ width: `${Math.min((metrics?.networkUsage || 0) / 100, 1) * 100}%` }}
                />
              </div>
            </div>
          </div>
        </motion.div>
      </motion.div>
    </div>
  );
};

export default Dashboard; 