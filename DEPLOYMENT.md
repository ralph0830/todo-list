# TodoList Docker 배포 가이드

Docker Compose를 사용하여 우분투 서버에 TodoList 애플리케이션을 배포하는 방법을 설명합니다.

## 📋 사전 요구사항

- Ubuntu Server (18.04 이상)
- Docker 및 Docker Compose 설치
- Git 설치
- Gmail 계정 (이메일 발송용)

## 🚀 배포 단계

### 1. 서버 환경 준비

```bash
# 시스템 업데이트
sudo apt update && sudo apt upgrade -y

# Docker 설치
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Docker Compose 설치 (최신 버전)
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 재로그인 또는 다음 명령어 실행
newgrp docker
```

### 2. 애플리케이션 코드 가져오기

```bash
# 프로젝트 복사 (방법 1: Git 사용)
git clone <your-repository-url>
cd todolist

# 또는 파일 직접 복사 (방법 2: SCP 사용)
scp -r /path/to/todolist user@server:/home/user/
```

### 3. 환경 설정

`production.env` 파일을 수정합니다:

```bash
# production.env 파일 편집
nano production.env
```

**중요 설정 항목:**

```env
# 보안 키 생성 및 설정
SECRET_KEY_BASE=your_generated_secret_key_here

# Gmail SMTP 설정
SMTP_USERNAME=your_gmail@gmail.com
SMTP_PASSWORD=your_app_password_here
MAILER_SENDER=your_gmail@gmail.com

# 수신자 이메일 (여러 개 가능)
REMINDER_EMAILS=email1@example.com,email2@example.com

# 서버 URL (실제 IP 또는 도메인으로 변경)
APP_URL=http://your-server-ip:4204
```

### 4. Gmail 앱 비밀번호 생성

1. Google 계정 설정 → 보안
2. 2단계 인증 활성화 (필수)
3. 앱 비밀번호 생성
4. 생성된 16자리 비밀번호를 `production.env`의 `SMTP_PASSWORD`에 입력

### 5. Secret Key Base 생성

로컬에서 비밀키를 생성합니다:

```bash
# 로컬에서 실행 (Rails가 설치된 환경)
bundle exec rails secret

# 출력된 키를 production.env의 SECRET_KEY_BASE에 복사
```

### 6. 애플리케이션 빌드 및 실행

```bash
# Docker 이미지 빌드
docker-compose build

# 백그라운드에서 컨테이너 실행
docker-compose up -d

# 로그 확인
docker-compose logs -f
```

### 7. 배포 확인

```bash
# 컨테이너 상태 확인
docker-compose ps

# 애플리케이션 접속 확인
curl http://localhost:4204

# 브라우저에서 접속
# http://your-server-ip:4204
```

## 📧 이메일 기능 테스트

```bash
# 컨테이너 내부에서 테스트 이메일 발송
docker-compose exec todolist bundle exec rails todo_reminder:test_email

# cron 작업 확인
docker-compose exec todolist crontab -l

# 설정 확인
docker-compose exec todolist bundle exec rails todo_reminder:show_config
```

## 🔧 관리 명령어

### 컨테이너 관리

```bash
# 서비스 중지
docker-compose stop

# 서비스 시작
docker-compose start

# 서비스 재시작
docker-compose restart

# 완전 종료 (컨테이너 삭제)
docker-compose down

# 로그 확인 (실시간)
docker-compose logs -f

# 컨테이너 내부 접속
docker-compose exec todolist bash
```

### 데이터베이스 관리

```bash
# DB 마이그레이션
docker-compose exec todolist bundle exec rails db:migrate RAILS_ENV=production

# Rails 콘솔 접속
docker-compose exec todolist bundle exec rails console RAILS_ENV=production
```

### 백업 및 복원

```bash
# SQLite 데이터베이스 백업
sudo cp ./db/production.sqlite3 ./db/production.sqlite3.backup

# 로그 파일 백업
sudo tar -czf logs_backup_$(date +%Y%m%d).tar.gz ./log/
```

## 🔄 업데이트 방법

```bash
# 서비스 중지
docker-compose down

# 코드 업데이트 (Git 사용 시)
git pull origin main

# 이미지 재빌드
docker-compose build --no-cache

# 서비스 시작
docker-compose up -d

# 마이그레이션 (필요시)
docker-compose exec todolist bundle exec rails db:migrate RAILS_ENV=production
```

## 🌐 방화벽 설정 (Ubuntu UFW)

```bash
# 포트 4204 열기
sudo ufw allow 4204

# SSH 포트 확인
sudo ufw allow 22

# 방화벽 활성화
sudo ufw enable

# 상태 확인
sudo ufw status
```

## 🚨 트러블슈팅

### 일반적인 문제들

1. **이메일 발송 실패**
   ```bash
   # 로그 확인
   docker-compose logs todolist
   
   # Gmail 설정 확인
   docker-compose exec todolist bundle exec rails todo_reminder:show_config
   ```

2. **데이터베이스 오류**
   ```bash
   # DB 권한 확인
   sudo chown -R 999:999 ./db
   
   # 마이그레이션 재실행
   docker-compose exec todolist bundle exec rails db:migrate RAILS_ENV=production
   ```

3. **크론 작업 실행 안됨**
   ```bash
   # 크론 상태 확인
   docker-compose exec todolist service cron status
   
   # 크론 재시작
   docker-compose exec todolist service cron restart
   ```

4. **포트 접근 불가**
   ```bash
   # 방화벽 확인
   sudo ufw status
   
   # 네트워크 확인
   docker network ls
   ```

## 📊 모니터링

### 시스템 리소스 확인

```bash
# Docker 컨테이너 리소스 사용량
docker stats

# 디스크 사용량
df -h

# 메모리 사용량
free -h
```

### 로그 모니터링

```bash
# 실시간 로그 모니터링
docker-compose logs -f --tail=100

# 특정 서비스 로그만 보기
docker-compose logs -f todolist
```

## ⚙️ 고급 설정

### Nginx 리버스 프록시 (선택사항)

```nginx
# /etc/nginx/sites-available/todolist
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://127.0.0.1:4204;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### SSL 인증서 (Let's Encrypt)

```bash
# Certbot 설치
sudo apt install certbot python3-certbot-nginx

# SSL 인증서 발급
sudo certbot --nginx -d your-domain.com
```

## 📞 지원

문제가 발생하면 다음을 확인하세요:

1. 로그 파일: `docker-compose logs`
2. 컨테이너 상태: `docker-compose ps`
3. 환경 변수: `production.env` 파일 확인
4. 네트워크: 방화벽 및 포트 설정 확인

---

**배포 완료!** 🎉

TodoList 애플리케이션이 성공적으로 배포되었습니다. 
매일 08:00, 13:00, 17:00에 자동으로 리마인더 이메일이 발송됩니다.