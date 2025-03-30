# K8S 도커기반 환경 구성 매뉴얼
---
### 1. Docker 네트워크 생성

Kubernetes 마스터 및 워커 컨테이너 간의 통신을 가능하게 하기 위해 사용자 정의 브리지 네트워크를 생성합니다.  
Docker의 기본 네트워크인 `bridge`는 컨테이너 이름 기반 통신을 지원하지 않기 때문에, 컨테이너 간 안정적인 DNS 이름 기반 통신을 위해 `k8s-net` 네트워크를 생성합니다.

예시: AWS VPC 구성

 코드
```bash
docker network create \
  --driver=bridge \
  --subnet=192.168.100.0/24 \
  --gateway=192.168.100.1 \
  k8s-net
```

---

### 2. Docker 이미지 Build
1. Ubuntu
   
- master-node
     
```bash
docker buildx build --platform linux/arm64 \
  -f ubuntu/Dockerfile.master \
  -t ubuntu-k8s-master .
```
   
- work-node
     
```bash
docker buildx build --platform linux/arm64 \
  -f ubuntu/Dockerfile.work \
  -t ubuntu-k8s-work .
```
2. Redhat
   
- master-node
     
```bash
docker buildx build --platform linux/arm64 \
  -f redhat/Dockerfile.master \
  -t redhat-k8s-master .
```
   
- work-node
     
```bash
docker buildx build --platform linux/arm64 \
  -f redhat/Dockerfile.work \
  -t redhat-k8s-work .
```

---

### 3. Docker 컨테이너 실행(예시:RedHat 이미지)

master-node 고정IP `192.168.100.240`

worker-node 고정IP `192.168.100.24N` (0<N<10)


1. master-node 실행 
```bash
docker run -d --name k8s-master \
    --hostname k8s-master \
    --privileged \
    --network k8s-net \
    --ip 192.168.100.240 \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    redhat-k8s-master
```

2. work-node 실행
```bash
docker run -d --name k8s-worker1 \
    --hostname k8s-worker1 \
    --privileged \
    --network k8s-net \
    --ip 192.168.100.241 \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    redhat-k8s-worker
```

---


### 4. Master-Node 환경 구성

1. 마스터 노드 초기화

- Calico의 기본 Pod CIDR은 `192.168.0.0/16` 이므로 **반드시** 일치해야 함

  ```bash
  kubeadm init \
    --pod-network-cidr=192.168.0.0/16 \
    --service-cidr=10.96.0.0/12 \
    --apiserver-advertise-address=192.168.100.240
  ```

2. Calico CNI 설치

- coredns, kube-proxy 등이 모두 정상 Running 상태가 되도록 기다림
- 설치 후 kubectl get pods -n kube-system 확인

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
    ```


3. MetalLB 설치 및 설정
- MetalLB 배포
   
    ```bash
    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.10/config/manifests/metallb-native.yaml
    ```
- MetalLB metallb-config.yaml 작성
  
    ```yaml
    # metallb-config.yaml
    apiVersion: metallb.io/v1beta1
    kind: IPAddressPool
    metadata:
    name: my-ip-pool
    namespace: metallb-system
    spec:
    addresses:
        - 192.168.100.241-192.168.100.250
    ---
    apiVersion: metallb.io/v1beta1
    kind: L2Advertisement
    metadata:
    name: l2-adv
    namespace: metallb-system
    ```

- metallb-config 적용

    ```bash
    kubectl apply -f metallb-config.yaml
    ```


1. NGINX Ingress Controller 설치
- 설치 완료 후 kubectl get svc -n ingress-nginx로 외부 IP(LB) 부여 확인
- MetalLB가 IP를 할당해야 정상적으로 EXTERNAL-IP가 생김

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.3/deploy/static/provider/cloud/deploy.yaml
    ```

---


### 5. Work-Node Join

   ```bash
   # 마스터에서 출력된 명령어 복사
   kubeadm join 192.168.100.240:6443 \
        --token <your-token> \
        --discovery-token-ca-cert-hash sha256:<hash>
   
   ```

