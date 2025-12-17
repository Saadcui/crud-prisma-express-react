# Ansible (Step 4)

Automates Kubernetes deployment of the backend API and Redis, including ConfigMap and Secret.

## Prerequisites
- Ansible installed on your machine (controller).
- `kubectl` installed and configured to your cluster context.
- Docker image for backend pushed to a registry (set `backend_image` variable).

## Run
From repo root:

```bash
cd ansible
# EKS example: ensure kubecontext
aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster

# Run with variables (recommended to pass DATABASE_URL at runtime)
ansible-playbook -i hosts.ini playbook.yaml \
  -e "database_url=mysql://admin:admin123@<RDS_ENDPOINT_HOST>:3306/mydb" \
  -e "backend_image=<your-dockerhub-username>/crud-backend:latest"
```

This will:
- Apply namespaces and ConfigMap in `k8s/`
- Create/update the `backend-secrets` Secret from the provided `database_url`
- Deploy Redis and the backend
- Set the backend image and wait for rollout
- Print pods and services

## Screenshot for submission
Capture the final Ansible output showing successful tasks and the `get pods,svc` summary.
