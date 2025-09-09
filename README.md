# 📝 TodoList - 스마트한 할 일 관리

Rails 8.0 기반의 모던하고 직관적인 할 일 관리 웹 애플리케이션입니다. 
반복할일 기능과 이메일 리마인더를 제공하여 생산성을 극대화할 수 있습니다.

![TodoList Screenshot](web.png)

## ✨ 주요 기능

- **📋 할일 관리**: 할일 추가, 완료 처리, 삭제 기능
- **🔄 반복할일**: 일일, 주간, 월간 반복 작업 자동 생성
- **📧 이메일 리마인더**: 매일 08:30, 13:00, 17:00에 자동 발송
- **📊 진행률 추적**: 실시간 완료율과 통계 대시보드
- **🎨 반응형 UI**: 모바일과 데스크톱 모두 최적화된 디자인
- **⚡ 접기/펴기**: 완료된 할일과 반복할일 목록 관리

## 🛠 기술 스택

- **Backend**: Ruby 3.3.6, Rails 8.0.2+
- **Database**: SQLite3 (Solid Cache/Queue/Cable)
- **Frontend**: Turbo/Stimulus (Hotwire), Tailwind CSS 4.x
- **Email**: ActionMailer with SMTP
- **Deployment**: Docker, Docker Compose
- **Process Management**: Foreman (개발), Cron (스케줄링)

## 🚀 빠른 시작

### Docker를 사용한 배포 (권장)

```bash
# 저장소 클론
git clone https://github.com/ralph0830/todo-list.git
cd todo-list

# 환경 변수 설정
cp production.env.example production.env
# production.env 파일을 편집하여 SMTP 설정 및 이메일 주소 입력

# Docker 컨테이너 빌드 및 실행
docker compose build
docker compose up -d

# 애플리케이션 접속
open http://localhost:4204
```

### 로컬 개발 환경

```bash
# 의존성 설치
bundle install
npm install

# 데이터베이스 설정
rails db:create
rails db:migrate
rails db:seed

# CSS 빌드
npm run build:css

# 개발 서버 실행
foreman start -f Procfile.dev
```

## ⚙️ 환경 설정

### 필수 환경변수

```env
# Gmail SMTP 설정
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your_gmail@gmail.com
SMTP_PASSWORD=your_app_password
MAILER_SENDER=your_gmail@gmail.com

# 이메일 수신자 (쉼표로 구분)
REMINDER_EMAILS=email1@example.com,email2@example.com

# 애플리케이션 URL
APP_URL=http://localhost:4204

# Rails 보안키 (프로덕션 필수)
SECRET_KEY_BASE=your_generated_secret_key
```

### Gmail 앱 비밀번호 생성

1. Google 계정 > 보안 > 2단계 인증 활성화
2. 앱 비밀번호 생성 > "기타(사용자 설정 이름)" 선택
3. 생성된 16자리 비밀번호를 `SMTP_PASSWORD`에 입력

## 📱 사용 방법

### 할일 관리
- **추가**: 상단 입력창에 할일 내용 입력 후 "추가하기" 클릭
- **완료**: 할일 왼쪽 체크박스 클릭으로 완료/미완료 토글
- **삭제**: 할일 우측 X 버튼 클릭 후 확인

### 반복할일 설정
1. 할일 입력 후 반복 주기 선택:
   - **일일**: 월~금 08:30에 자동 생성
   - **주간**: 매주 월요일 08:30에 생성
   - **월간**: 매월 1일 08:30에 생성
2. "추가하기" 클릭으로 반복할일 등록
3. 반복할일 목록에서 개별 삭제 가능

### 이메일 리마인더
- **자동 발송**: 매일 08:30, 13:00, 17:00
- **내용**: 진행중인 할일, 오늘 완료한 할일 목록
- **수신자**: 환경변수 `REMINDER_EMAILS`에 설정된 이메일 주소

## 🔧 관리자 명령어

### Docker 환경

```bash
# 컨테이너 상태 확인
docker compose ps

# 로그 확인
docker compose logs -f

# 테스트 이메일 발송
docker compose exec todolist bundle exec rails todo_reminder:test_email

# 수동 리마인더 발송
docker compose exec todolist bundle exec rails todo_reminder:send_reminders

# 크론 작업 상태 확인
docker compose exec todolist crontab -l

# 데이터베이스 마이그레이션
docker compose exec todolist bundle exec rails db:migrate RAILS_ENV=production
```

### 로컬 개발

```bash
# 테스트 실행
rails test

# 코드 스타일 검사
rubocop

# 보안 취약점 검사
brakeman

# CSS 빌드 (감시 모드)
npm run build:css -- --watch
```

## 📂 프로젝트 구조

```
todo-list/
├── app/
│   ├── controllers/          # 컨트롤러
│   │   ├── tasks_controller.rb
│   │   └── recurring_tasks_controller.rb
│   ├── models/               # 모델
│   │   ├── task.rb
│   │   └── recurring_task.rb
│   ├── views/                # 뷰 템플릿
│   │   ├── tasks/
│   │   └── todo_reminder_mailer/
│   └── mailers/              # 메일러
│       └── todo_reminder_mailer.rb
├── config/
│   ├── schedule.rb           # Cron 스케줄 설정
│   └── routes.rb            # 라우팅 설정
├── lib/tasks/               # Rake 태스크
│   ├── todo_reminder.rake
│   └── recurring_tasks.rake
├── docker-compose.yml       # Docker 설정
├── Dockerfile              # Docker 이미지 설정
└── production.env          # 프로덕션 환경변수
```

## 🐳 Docker 설정

### 서비스 구성
- **todolist-app**: Rails 애플리케이션 (포트: 4204)
- **자동 실행**: 데이터베이스 마이그레이션, 크론 작업 설정

### 볼륨 마운트
- `./storage:/app/storage`: SQLite 데이터베이스 영속성
- `./log:/app/log`: 애플리케이션 로그
- `./screenshots:/app/screenshots`: 스크린샷 저장

## 🧪 테스트

```bash
# 전체 테스트 실행
rails test

# 특정 테스트 파일 실행
rails test test/models/task_test.rb
rails test test/controllers/tasks_controller_test.rb

# 모델 테스트
rails test test/models/

# 컨트롤러 테스트
rails test test/controllers/
```

## 📊 모니터링

### 로그 파일
- `log/production.log`: 애플리케이션 로그
- `log/cron.log`: 크론 작업 실행 로그

### 헬스체크
```bash
# 애플리케이션 상태 확인
curl http://localhost:4204

# 이메일 설정 확인
docker compose exec todolist bundle exec rails todo_reminder:show_config
```

## 🔒 보안

- **CSRF 보호**: Rails 기본 CSRF 토큰 사용
- **환경변수**: 민감한 정보는 환경변수로 관리
- **SMTP 보안**: STARTTLS를 통한 암호화된 이메일 전송
- **Brakeman**: 정적 보안 분석 도구 포함

## 📝 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 🤝 기여

1. 이 저장소를 포크합니다
2. 기능 브랜치를 생성합니다 (`git checkout -b feature/amazing-feature`)
3. 변경사항을 커밋합니다 (`git commit -m 'Add some amazing feature'`)
4. 브랜치에 푸시합니다 (`git push origin feature/amazing-feature`)
5. Pull Request를 생성합니다

## 📞 지원

문제가 발생하거나 기능 요청이 있으시면 [Issues](https://github.com/ralph0830/todo-list/issues)를 통해 연락해 주세요.

---

**Made with ❤️ & Rails 8.0**

🤖 Generated with [Claude Code](https://claude.ai/code)