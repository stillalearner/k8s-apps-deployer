"""Base application class"""
from abc import ABC, abstractmethod
from typing import Optional
import logging


class Application(ABC):
    """Base class for all applications"""
    
    def __init__(self, cluster, namespace: str, logger: Optional[logging.Logger] = None):
        """
        Initialize application
        
        Args:
            cluster: ClusterConnection instance
            namespace: Namespace to deploy to
            logger: Logger instance
        """
        self.cluster = cluster
        self.namespace = namespace
        self.logger = logger or logging.getLogger(__name__)
    
    @abstractmethod
    def deploy(self, **kwargs) -> bool:
        """Deploy the application"""
        pass
    
    @abstractmethod
    def remove(self, **kwargs) -> bool:
        """Remove the application"""
        pass
    
    @abstractmethod
    def validate(self, **kwargs) -> bool:
        """Validate the application is working"""
        pass
