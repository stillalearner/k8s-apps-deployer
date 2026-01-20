"""Ansible-based application deployment"""
import os
import inspect
import ansible_runner
import shutil
import logging
from typing import Dict, Any

from k8sdeployer.apps.base import Application
import k8sdeployer.ansible


class AnsibleApplication(Application):
    """Application deployed via Ansible playbooks"""
    
    def __init__(self, role_name: str, cluster, namespace: str = None, logger=None):
        """
        Initialize Ansible application
        
        Args:
            role_name: Name of the Ansible role
            cluster: ClusterConnection instance
            namespace: Namespace to deploy to (defaults to role_name)
            logger: Logger instance
        """
        ns = namespace if namespace else role_name
        super().__init__(cluster, ns, logger)
        
        self.role_name = role_name
        self.ansible_dir = os.path.dirname(inspect.getfile(k8sdeployer.ansible))
        self.ansible_roles_dir = os.path.join(self.ansible_dir, 'roles')
    
    def deploy(self, extra_vars: Dict[str, Any] = None) -> bool:
        """Deploy the application"""
        playbook = os.path.join(self.ansible_dir, 'deploy.yml')
        result = self._execute_playbook(playbook, extra_vars or {})
        return result.rc == 0
    
    def remove(self, extra_vars: Dict[str, Any] = None) -> bool:
        """Remove the application"""
        playbook = os.path.join(self.ansible_dir, 'remove.yml')
        result = self._execute_playbook(playbook, extra_vars or {})
        return result.rc == 0
    
    def validate(self, extra_vars: Dict[str, Any] = None) -> bool:
        """Validate the application"""
        playbook = os.path.join(self.ansible_dir, 'validate.yml')
        result = self._execute_playbook(playbook, extra_vars or {})
        return result.rc == 0
    
    def _get_common_extra_vars(self) -> Dict[str, Any]:
        """Get common variables for Ansible playbooks"""
        return {
            'token': self.cluster.token,
            'namespace': self.namespace,
            'server': self.cluster.server,
            'verify_ssl': self.cluster.verify_ssl,
            'is_openshift': self.cluster.is_openshift(),
            'cluster_version': self.cluster.get_version(),
            'use_role': self.role_name
        }
    
    def event_handler(self, event):
        """Handle Ansible runner events"""
        lines = event.get('stdout', 'EVENT HAS NO STDOUT').splitlines()
        for line in lines:
            self.logger.info(line)
    
    def _execute_playbook(self, playbook: str, extra_vars: Dict[str, Any]) -> Any:
        """Execute Ansible playbook"""
        all_extra_vars = {}
        all_extra_vars.update(self._get_common_extra_vars())
        all_extra_vars.update(extra_vars)
        
        envvars = {'ANSIBLE_CONFIG': os.path.join(self.ansible_dir, 'ansible.cfg')}
        
        self.logger.info(f'Executing playbook: {playbook}')
        
        result = ansible_runner.run(
            extravars=all_extra_vars,
            playbook=playbook,
            roles_path=self.ansible_roles_dir,
            envvars=envvars,
            event_handler=self.event_handler,
            quiet=True
        )
        
        # Cleanup temporary files
        if result.config.private_data_dir.startswith('/tmp'):
            self.logger.debug(f'Removing private data directory: {result.config.private_data_dir}')
            shutil.rmtree(result.config.private_data_dir)
        
        return result
