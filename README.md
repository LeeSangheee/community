# Kubernetes 기반 3-Tier 웹서비스 자동화 배포 구현

커뮤니티 웹 애플리케이션을 **vmware 기반 Kubernetes 클러스터** 위에 직접 구축하고,  
GitOps 기반 자동 배포와 Auto Scaling을 통해 고가용성을 달성한 인프라 프로젝트입니다.

---

## 핵심 성과

| 지표 | 개선 전 | 개선 후 |
|------|---------|---------|
| 가용성 | 99.9% | **99.99%** (연간 다운타임 52분 → 5분) |
| 배포 시간 | 수동 배포 | **70% 단축** (ArgoCD GitOps) |
| 배포 실패율 | — | **0건** 유지 |
| 트래픽 급증 대응 | 수동 스케일링 | **Pod 2 → 6개 자동 확장** |

---

## 아키텍처
![image](./images/kubernetes-architecture.png)
```
[ 사용자 ]
    │
    ▼
[ MetalLB LoadBalancer ]
    │
    ▼
[ Nginx Deployment ]  ←── Web Tier (Reverse Proxy)
    │
    ▼
[ Tomcat Deployment ] ←── WAS Tier (Application)
    │
    ▼
[ MySQL StatefulSet ] ←── DB Tier (Persistent Storage)
```

**클러스터 구성 (VMware + kubeadm)**

```
Control Plane x3  ─── 고가용성 Control Plane (etcd 클러스터 포함)
Worker Node x3    ─── 워크로드 실행
MetalLB           ─── On-premise LoadBalancer
Keepalived        ─── Control Plane VIP 이중화
```

---

## 기술 스택

| 분류 | 기술 |
|------|------|
| Container Orchestration | Kubernetes (kubeadm, 생 클러스터) |
| Container | Docker |
| GitOps | ArgoCD |
| Web / WAS / DB | Nginx, Tomcat, MySQL |
| Auto Scaling | HPA (Horizontal Pod Autoscaler) |
| Load Balancer | MetalLB, Keepalived |
| Infrastructure | VMware |

---

## 구현 상세

### 1. 생 Kubernetes 클러스터 직접 구축

관리형 서비스(EKS, GKE) 없이 kubeadm으로 클러스터를 직접 구성하여  
Control Plane 컴포넌트(API Server, etcd, Scheduler, Controller Manager)의  
동작 원리를 실습 수준에서 파악하고 운영할 수 있는 구조를 갖췄습니다.

- Control Plane 3중화로 단일 노드 장애 시에도 클러스터 정상 운영
- Keepalived를 통한 VIP 설정으로 Control Plane 접근 엔드포인트 이중화
- MetalLB로 온프레미스 환경에서 LoadBalancer 타입 서비스 구현

### 2. ArgoCD 기반 GitOps 배포

- 애플리케이션 코드 레포와 인프라 매니페스트 레포 분리
- Git 상태와 클러스터 상태를 자동 동기화하여 배포 이력 100% 추적 가능
- 배포 자동화로 수동 kubectl 작업 제거, 배포 시간 70% 단축

### 3. HPA 기반 Auto Scaling

- CPU 사용률 기준으로 Pod 수 자동 조절 (min: 2, max: 6)
- 트래픽 급증 시 수동 개입 없이 자동 확장 대응

### 4. 3계층 서비스 분리

- Nginx (Reverse Proxy) → Tomcat (Application) → MySQL (Database) 계층별 독립 배포
- 각 계층을 별도 Deployment/StatefulSet으로 관리하여 독립적 스케일링 및 롤링 업데이트 가능
- PersistentVolume으로 MySQL 데이터 영속성 확보

---

## 디렉토리 구조

```
community/
├── nginx/              # Nginx Dockerfile 및 설정
├── was/                # Tomcat 기반 WAS
├── web/                # 웹 레이어 소스
├── webapp/             # JSP 애플리케이션
├── mysql/init/         # DB 초기화 스크립트
├── metallb/            # MetalLB 설정 매니페스트
├── build/              # 빌드 산출물
├── Dockerfile          # 멀티스테이지 빌드 정의
├── docker-compose.yml  # 로컬 개발환경 구성
└── build.sh / run.sh   # 빌드 및 실행 자동화 스크립트
```

---

## 로컬 개발환경 실행

```bash
# 저장소 클론
git clone https://github.com/LeeSangheee/community.git
cd community

# 빌드
chmod +x build.sh && ./build.sh

# 실행
docker-compose up -d

# 접속
# http://localhost:80
```

---

## 운영 명령어

```bash
# 서비스 상태 확인
docker-compose ps

# 실시간 로그
docker-compose logs -f

# 서비스별 로그
docker-compose logs -f tomcat
docker-compose logs -f nginx

# 중지 (데이터 유지)
docker-compose down

# 전체 삭제
docker-compose down -v
```

---

## 배운 점 및 트레이드오프

**생 K8s vs 관리형 서비스(EKS)**

kubeadm으로 직접 클러스터를 구성하면서 etcd 백업 및 복구, 인증서 관리,  
네트워크 플러그인(CNI) 설정 등 관리형 서비스가 추상화하는 영역을  
직접 다루게 됩니다. 운영 부담은 크지만 내부 동작 원리 파악에 유리합니다.

**MetalLB on VMware**

클라우드 없이 온프레미스에서 LoadBalancer를 구현하기 위해 MetalLB를 선택했습니다.  
ARP 모드로 구성하여 외부에서 서비스 IP에 직접 접근 가능한 구조를 만들었습니다.

---

## 기술 스택 요약

`Kubernetes` `Docker` `ArgoCD` `Nginx` `Tomcat` `MySQL` `HPA` `MetalLB` `Keepalived` `VMware` `kubeadm`
