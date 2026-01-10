# Community

## System Architecture Diagram

```
                                    ┌─────────────────────────────────────────────────────────────────┐
                                    │                          Dev Environment                         │
                                    │                                                                 │
                                    │  Developer Code → Git Push → GitHub Repository                 │
                                    └──────────────────────────────┬──────────────────────────────────┘
                                                                   │
                                                                   ▼
                                    ┌─────────────────────────────────────────────────────────────────┐
                                    │                    CI/CD Pipeline (GitHub Actions)             │
                                    │                                                                 │
                                    │  Build → Test → Push to AWS ECR → Trigger ArgoCD             │
                                    └──────────────────────────────┬──────────────────────────────────┘
                                                                   │
                                                                   ▼
                                    ┌─────────────────────────────────────────────────────────────────┐
                                    │                   AWS Artifact Registry (ECR)                   │
                                    │                    Container Image Storage                      │
                                    └──────────────────────────────┬──────────────────────────────────┘
                                                                   │
                                                                   ▼
                                    ┌─────────────────────────────────────────────────────────────────┐
                                    │                      ArgoCD (Deployment)                       │
                                    │                   GitOps-based Orchestration                   │
                                    └──────────────────────────────┬──────────────────────────────────┘
                                                                   │
                                    ┌──────────────────────────────┴──────────────────────────────────┐
                                    │                                                                 │
                                    ▼                                                                 ▼
                        ┌──────────────────────────────┐                             ┌──────────────────────────────┐
                        │   VIP Load Balancer (LB1)    │                             │   VIP Load Balancer (LB2)    │
                        │   (Primary)                  │                             │   (Standby)                  │
                        └──────────────┬───────────────┘                             └──────────────┬───────────────┘
                                       │                                                            │
                        ┌──────────────┴────────────────────────────────────────────────────────────┴──────────────┐
                        │                                                                                           │
                        ▼                                                                                           ▼
        ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        │                              Kubernetes Cluster (k8s-Cluster)                                           │
        │                                                                                                          │
        │  ┌────────────────────────────────────────────────────────────────────────────────────────────────────┐ │
        │  │                         Control Plane (Master Nodes)                                              │ │
        │  │  - API Server, Scheduler, Controller Manager, etcd                                               │ │
        │  │  - High Availability (3x Master Nodes for HA)                                                    │ │
        │  └────────────────────────────────────────────────────────────────────────────────────────────────────┘ │
        │                                                                                                          │
        │  ┌────────────────────────────────────────────────────────────────────────────────────────────────────┐ │
        │  │                         Worker Node Tier (Multiple Nodes)                                         │ │
        │  │                                                                                                    │ │
        │  │  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐           │ │
        │  │  │   Worker Node 1  │  │   Worker Node 2  │  │   Worker Node 3  │  │   Worker Node N  │           │ │
        │  │  │  (Compute)       │  │  (Compute)       │  │  (Compute)       │  │  (Compute)       │           │ │
        │  │  └──────────────────┘  └──────────────────┘  └──────────────────┘  └──────────────────┘           │ │
        │  └────────────────────────────────────────────────────────────────────────────────────────────────────┘ │
        │                                                                                                          │
        │  ┌────────────────────────────────────────────────────────────────────────────────────────────────────┐ │
        │  │                         Ingress Controller (Nginx Ingress)                                        │ │
        │  │                   - Routes external traffic to services                                          │ │
        │  │                   - SSL/TLS termination                                                          │ │
        │  └────────────────────────────────────────────────────────────────────────────────────────────────────┘ │
        │                                                                                                          │
        │  ┌────────────────────────────────────────────────────────────────────────────────────────────────────┐ │
        │  │                      Web Tier (Frontend) - Deployment/StatefulSet                                │ │
        │  │                                                                                                    │ │
        │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                                              │ │
        │  │  │  Web Pod 1  │  │  Web Pod 2  │  │  Web Pod 3  │     Horizontal Pod Autoscaler (HPA)         │ │
        │  │  │  (Nginx)    │  │  (Nginx)    │  │  (Nginx)    │     - Scales pods based on CPU/Memory       │ │
        │  │  └─────────────┘  └─────────────┘  └─────────────┘                                              │ │
        │  │                                                                                                    │ │
        │  │  Service (ClusterIP) → External LoadBalancer                                                     │ │
        │  └────────────────────────────────────────────────────────────────────────────────────────────────────┘ │
        │                                                                                                          │
        │  ┌────────────────────────────────────────────────────────────────────────────────────────────────────┐ │
        │  │                      WAS Tier (Application) - Deployment/StatefulSet                             │ │
        │  │                                                                                                    │ │
        │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                                              │ │
        │  │  │  WAS Pod 1  │  │  WAS Pod 2  │  │  WAS Pod 3  │     Horizontal Pod Autoscaler (HPA)         │ │
        │  │  │  (Java/Go)  │  │  (Java/Go)  │  │  (Java/Go)  │     - Scales pods based on CPU/Memory       │ │
        │  │  └─────────────┘  └─────────────┘  └─────────────┘                                              │ │
        │  │                                                                                                    │ │
        │  │  Service (ClusterIP) → Web Tier                                                                  │ │
        │  └────────────────────────────────────────────────────────────────────────────────────────────────────┘ │
        │                                                                                                          │
        └──────────────────────────────────────────────────────────────────────────────────────────────────────────┘
                                                                   │
                                    ┌──────────────────────────────┴──────────────────────────────────┐
                                    │                                                                 │
                                    ▼                                                                 ▼
                        ┌──────────────────────────────┐                             ┌──────────────────────────────┐
                        │   Database Tier (Storage)    │                             │   Backup & Disaster Recovery │
                        │                              │                             │                              │
                        │  MySQL Group Replication     │                             │  - Automated Backups         │
                        │  ┌──────────────────────────┐│                             │  - Replication to Standby    │
                        │  │  MySQL Primary (Active)  ││                             │  - Point-in-Time Restore     │
                        │  │  (Read/Write)            ││                             │                              │
                        │  └──────────────────────────┘│                             └──────────────────────────────┘
                        │  ┌──────────────────────────┐│
                        │  │  MySQL Replica (Standby) ││
                        │  │  (Read-Only)             ││
                        │  └──────────────────────────┘│
                        │                              │
                        │  Persistent Volume (PVC)     │
                        │  - Cloud Storage Backend     │
                        │  - High Availability         │
                        └──────────────────────────────┘
                                    │
                        ┌───────────┴───────────┐
                        │                       │
                        ▼                       ▼
                ┌──────────────────┐   ┌──────────────────┐
                │  Monitoring      │   │  Logging         │
                │  (Prometheus)    │   │  (ELK/Datadog)   │
                │                  │   │                  │
                │  - Metrics       │   │  - Log Storage   │
                │  - Alerts        │   │  - Log Indexing  │
                │  - Dashboards    │   │  - Search/Query  │
                │  (Grafana)       │   │  - Visualization │
                └──────────────────┘   └──────────────────┘
```

