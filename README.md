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

## CI/CD (GitHub Actions)

This repo includes a pipeline at [.github/workflows/ci-cd.yml](.github/workflows/ci-cd.yml):
- CI (on push): Lint backend, build Docker image, push to Docker Hub, run Trivy scans.
- CD (manual): Terraform plan/apply for infra, configure EKS, apply k8s manifests, update backend image, smoke test from in-cluster.

Required GitHub Secrets:
- `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION` (us-east-1)
- `EKS_CLUSTER_NAME` (my-eks-cluster)
- `DB_PASSWORD` (RDS admin password)
- `DATABASE_URL` (e.g., mysql://admin:admin123@mysql:3306/mydb)

Run:
1) Push to `main` to execute CI build and push.
2) Trigger `Run workflow` in Actions (workflow_dispatch) to execute CD once the EKS cluster is ready.

