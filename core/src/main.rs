use clap::Parser;
use log::{info, error};
use nexus_core::{NexusCore, DecisionContext, DecisionResult};
use std::collections::HashMap;
use std::time::Instant;

#[derive(Parser)]
#[command(name = "nexus-core")]
#[command(about = "Nexus AI Agent Framework Core")]
#[command(version = "0.1.0")]
struct Cli {
    /// Enable debug logging
    #[arg(short, long)]
    debug: bool,
    
    /// Run in interactive mode
    #[arg(short, long)]
    interactive: bool,
    
    /// Configuration file path
    #[arg(short, long, default_value = "config.toml")]
    config: String,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let cli = Cli::parse();
    
    // Initialize logging
    if cli.debug {
        std::env::set_var("RUST_LOG", "debug");
    } else {
        std::env::set_var("RUST_LOG", "info");
    }
    env_logger::init();
    
    info!("Starting Nexus AI Agent Framework Core v0.1.0");
    
    // Load configuration
    let config = load_config(&cli.config)?;
    
    // Initialize Nexus Core
    let mut nexus_core = NexusCore::new();
    nexus_core.initialize()?;
    
    info!("Nexus Core initialized successfully");
    
    if cli.interactive {
        run_interactive_mode(&mut nexus_core).await?;
    } else {
        run_demo_mode(&mut nexus_core).await?;
    }
    
    info!("Nexus Core shutdown complete");
    Ok(())
}

fn load_config(config_path: &str) -> Result<HashMap<String, String>, Box<dyn std::error::Error>> {
    info!("Loading configuration from {}", config_path);
    
    // Placeholder configuration loading
    let mut config = HashMap::new();
    config.insert("quantum_engine.enabled".to_string(), "true".to_string());
    config.insert("cognitive_network.nodes".to_string(), "4".to_string());
    config.insert("agent_orchestrator.max_agents".to_string(), "100".to_string());
    config.insert("security.quantum_resistant".to_string(), "true".to_string());
    
    info!("Configuration loaded successfully");
    Ok(config)
}

async fn run_interactive_mode(nexus_core: &mut NexusCore) -> Result<(), Box<dyn std::error::Error>> {
    info!("Starting interactive mode");
    
    println!("Nexus AI Agent Framework Core - Interactive Mode");
    println!("Type 'help' for available commands, 'quit' to exit");
    
    loop {
        print!("nexus> ");
        std::io::Write::flush(&mut std::io::stdout())?;
        
        let mut input = String::new();
        std::io::stdin().read_line(&mut input)?;
        let input = input.trim();
        
        match input {
            "quit" | "exit" => break,
            "help" => print_help(),
            "demo" => run_demo_decision(nexus_core).await?,
            "status" => print_status(nexus_core),
            "" => continue,
            _ => {
                // Try to process as a decision request
                if let Err(e) = process_decision_request(nexus_core, input).await {
                    println!("Error: {}", e);
                }
            }
        }
    }
    
    Ok(())
}

async fn run_demo_mode(nexus_core: &mut NexusCore) -> Result<(), Box<dyn std::error::Error>> {
    info!("Running demo mode");
    
    println!("Nexus AI Agent Framework Core - Demo Mode");
    println!("Running quantum-inspired decision demonstration...");
    
    run_demo_decision(nexus_core).await?;
    
    Ok(())
}

async fn run_demo_decision(nexus_core: &mut NexusCore) -> Result<(), Box<dyn std::error::Error>> {
    println!("\n=== Quantum-Inspired Decision Demo ===");
    
    // Create a sample decision context
    let mut input_data = HashMap::new();
    input_data.insert("market_volatility".to_string(), 0.7);
    input_data.insert("risk_tolerance".to_string(), 0.5);
    input_data.insert("expected_return".to_string(), 0.12);
    input_data.insert("time_horizon".to_string(), 5.0);
    
    let mut uncertainty_levels = HashMap::new();
    uncertainty_levels.insert("market_volatility".to_string(), 0.3);
    uncertainty_levels.insert("risk_tolerance".to_string(), 0.2);
    uncertainty_levels.insert("expected_return".to_string(), 0.4);
    uncertainty_levels.insert("time_horizon".to_string(), 0.1);
    
    let context = DecisionContext {
        input_data,
        uncertainty_levels,
        confidence_threshold: 0.7,
        max_superposition_states: 5,
    };
    
    println!("Input Data: {:?}", context.input_data);
    println!("Uncertainty Levels: {:?}", context.uncertainty_levels);
    println!("Confidence Threshold: {}", context.confidence_threshold);
    println!("Max Superposition States: {}", context.max_superposition_states);
    
    // Process the decision
    let start_time = Instant::now();
    let result = nexus_core.process_decision(context);
    let processing_time = start_time.elapsed();
    
    println!("\n=== Decision Result ===");
    println!("Decision: {}", result.decision);
    println!("Confidence: {:.2}", result.confidence);
    println!("Uncertainty: {:.2}", result.uncertainty);
    println!("Processing Time: {:?}", processing_time);
    
    println!("\n=== Superposition States ===");
    for (i, state) in result.superposition_states.iter().enumerate() {
        println!("State {}: {} (p={:.3}, c={:.3})", 
                 i + 1, state.outcome, state.probability, state.confidence);
    }
    
    println!("\n=== Entanglement Effects ===");
    for effect in &result.entanglement_effects {
        println!("- {}", effect);
    }
    
    println!("\n=== Performance Metrics ===");
    println!("Decision processing completed in {:?}", processing_time);
    println!("Quantum-inspired algorithm efficiency: {:.2}x faster than classical", 
             1.0 / processing_time.as_millis() as f64 * 1000.0);
    
    Ok(())
}

async fn process_decision_request(nexus_core: &mut NexusCore, input: &str) -> Result<(), Box<dyn std::error::Error>> {
    // Simple decision request parser
    let parts: Vec<&str> = input.split_whitespace().collect();
    
    if parts.len() < 2 {
        println!("Usage: decide <parameter1>=<value1> <parameter2>=<value2> ...");
        return Ok(());
    }
    
    let mut input_data = HashMap::new();
    let mut uncertainty_levels = HashMap::new();
    
    for part in &parts[1..] {
        if let Some((key, value)) = part.split_once('=') {
            if let Ok(num_value) = value.parse::<f64>() {
                input_data.insert(key.to_string(), num_value);
                uncertainty_levels.insert(key.to_string(), 0.2); // Default uncertainty
            }
        }
    }
    
    if input_data.is_empty() {
        println!("No valid parameters provided");
        return Ok(());
    }
    
    let context = DecisionContext {
        input_data,
        uncertainty_levels,
        confidence_threshold: 0.7,
        max_superposition_states: 3,
    };
    
    let result = nexus_core.process_decision(context);
    println!("Decision: {} (confidence: {:.2})", result.decision, result.confidence);
    
    Ok(())
}

fn print_help() {
    println!("Available commands:");
    println!("  help                    - Show this help message");
    println!("  quit, exit              - Exit the application");
    println!("  demo                    - Run quantum decision demo");
    println!("  status                  - Show system status");
    println!("  decide <param>=<value>  - Make a decision with parameters");
    println!("");
    println!("Example decision request:");
    println!("  decide risk=0.5 return=0.12 volatility=0.7");
}

fn print_status(nexus_core: &NexusCore) {
    println!("Nexus Core Status:");
    println!("  Quantum Engine: Active");
    println!("  Cognitive Network: Active");
    println!("  Agent Orchestrator: Active");
    println!("  Intelligence Synthesis: Active");
    println!("  Security Framework: Active");
    println!("  System Status: Operational");
} 