## Architecture Components

### 1. **Development & CI/CD Pipeline**
- **Dev Environment**: Developers push code to GitHub repository
- **GitHub Actions**: Automated build, test, and deployment pipeline
- **AWS ECR**: Centralized container image registry for storing Docker images
- **ArgoCD**: GitOps-based continuous deployment tool that syncs desired state from Git to Kubernetes

### 2. **Load Balancing**
- **VIP Load Balancers (Primary & Standby)**: Distribute incoming traffic across Kubernetes cluster
- High availability configuration with automatic failover

### 3. **Kubernetes Cluster**
- **Control Plane (Master Nodes)**: 
  - API Server, Scheduler, Controller Manager
  - etcd for distributed configuration storage
  - 3x Master nodes for high availability
  
- **Worker Nodes**: Run containerized applications with multiple replicas for redundancy
  
- **Ingress Controller**: Routes external HTTP/HTTPS traffic to appropriate services
  - SSL/TLS termination
  - URL-based routing

### 4. **Application Tiers**

#### Web Tier (Frontend)
- Nginx-based frontend pods running in Kubernetes
- Multiple replicas for load distribution
- Horizontal Pod Autoscaler (HPA) for dynamic scaling based on CPU/Memory metrics

#### WAS Tier (Application)
- Java/Go-based application servers running as containerized workloads
- Multiple replicas for fault tolerance and load balancing
- Horizontal Pod Autoscaler (HPA) for automatic scaling
- Service mesh integration for inter-pod communication

### 5. **Database Tier**
- **MySQL Group Replication**:
  - Primary (Active): Handles read/write operations
  - Replica (Standby): Handles read operations, provides high availability
  - Automatic failover in case of primary node failure
  
- **Persistent Volumes (PVC)**: Cloud-based storage backend for data persistence
  
- **Backup & Disaster Recovery**:
  - Automated backups with configurable retention policies
  - Replication to standby database
  - Point-in-time restore capabilities

### 6. **Monitoring & Logging**
- **Prometheus**: Metrics collection and alerting
  - Grafana dashboards for visualization
  - Custom metrics and SLOs
  
- **ELK Stack/Datadog**: Centralized logging
  - Log collection from all pods
  - Indexing and searching
  - Real-time monitoring and alerting

## Key Features

✅ **Cloud-Native Architecture**: Fully containerized with Kubernetes orchestration  
✅ **High Availability**: Multi-node setup with automatic failover  
✅ **Auto-Scaling**: HPA for dynamic resource allocation  
✅ **CI/CD Automation**: GitOps-based deployment with ArgoCD  
✅ **Production-Grade**: Enterprise-ready monitoring, logging, and backup solutions  
✅ **Security**: SSL/TLS termination, network policies, RBAC  
✅ **Disaster Recovery**: Automated backups and multi-region capabilities
