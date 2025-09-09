# TO-DO List for Rails Project

이 문서는 `PRD.md`를 기반으로 실제 개발 작업을 추적하기 위한 체크리스트입니다.

### 1단계: 프로젝트 설정 및 핵심 모델 생성

- [x] Rails 프로젝트 생성 (`todolist`)
- [x] Ruby 버전 설정 (3.3.0) 및 `bundle install` 완료
- [ ] `Task` 모델 생성 (`content:string`, `done:boolean`, `done_at:datetime`)
- [ ] `User` 모델 생성 (`name:string`, `email:string`, `role:string`)
- [ ] 데이터베이스 마이그레이션 실행 (`rails db:migrate`)

### 2단계: TO-DO 핵심 기능 구현 (CRUD)

- [ ] `Tasks` 리소스에 대한 라우트 설정 (`config/routes.rb`)
- [ ] `Tasks` 컨트롤러 생성 및 CRUD 액션 구현
- [ ] 메인 페이지(`tasks#index`) UI 구현
    - [ ] 미완료된 Task 목록 표시
    - [ ] 새로운 Task를 추가하는 폼
- [ ] Task 생성 기능 구현
- [ ] Task 완료 기능 구현 (체크박스 클릭 시 `done` 및 `done_at` 업데이트)
- [ ] 완료된 Task는 메인 목록에 보이지 않도록 처리

### 3단계: 이메일 발송 기능 구현

- [ ] `ActionMailer` 기본 설정 (SMTP 정보는 `.env` 파일 사용)
- [ ] `TaskMailer` 생성
- [ ] 미완료 Task 목록을 보내는 메일 템플릿 작성
- [ ] `whenever` gem 설치 및 설정
- [ ] 매일 08:30, 13:00에 메일을 보내는 Rake Task 작성
- [ ] `config/schedule.rb`에 스케줄 등록

### 4단계: 관리자 기능 (사용자 관리)

- [ ] `devise` gem을 사용한 관리자 인증 기능 추가
- [ ] 관리자 전용 네임스페이스(e.g., `/admin`) 설정
- [ ] 관리자 페이지에서 `User` 모델 CRUD 기능 구현
- [ ] 관리자 페이지 접근 제어 (로그인한 관리자만 접근)

### 5단계: 배포

- [ ] 운영 환경용 데이터베이스를 PostgreSQL로 변경 설정
- [ ] Nginx + Passenger 배포 설정
- [ ] 서버에 배포
