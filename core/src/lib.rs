pub mod quantum_substrate;
pub mod cognitive_foundation;
pub mod agent_orchestration;
pub mod intelligence_synthesis;
pub mod security_governance;

pub use quantum_substrate::*;
pub use cognitive_foundation::*;
pub use agent_orchestration::*;
pub use intelligence_synthesis::*;
pub use security_governance::*;

/// Main entry point for the Nexus Core system
pub struct NexusCore {
    quantum_engine: QuantumDecisionEngine,
    cognitive_network: DistributedCognitionNetwork,
    agent_orchestrator: AgentOrchestrator,
    intelligence_synthesizer: IntelligenceSynthesizer,
    security_framework: QuantumSecurityFramework,
}

impl NexusCore {
    pub fn new() -> Self {
        Self {
            quantum_engine: QuantumDecisionEngine::new(),
            cognitive_network: DistributedCognitionNetwork::new(),
            agent_orchestrator: AgentOrchestrator::new(),
            intelligence_synthesizer: IntelligenceSynthesizer::new(),
            security_framework: QuantumSecurityFramework::new(),
        }
    }

    pub fn initialize(&mut self) -> Result<(), Box<dyn std::error::Error>> {
        self.quantum_engine.initialize()?;
        self.cognitive_network.initialize()?;
        self.agent_orchestrator.initialize()?;
        self.intelligence_synthesizer.initialize()?;
        self.security_framework.initialize()?;
        Ok(())
    }

    pub fn process_decision(&mut self, context: DecisionContext) -> DecisionResult {
        self.quantum_engine.process_superposition_decision(context)
    }
} 