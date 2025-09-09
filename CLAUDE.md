# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

이 프로젝트는 Rails 8.0 기반의 할 일 관리(Todo) 웹 애플리케이션입니다. Docker를 통한 배포를 지원하며, 자동 이메일 리마인더 기능을 포함합니다.

## 개발 환경 설정

### 로컬 개발 실행
```bash
# 의존성 설치
bundle install
yarn install

# 데이터베이스 설정
rails db:create
rails db:migrate
rails db:seed

# CSS 빌드
yarn build:css

# 개발 서버 실행 (Foreman 사용)
foreman start -f Procfile.dev

# 또는 개별 실행
rails server -p 4204
yarn build:css --watch
```

### 테스트 실행
```bash
# 전체 테스트 실행
rails test

# 특정 테스트 파일 실행
rails test test/models/task_test.rb
rails test test/controllers/tasks_controller_test.rb

# 특정 테스트 메서드 실행
rails test test/models/task_test.rb:test_should_create_task
```

### 코드 품질 검사
```bash
# RuboCop (코딩 스타일 검사)
rubocop

# Brakeman (보안 취약점 검사)
brakeman
```

## 아키텍처 구조

### 핵심 모델 관계
- **Task**: 할 일 항목 (content, done, done_at)
- **User**: 사용자 정보 (현재 사용되지 않음, 향후 인증 기능용)

### 컨트롤러 구조
- **TasksController**: CRUD 작업, 완료/미완료 토글 기능
- **ApplicationController**: 기본 컨트롤러

### 이메일 시스템
- **TodoReminderMailer**: 일일 리마인더 이메일 발송
- **lib/tasks/todo_reminder.rake**: 이메일 발송 Rake 태스크
- **config/schedule.rb**: Whenever gem을 통한 cron 스케줄링

### 프론트엔드 스택
- **Rails 8.0** with Turbo/Stimulus
- **Tailwind CSS** (v4.x) with Propshaft
- **Importmap** for JavaScript module management

## 배포 및 운영

### Docker 배포
```bash
# 이미지 빌드
docker-compose build

# 컨테이너 실행
docker-compose up -d

# 로그 확인
docker-compose logs -f
```

### 이메일 기능 관리
```bash
# 테스트 이메일 발송
docker-compose exec todolist bundle exec rails todo_reminder:test_email

# 설정 확인
docker-compose exec todolist bundle exec rails todo_reminder:show_config

# 수동 리마인더 발송
docker-compose exec todolist bundle exec rails todo_reminder:send_reminders
```

## 환경 변수 설정

개발 환경에서는 `.env` 파일, 프로덕션에서는 `production.env` 파일 사용:

```env
# Gmail SMTP 설정
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your_gmail@gmail.com
SMTP_PASSWORD=your_app_password
MAILER_SENDER=your_gmail@gmail.com

# 이메일 수신자 (쉼표로 구분)
REMINDER_EMAILS=email1@example.com,email2@example.com

# 앱 URL
APP_URL=http://localhost:4204

# Rails 보안키 (프로덕션 필수)
SECRET_KEY_BASE=your_generated_secret_key
```

## 주요 기술 스택

- **Ruby 3.3+**
- **Rails 8.0.2+**
- **SQLite3** (개발/프로덕션)
- **Solid Cache/Queue/Cable** (Rails의 새로운 기본 어댑터)
- **Puma** 웹서버
- **Tailwind CSS 4.x**
- **Turbo/Stimulus** (Hotwire)
- **Whenever** (cron 스케줄링)
- **Foreman** (프로세스 관리)

## 특별 고려사항

1. **Rails 8.0 새 기능 사용**: Solid adapters, Propshaft 등 최신 Rails 기능 활용
2. **시간대 설정**: 한국 시간(Asia/Seoul) 기준으로 cron 작업 스케줄링
3. **이메일 템플릿**: HTML/텍스트 이중 형식 지원
4. **Docker 최적화**: 멀티스테이지 빌드 및 볼륨 마운트 구성
5. **보안**: Brakeman을 통한 정적 보안 분석 포함

## 파일 구조 주의사항

- `app/models/`: Task, User 모델 (User는 현재 미사용)
- `lib/tasks/`: 커스텀 Rake 태스크 (이메일 리마인더)
- `config/schedule.rb`: cron 작업 정의 (하루 3회 이메일 발송)
- `app/views/todo_reminder_mailer/`: 이메일 템플릿
- `docker-compose.yml`: 프로덕션 Docker 설정
- `Procfile.dev`: 개발 환경 프로세스 정의