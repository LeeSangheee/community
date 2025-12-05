# Community Web Application

RAPA 커뮤니티 웹 애플리케이션

## 🚀 빠른 시작

### 필수 요구사항
- Docker & Docker Compose
- JDK 17+
- Git

### 실행 방법
```bash
# 1. 저장소 클론
git clone https://github.com/username/community-docker.git
cd community-docker

# 2. 빌드
./build.sh

# 3. 실행
docker-compose up -d

# 4. 접속
http://localhost/
```

### 중지
```bash
docker-compose down
```

### 완전 삭제 (데이터 포함)
```bash
docker-compose down -v
```

## 📂 프로젝트 구조
```
community-docker/
├── src/                    # Java 소스 코드
├── webapp/                 # 웹 리소스 (JSP, CSS, 이미지)
├── nginx/                  # Nginx 설정
├── mysql/                  # MySQL 초기화 스크립트
├── tomcat-config/          # Tomcat 설정
├── docker-compose.yml      # Docker Compose 설정
├── Dockerfile              # Tomcat 이미지
└── build.sh                # 빌드 스크립트
```

## 🛠️ 개발

### 로그 확인
```bash
# 전체 로그
docker-compose logs -f

# 특정 서비스 로그
docker-compose logs -f tomcat
docker-compose logs -f nginx
docker-compose logs -f mysql
```

### 데이터베이스 접속
```bash
docker exec -it community-mysql mysql -u appuser -papppass community
```

## 🔧 설정

### 포트 변경

`docker-compose.yml` 수정:
```yaml
services:
  nginx:
    ports:
      - "8000:80"  # 80 → 8000
  tomcat:
    ports:
      - "8081:8080"  # 8080 → 8081
```

### 데이터베이스 비밀번호 변경

`docker-compose.yml`과 `tomcat-config/context.xml` 수정