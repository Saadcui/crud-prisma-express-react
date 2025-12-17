# Kubernetes Deployment (Step 3)

This folder contains manifests to deploy the backend API (Express + Prisma) and a Redis cache to Kubernetes.

## What’s included
- `namespaces.yaml`: Namespaces `dev` and `prod` (we use `dev`).
- `configmap-dev.yaml`: Non-secret config (APP_PORT).
- `secret-dev.yaml`: DATABASE_URL secret (fill with your RDS URL).
- `deployment-backend.yaml`: Backend `Deployment` and `Service` (ClusterIP).
- `deployment-redis.yaml`: Redis `Deployment` and `Service` (ClusterIP).
- `ingress.yaml`: Optional Ingress (requires an Ingress controller like NGINX).
- `service-mysql-external.yaml`: ExternalName Service `mysql` pointing to your RDS hostname, so pods can refer to DB via a K8s Service.

## Prerequisites
- `kubectl` installed and configured.
- Either:
  - EKS: `aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster`
  - Minikube: `minikube start`
- Backend Docker image pushed to a registry (replace `<your-dockerhub-username>/crud-backend:latest` in manifests).

## Set secrets and deploy

1) Create namespaces and config:
```bash
kubectl apply -f k8s/namespaces.yaml
kubectl apply -f k8s/configmap-dev.yaml
```

2) Create the secret (Preferred: CLI without committing secrets):
```bash
kubectl -n dev create secret generic backend-secrets \
  --from-literal=DATABASE_URL="mysql://admin:admin123@mysql:3306/mydb"
```
Alternatively, edit `k8s/secret-dev.yaml` to set `DATABASE_URL` and apply it:
```bash
kubectl apply -f k8s/secret-dev.yaml
```

3) Create ExternalName Service for RDS (replace the hostname in the file if needed):
```bash
kubectl apply -f k8s/service-mysql-external.yaml
```

4) Deploy Redis (optional cache/message queue requirement):
```bash
kubectl apply -f k8s/deployment-redis.yaml
```

5) Deploy backend:
```bash
kubectl apply -f k8s/deployment-backend.yaml
```

6) (Optional) Expose via Ingress (requires controller):
```bash
kubectl apply -f k8s/ingress.yaml
```

## Verify
```bash
kubectl -n dev get pods
kubectl -n dev get svc
kubectl -n dev describe pod <backend-pod-name>
```
- Backend service name: `backend` (port 5000)
- Redis service name: `redis` (port 6379)
- DB service name: `mysql` (ExternalName to RDS)

If using Minikube without Ingress, you can port-forward for quick testing:
```bash
kubectl -n dev port-forward svc/backend 5000:5000
# Then curl http://localhost:5000/
```

## Notes
- Frontend code currently calls `http://localhost:5000/...`. For K8s usage, either run the frontend locally while port-forwarding the backend service, or update the frontend to read an environment variable (e.g., `REACT_APP_API_URL`) and rebuild with the cluster URL/Ingress.
- For production, keep RDS private and run migrations from within the cluster (Job) or a private runner.

## EKS Bootstrap (aws-auth)
- EKS worker nodes must be authorized via `aws-auth` in `kube-system`.
- If Terraform targeting is inconvenient, apply the config directly:
```bash
kubectl apply -f k8s/aws-auth.yaml
kubectl -n kube-system get configmap aws-auth -o yaml
```

Then create (or recreate) the node group with Terraform:
```bash
cd infra
terraform plan -target=aws_eks_node_group.default -out=tfplan
terraform apply tfplan
```
Verify nodes join:
```bash
kubectl get nodes -o wide
kubectl -n kube-system get pods
```
