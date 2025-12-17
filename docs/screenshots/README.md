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
