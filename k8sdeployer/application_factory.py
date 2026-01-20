"""Application factory for creating application instances"""
import os
from typing import Dict, Type

from k8sdeployer.apps.ansible_app import AnsibleApplication
from k8sdeployer.apps.base import Application


class ApplicationNotAvailable(Exception):
    """Raised when requested application is not available"""
    pass


class ApplicationFactory:
    """Factory for creating application instances"""
    
    def __init__(self):
        """Initialize factory with available applications"""
        self.applications: Dict[str, Type[Application]] = self._discover_ansible_apps()
    
    def _discover_ansible_apps(self) -> Dict[str, Type[Application]]:
        """Discover Ansible-based applications from roles directory"""
        import k8sdeployer.ansible
        import inspect
        
        ansible_path = os.path.dirname(inspect.getfile(k8sdeployer.ansible))
        roles_path = os.path.join(ansible_path, 'roles')
        
        apps = {}
        if os.path.exists(roles_path):
            for entry in os.scandir(roles_path):
                if entry.is_dir() and not entry.name.startswith('.'):
                    apps[entry.name] = AnsibleApplication
        
        return apps
    
    def get_all_app_ids(self) -> list:
        """Get list of all available application IDs"""
        return list(self.applications.keys())
    
    def create_app(self, app_id: str, cluster, namespace: str = None, logger=None) -> Application:
        """
        Create an application instance
        
        Args:
            app_id: Application identifier
            cluster: ClusterConnection instance
            namespace: Namespace to deploy to
            logger: Logger instance
        
        Returns:
            Application instance
        
        Raises:
            ApplicationNotAvailable: If application is not found
        """
        app_class = self.applications.get(app_id)
        if app_class is None:
            raise ApplicationNotAvailable(f'Application "{app_id}" does not exist!')
        
        return app_class(app_id, cluster, namespace, logger)
