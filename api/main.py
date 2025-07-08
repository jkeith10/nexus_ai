#!/usr/bin/env python3
"""
Nexus AI Agent Framework - API Server
RESTful API for interacting with the Nexus AI system
"""

import asyncio
import logging
import json
import time
from typing import Dict, List, Optional, Any
from dataclasses import dataclass, asdict
from pathlib import Path

# FastAPI imports
from fastapi import FastAPI, HTTPException, Depends, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel, Field
import uvicorn

# Custom imports
from nexus_core_client import NexusCoreClient
from ai_client import AIClient
from auth_service import AuthService
from rate_limiter import RateLimiter
from monitoring import APIMonitoring

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Pydantic models for API requests/responses
class DecisionRequest(BaseModel):
    input_data: Dict[str, float] = Field(..., description="Input data for decision making")
    uncertainty_levels: Optional[Dict[str, float]] = Field(default=None, description="Uncertainty levels for inputs")
    confidence_threshold: float = Field(default=0.7, description="Confidence threshold for decision")
    max_superposition_states: int = Field(default=5, description="Maximum superposition states")

class DecisionResponse(BaseModel):
    decision: str
    confidence: float
    uncertainty: float
    superposition_states: List[Dict[str, Any]]
    entanglement_effects: List[str]
    processing_time: float

class LearningTaskRequest(BaseModel):
    task_type: str = Field(..., description="Type of learning task")
    input_data: Dict[str, Any] = Field(..., description="Input data for learning")
    target_data: Optional[Dict[str, Any]] = Field(default=None, description="Target data for supervised learning")
    metadata: Optional[Dict[str, Any]] = Field(default=None, description="Additional metadata")

class LearningTaskResponse(BaseModel):
    task_id: str
    success: bool
    accuracy: Optional[float] = None
    loss: Optional[float] = None
    learning_metrics: Optional[Dict[str, float]] = None
    error_message: Optional[str] = None

class CollaborativeSessionRequest(BaseModel):
    user_id: str = Field(..., description="User ID for the session")
    problem_description: str = Field(..., description="Description of the problem to solve")

class CollaborativeSessionResponse(BaseModel):
    session_id: str
    status: str
    problem_description: str
    session_start: float

class ContributionRequest(BaseModel):
    session_id: str = Field(..., description="Session ID to contribute to")
    contribution: str = Field(..., description="Contribution content")
    contributor: str = Field(default="human", description="Contributor type")

class ContributionResponse(BaseModel):
    session_id: str
    contribution_accepted: bool
    solution_update: Optional[Dict[str, Any]] = None
    session_progress: float
    error_message: Optional[str] = None

class SystemHealthResponse(BaseModel):
    status: str
    components: Dict[str, str]
    metrics: Dict[str, float]
    last_updated: float

