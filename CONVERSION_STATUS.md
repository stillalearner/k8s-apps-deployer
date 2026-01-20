# Role Conversion Status

This document tracks the conversion of Ansible roles from `oadp-apps-deployer` to `k8s-apps-deployer`.

## Conversion Strategy

All roles have been converted to:
- Use `k8s` Ansible module instead of `oc` shell commands for resource management
- Use `kubectl` via `ansible.builtin.command` for exec/logs operations
- Support both Kubernetes and OpenShift
- Preserve all validations and data provisioning steps
- Use consistent variable names (`server`, `token`, `verify_ssl`)

## Completed Conversions ✅

1. **mysql** - Full conversion with data provisioning
2. **mongodb** - Full conversion with data loading
3. **redis** - Full conversion
4. **basic-pod** - Full conversion with all templates (base data, add data, remove data, validation)
5. **pvc** - Full conversion
6. **configmap** - Full conversion
7. **jobs** - Full conversion
8. **cronjob** - Full conversion
9. **cassandra** - Full conversion with StatefulSet
10. **mssql** - Full conversion with SCC handling
11. **initcont** - Full conversion
12. **pod-with-emptydir** - Full conversion
13. **simple-nginx-nopv** - Full conversion
14. **resourcequota** - Full conversion
15. **storageclass** - Full conversion
16. **sets** - Full conversion (DaemonSet, ReplicaSet, StatefulSet)
17. **8pvc-app** - Full conversion with 8 PVCs
18. **pvc-with-data-attached-to-a-completed-pod** - Full conversion
19. **project** - Full conversion (OpenShift Project)
20. **role** - Full conversion (RBAC Role and RoleBinding)
21. **corrupt-file** - Full conversion
22. **datavolume** - Full conversion (KubeVirt DataVolume)
23. **todolist-mariadb** - Full conversion
24. **todolist-mongodb-block** - Full conversion
25. **volumesnapshot** - Full conversion
26. **crd** - Full conversion (CustomResourceDefinition)
27. **core-crs** - Full conversion (Core Custom Resources)
28. **robot-shop** - Full conversion
29. **sock-shop** - Full conversion
30. **nginxpv** - Full conversion
31. **django** - Full conversion (template-based, OpenShift-specific features marked)
32. **cakephp** - Full conversion (OpenShift-specific features marked)
33. **datagrid** - Full conversion (OpenShift-specific features marked)
34. **dockerbuild** - Full conversion (OpenShift-specific features marked)
35. **imagestreams** - Full conversion (OpenShift-specific features marked)
36. **templateinstance** - Full conversion (OpenShift-specific features marked)
37. **kubevirt** - Full conversion (KubeVirt-specific features marked)
38. **kubevirt-running-vm** - Full conversion (KubeVirt-specific features marked)
39. **kubevirt-todo** - Full conversion (KubeVirt-specific features marked)

## Notes

- OpenShift-specific resources (Routes, ImageStreams, BuildConfigs, DeploymentConfigs, SecurityContextConstraints, Templates, TemplateInstances) are conditionally handled or replaced with K8s equivalents
- Routes are optional (OpenShift only) - validation checks for their existence before using them
- SCC resources are only created/validated on OpenShift clusters
- BuildConfig operations are skipped on pure Kubernetes clusters (OpenShift only)
- KubeVirt resources (VirtualMachine, VirtualMachineInstance, DataVolume) are marked as KubeVirt-only
- All roles maintain backward compatibility with existing Ansible playbook structure
- Template-based deployments are converted to direct K8s resource definitions where possible
- OpenShift-specific operations use `ignore_errors: yes` to gracefully handle failures on pure K8s clusters
