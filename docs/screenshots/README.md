       # Screenshots Checklist

Include the following screenshots for submission:

- VPC: Details page of the created VPC (ID visible).
- Subnets: `public-a` and `public-b` with route table associations.
- Security Group: `rds-sg` with inbound rule on TCP/3306 (your IP /32) visible.
- RDS: Instance `my-db` details page with endpoint and status `available`.
- EKS: Cluster `my-eks-cluster` overview page.
- Terraform outputs: Terminal showing `terraform output` with `eks_name`, `rds_endpoint`, `vpc_id`.
- Destroy proof: Terminal screenshot of `terraform destroy` ending with `Destroy complete!` and resource counts.

Optional:
- `kubectl get pods` and `kubectl get svc` if you deploy workloads later.

## Monitoring & Observability

Capture the following after deploying Prometheus + Grafana:

- Grafana Access: Open Grafana via NodePort `32000` (or port-forward). Default login: `admin` / `prom-operator`.
- Node CPU & Memory: Built-in Kubernetes/Nodes dashboard panels showing CPU and memory usage.
- Pod Metrics: Built-in Kubernetes/Pods dashboard for backend pod CPU/memory.
- Requests Count: A panel querying `sum by (route) (rate(http_requests_total[5m]))` to show app request rate per route.
- Prometheus Targets: Prometheus UI showing `backend` ServiceMonitor target as `UP`.

Quick access commands:

```bash
# Port-forward Grafana if NodePort is not reachable
kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80
# Then browse http://localhost:3000

# Port-forward Prometheus (optional)
kubectl -n monitoring port-forward svc/kube-prometheus-stack-prometheus 9090:9090
# Then browse http://localhost:9090/targets
```