class NexusAPI:
    """Main API server for Nexus AI Agent Framework"""
    
    def __init__(self):
        self.app = FastAPI(
            title="Nexus AI Agent Framework API",
            description="RESTful API for next-generation AI agent interactions",
            version="0.1.0",
            docs_url="/docs",
            redoc_url="/redoc"
        )
        
        # Initialize clients
        self.core_client = NexusCoreClient()
        self.ai_client = AIClient()
        self.auth_service = AuthService()
        self.rate_limiter = RateLimiter()
        self.monitoring = APIMonitoring()
        
        # Security
        self.security = HTTPBearer()
        
        # Setup middleware and routes
        self.setup_middleware()
        self.setup_routes()
        
        logger.info("Initialized Nexus API Server")
    
    def setup_middleware(self):
        """Setup API middleware"""
        # CORS middleware
        self.app.add_middleware(
            CORSMiddleware,
            allow_origins=["*"],  # Configure appropriately for production
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
        )
        
        # Add custom middleware for monitoring and rate limiting
        self.app.middleware("http")(self.monitoring.middleware)
        self.app.middleware("http")(self.rate_limiter.middleware)
    
    def setup_routes(self):
        """Setup API routes"""
        
        @self.app.on_event("startup")
        async def startup_event():
            """Initialize services on startup"""
            await self.core_client.initialize()
            await self.ai_client.initialize()
            await self.auth_service.initialize()
            await self.rate_limiter.initialize()
            await self.monitoring.initialize()
            logger.info("Nexus API Server started successfully")
        
        @self.app.on_event("shutdown")
        async def shutdown_event():
            """Cleanup on shutdown"""
            await self.core_client.shutdown()
            await self.ai_client.shutdown()
            await self.auth_service.shutdown()
            await self.rate_limiter.shutdown()
            await self.monitoring.shutdown()
            logger.info("Nexus API Server shutdown complete")
        
        # Health check endpoint
        @self.app.get("/health", response_model=SystemHealthResponse)
        async def health_check():
            """System health check"""
            try:
                health_data = await self.monitoring.get_system_health()
                return SystemHealthResponse(**health_data)
            except Exception as e:
                logger.error(f"Health check failed: {e}")
                raise HTTPException(status_code=500, detail="Health check failed")
        
        # Decision making endpoint
        @self.app.post("/decisions", response_model=DecisionResponse)
        async def make_decision(
            request: DecisionRequest,
            background_tasks: BackgroundTasks,
            credentials: HTTPAuthorizationCredentials = Depends(self.security)
        ):
            """Make a quantum-inspired decision"""
            try:
                # Authenticate request
                user_id = await self.auth_service.authenticate(credentials.credentials)
                
                # Rate limiting
                await self.rate_limiter.check_rate_limit(user_id, "decisions")
                
                # Record request
                background_tasks.add_task(self.monitoring.record_request, "decisions", user_id)
                
                # Process decision
                start_time = time.time()
                result = await self.core_client.process_decision(request.dict())
                processing_time = time.time() - start_time
                
                # Add processing time to result
                result["processing_time"] = processing_time
                
                return DecisionResponse(**result)
                
            except Exception as e:
                logger.error(f"Decision making failed: {e}")
                raise HTTPException(status_code=500, detail=str(e))
        
        # Learning task endpoint
        @self.app.post("/learning/tasks", response_model=LearningTaskResponse)
        async def process_learning_task(
            request: LearningTaskRequest,
            background_tasks: BackgroundTasks,
            credentials: HTTPAuthorizationCredentials = Depends(self.security)
        ):
            """Process a learning task"""
            try:
                # Authenticate request
                user_id = await self.auth_service.authenticate(credentials.credentials)
                
                # Rate limiting
                await self.rate_limiter.check_rate_limit(user_id, "learning")
                
                # Record request
                background_tasks.add_task(self.monitoring.record_request, "learning", user_id)
                
                # Process learning task
                result = await self.ai_client.process_learning_task(request.dict())
                
                return LearningTaskResponse(**result)
                
            except Exception as e:
                logger.error(f"Learning task failed: {e}")
                raise HTTPException(status_code=500, detail=str(e))
        
        # AI response generation endpoint
        @self.app.post("/ai/generate")
        async def generate_response(
            input_text: str,
            context: Optional[Dict[str, Any]] = None,
            credentials: HTTPAuthorizationCredentials = Depends(self.security)
        ):
            """Generate AI response"""
            try:
                # Authenticate request
                user_id = await self.auth_service.authenticate(credentials.credentials)
                
                # Rate limiting
                await self.rate_limiter.check_rate_limit(user_id, "ai_generation")
                
                # Generate response
                response = await self.ai_client.generate_response(input_text, context)
                
                return {"response": response, "user_id": user_id}
                
            except Exception as e:
                logger.error(f"Response generation failed: {e}")
                raise HTTPException(status_code=500, detail=str(e))
        
        # Collaborative session endpoints
        @self.app.post("/collaborative/sessions", response_model=CollaborativeSessionResponse)
        async def start_collaborative_session(
            request: CollaborativeSessionRequest,
            credentials: HTTPAuthorizationCredentials = Depends(self.security)
        ):
            """Start a collaborative problem-solving session"""
            try:
                # Authenticate request
                user_id = await self.auth_service.authenticate(credentials.credentials)
                
                # Verify user matches request
                if user_id != request.user_id:
                    raise HTTPException(status_code=403, detail="User ID mismatch")
                
                # Start session
                session_id = await self.ai_client.start_collaborative_session(
                    request.user_id, request.problem_description
                )
                
                if not session_id:
                    raise HTTPException(status_code=500, detail="Failed to start session")
                
                return CollaborativeSessionResponse(
                    session_id=session_id,
                    status="active",
                    problem_description=request.problem_description,
                    session_start=time.time()
                )
                
            except Exception as e:
                logger.error(f"Session start failed: {e}")
                raise HTTPException(status_code=500, detail=str(e))
        
        @self.app.post("/collaborative/contribute", response_model=ContributionResponse)
        async def contribute_to_session(
            request: ContributionRequest,
            credentials: HTTPAuthorizationCredentials = Depends(self.security)
        ):
            """Contribute to a collaborative session"""
            try:
                # Authenticate request
                user_id = await self.auth_service.authenticate(credentials.credentials)
                
                # Rate limiting
                await self.rate_limiter.check_rate_limit(user_id, "collaboration")
                
                # Contribute to session
                result = await self.ai_client.contribute_to_session(
                    request.session_id, request.contribution, request.contributor
                )
                
                return ContributionResponse(**result)
                
            except Exception as e:
                logger.error(f"Contribution failed: {e}")
                raise HTTPException(status_code=500, detail=str(e))
        
        @self.app.post("/collaborative/end/{session_id}")
        async def end_collaborative_session(
            session_id: str,
            credentials: HTTPAuthorizationCredentials = Depends(self.security)
        ):
            """End a collaborative session"""
            try:
                # Authenticate request
                user_id = await self.auth_service.authenticate(credentials.credentials)
                
                # End session
                result = await self.ai_client.end_collaborative_session(session_id)
                
                return result
                
            except Exception as e:
                logger.error(f"Session end failed: {e}")
                raise HTTPException(status_code=500, detail=str(e))
        
        # System monitoring endpoints
        @self.app.get("/monitoring/metrics")
        async def get_metrics(
            credentials: HTTPAuthorizationCredentials = Depends(self.security)
        ):
            """Get system metrics"""
            try:
                # Authenticate request
                user_id = await self.auth_service.authenticate(credentials.credentials)
                
                # Check admin privileges
                if not await self.auth_service.is_admin(user_id):
                    raise HTTPException(status_code=403, detail="Admin access required")
                
                metrics = await self.monitoring.get_metrics()
                return metrics
                
            except Exception as e:
                logger.error(f"Metrics retrieval failed: {e}")
                raise HTTPException(status_code=500, detail=str(e))
        
        @self.app.get("/monitoring/requests")
        async def get_request_history(
            limit: int = 100,
            credentials: HTTPAuthorizationCredentials = Depends(self.security)
        ):
            """Get request history"""
            try:
                # Authenticate request
                user_id = await self.auth_service.authenticate(credentials.credentials)
                
                # Check admin privileges
                if not await self.auth_service.is_admin(user_id):
                    raise HTTPException(status_code=403, detail="Admin access required")
                
                history = await self.monitoring.get_request_history(limit)
                return history
                
            except Exception as e:
                logger.error(f"Request history retrieval failed: {e}")
                raise HTTPException(status_code=500, detail=str(e))

def main():
    """Main entry point"""
    logger.info("Starting Nexus AI Agent Framework API Server")
    
    # Create API instance
    api = NexusAPI()
    
    # Run server
    uvicorn.run(
        api.app,
        host="0.0.0.0",
        port=8000,
        log_level="info",
        reload=False
    )

if __name__ == "__main__":
    main() 