# Ruby 3.3.6 기반 이미지 사용
FROM ruby:3.3.6-slim

# 작업 디렉토리 설정
WORKDIR /app

# 시스템 의존성 설치
RUN apt-get update -qq &&     apt-get install -y --no-install-recommends     build-essential     libsqlite3-dev     nodejs     npm     curl     cron     tzdata &&     rm -rf /var/lib/apt/lists/*

# 번들러 설치
RUN gem install bundler

# Gemfile 복사 및 의존성 설치
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local deployment 'true' &&     bundle config set --local without 'development test' &&     bundle install

# 애플리케이션 코드 복사
COPY . .

# Node.js 의존성 설치 및 CSS 빌드
RUN npm install
RUN npm run build:css

# Rails 애셋 프리컴파일
RUN bundle exec rails assets:precompile RAILS_ENV=production

# 시간대 설정
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/ /etc/localtime && echo  > /etc/timezone

# 포트 노출
EXPOSE 4204

# Rails 서버 직접 실행
CMD ["bash", "-c", "bundle exec rails db:create RAILS_ENV=production 2>/dev/null || true && bundle exec rails db:migrate RAILS_ENV=production && service cron start && bundle exec whenever --update-crontab --set environment=production && bundle exec rails server -b 0.0.0.0 -p 4204 -e production"]
