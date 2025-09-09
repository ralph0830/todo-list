#!/bin/bash
set -e

echo "🚀 TodoList 애플리케이션 시작 중..."

# 환경변수 확인
echo "환경: ${RAILS_ENV:-production}"
echo "포트: ${PORT:-4204}"
echo "시간대: ${TZ:-Asia/Seoul}"

# 시간대 설정
if [ -n "$TZ" ]; then
  echo "시간대 설정: $TZ"
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
fi

# JavaScript 의존성 설치
echo "📦 JavaScript 의존성 설치 중..."
npm install --production 2>/dev/null || echo "npm install 건너뜀"

# 데이터베이스 준비
echo "📊 데이터베이스 준비 중..."
bundle exec rails db:create RAILS_ENV=production 2>/dev/null || echo "데이터베이스가 이미 존재합니다."
bundle exec rails db:migrate RAILS_ENV=production

# 자산 사전 컴파일
echo "🎨 자산 컴파일 중..."
RAILS_ENV=production bundle exec rails assets:precompile 2>/dev/null || echo "자산 컴파일 건너뜀"

# Cron 작업 설정
echo "⏰ Cron 작업 설정 중..."

# whenever를 사용해서 crontab 업데이트
bundle exec whenever --update-crontab --set environment=production

# cron 서비스 시작
service cron start

# cron 작업이 제대로 설정되었는지 확인
echo "📋 설정된 Cron 작업:"
crontab -l

# 애플리케이션 정보 출력
echo "🌟 TodoList 애플리케이션 정보:"
echo "- 환경: ${RAILS_ENV:-production}"
echo "- 포트: ${PORT:-4204}"
echo "- 시간대: ${TZ:-Asia/Seoul}"
echo "- 크론 작업: 매일 08:00, 13:00, 17:00에 리마인더 이메일 발송"

# 로그 디렉토리 생성
mkdir -p /app/log

echo "✅ 초기화 완료! Rails 서버를 시작합니다..."

# Rails 서버 실행
exec bundle exec rails server -b 0.0.0.0 -p 4204 -e production
