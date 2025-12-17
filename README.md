# Full-stack CRUD with Prisma, Express and React

This project is a full-stack CRUD (create, read, update, delete) application using [Prisma](https://www.prisma.io/), [Express](https://expressjs.com), and [React](https://reactjs.org)

## Back-End

```bash
cd backend
```

copy the `.env.example` file to `.env`

```
APP_PORT=5000
DATABASE_URL="mysql://root:123456@localhost:3306/prisma-react"
```

Install dependencies

```bash
npm install
```

Generate the Prisma Client

```
npx prisma generate
```

Migrate Database with Prisma

```
npx prisma migrate dev
```

Start the server

```bash
npm start
```

Your express server will now be running on port 5000. You can visit [http://localhost:5000](http://localhost:5000) in your web browser to verify that the server is working correctly.

## Front-End

```bash
cd frontend

# Install dependencies...
npm install

# To start the application...
npm start
```

Runs the app in the development mode. Open [http://localhost:3000](http://localhost:3000) to view it in your browser.

## Run with Docker Compose

Docker Compose in [docker-compose.yml](docker-compose.yml) spins up MySQL, backend, and frontend:

```powershell
# From repo root
docker compose up -d --build

# Services
# - MySQL: localhost:3307 (container listens on 3306)
# - Backend API: http://localhost:5000
# - Frontend (static server): http://localhost:3001

# View logs
docker compose logs -f backend
docker compose logs -f frontend

# Tear down
docker compose down -v
```

Backend Prisma (optional while developing):

```powershell
# Inside backend/
npx prisma migrate deploy
npx prisma generate
```

## Infrastructure (Terraform)

Terraform in [infra/](infra) provisions:
- VPC, public subnets, Internet Gateway, routing
- RDS MySQL (publicly accessible for development)
- EKS cluster (control plane)

Commands:

```powershell
cd infra
terraform init

# Apply (use your public IP for MySQL allow-list)
$ip = (Invoke-RestMethod -Uri https://checkip.amazonaws.com).Trim()
terraform apply `
	-var "db_username=admin" `
	-var "db_password=admin123" `
	-var "db_name=mydb" `
	-var "client_ip_cidr=$ip/32"

# Show outputs (capture for report)
terraform output
terraform output rds_endpoint
terraform output eks_name
terraform output vpc_id

# Destroy (cleanup proof)
terraform destroy -auto-approve `
	-var "db_username=admin" `
	-var "db_password=admin123" `
	-var "db_name=mydb" `
	-var "client_ip_cidr=$ip/32"
```

Tips:
- If destroy fails deleting the RDS Security Group due to an ENI, wait 2–5 minutes and re-run `terraform destroy` — AWS may be releasing the managed ENI.
- Store console screenshots and terminal captures in [docs/screenshots/](docs/screenshots).

## Kubernetes Deployment

Prerequisites:
- EKS cluster provisioned via Terraform outputs.
- `kubectl` configured (the CI job runs `aws eks update-kubeconfig`).

Deploy app resources:

```powershell
# Create dev namespace and base resources
kubectl apply -f k8s/namespaces.yaml
kubectl apply -f k8s/configmap-dev.yaml
kubectl apply -f k8s/secret-dev.yaml
kubectl apply -f k8s/service-mysql-external.yaml
kubectl apply -f k8s/deployment-redis.yaml
kubectl apply -f k8s/deployment-backend.yaml

# Optional: Ingress for backend
kubectl apply -f k8s/ingress.yaml

# Update image (after CI push)
kubectl -n dev set image deployment/backend backend=<dockerhub-user>/crud-backend:<tag>
kubectl -n dev rollout status deployment/backend --timeout=600s
```

Monitoring (Prometheus + Grafana):

```powershell
# Namespace and Helm repo
kubectl apply -f k8s/monitoring-namespace.yaml
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install kube-prometheus-stack with our values
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack `
	-n monitoring --create-namespace -f k8s/monitoring-values.yaml --wait

# Scrape backend /metrics
kubectl apply -f k8s/servicemonitor-backend.yaml

# Access Grafana
# - NodePort: http://<node-ip>:32000 (user: admin, pass: prom-operator)
# - Or port-forward
kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80
```

Useful queries/panels:
- Request rate: `sum by (route) (rate(http_requests_total[5m]))`
- Node CPU/Memory: Built-in "Kubernetes / Nodes" dashboard
- Pods CPU/Memory: Built-in "Kubernetes / Pods" dashboard for `dev/backend`

## CI/CD (GitHub Actions)

This repo includes a pipeline at [.github/workflows/ci-cd.yml](.github/workflows/ci-cd.yml):
- CI (on push): Lint backend, build Docker image, push to Docker Hub, run Trivy scans.
- CD (manual): Terraform plan/apply for infra, configure EKS, apply k8s manifests, update backend image, smoke test from in-cluster.

Required GitHub Secrets:
- `DOCKER_USERNAME`, `DOCKER_PASSWORD`
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION` (us-east-1)
- `EKS_CLUSTER_NAME` (my-eks-cluster)
- `DB_PASSWORD` (RDS admin password)
- `DATABASE_URL` (e.g., mysql://admin:admin123@mysql:3306/mydb)

Run:
1) Push to `main` to execute CI build and push.
2) Trigger `Run workflow` in Actions (workflow_dispatch) to execute CD once the EKS cluster is ready.

