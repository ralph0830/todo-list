# TodoList 리마인더 이메일 스케줄 설정
# 매일 08:00, 13:00, 17:00에 리마인더 이메일 발송

# 환경 설정
set :environment, 'production'
set :output, '/app/log/cron.log'

# 시간대 설정 (한국 시간)
set :chronic_options, :time_zone => 'Asia/Seoul'

# PATH와 bundler 경로 설정
ENV.each { |k, v| env(k, v) }
set :path, '/app'

# 절대 경로를 사용한 rake 실행
job_type :rake_with_env, 'cd /app && /usr/local/bin/bundle exec rake :task RAILS_ENV=production >> /app/log/cron.log 2>&1'

# 매일 07:00 (반복 할일 생성) - 리마인더보다 먼저 실행
every 1.day, at: '7:00 am' do
  rake_with_env 'recurring_tasks:generate_daily'
end

# 매일 08:30 (아침 리마인더)
every 1.day, at: '8:30 am' do
  rake_with_env 'todo_reminder:send_reminders'
end

# 매일 13:00 (점심 리마인더)  
every 1.day, at: '1:00 pm' do
  rake_with_env 'todo_reminder:send_reminders'
end

# 매일 17:00 (오후 리마인더)
every 1.day, at: '5:00 pm' do
  rake_with_env 'todo_reminder:send_reminders'
end

# 테스트용 - 매분마다 실행 (개발 중에만 사용, 실제 운영에서는 주석 처리)
# every 1.minute do
#   rake_with_env 'todo_reminder:send_reminders'
# end

# 예시: 매일 자정에 완료된 오래된 할 일들 정리 (필요시 활용)
# every 1.day, at: '12:00 am' do
#   rake_with_env 'todo:cleanup_old_completed'
# end

# 예시: 매주 월요일 오전 9시에 주간 리포트 (필요시 활용)
# every :monday, at: '9:00 am' do
#   rake_with_env 'todo_reminder:send_weekly_report'
# end
