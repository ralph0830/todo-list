class TodoReminderMailer < ApplicationMailer
  default from: ENV.fetch('MAILER_SENDER', 'noreply@todolist.com')

  def daily_reminder(email, incomplete_tasks, completed_tasks)
    @email = email
    @incomplete_tasks = incomplete_tasks
    @completed_tasks = completed_tasks
    @total_tasks = incomplete_tasks.count + completed_tasks.count
    @completion_rate = @total_tasks > 0 ? (completed_tasks.count.to_f / @total_tasks * 100).round : 0
    @app_url = ENV.fetch('APP_URL', 'http://localhost:3000')
    
    # 시간대별 인사말
    current_hour = Time.current.hour
    @greeting = case current_hour
               when 5..11
                 "좋은 아침입니다! ☀️"
               when 12..17
                 "좋은 오후입니다! 🌤️"
               when 18..21
                 "좋은 저녁입니다! 🌅"
               else
                 "안녕하세요! 👋"
               end

    # 동기부여 메시지
    @motivation = if @incomplete_tasks.count == 0
                   "모든 할 일을 완료하셨네요! 정말 대단해요! 🎉"
                 elsif @completion_rate >= 80
                   "거의 다 끝났어요! 조금만 더 힘내세요! 💪"
                 elsif @completion_rate >= 50
                   "절반 이상 완료하셨네요! 계속 화이팅! 🔥"
                 elsif @incomplete_tasks.count > 5
                   "할 일이 많네요! 하나씩 차근차근 해보세요! 📝"
                 else
                   "오늘도 계획한 일들을 차근차근 해보세요! ✨"
                 end

    mail(
      to: email,
      subject: "📋 TodoList 리마인더 - #{Time.current.strftime('%m월 %d일')} #{Time.current.strftime('%H:%M')}"
    )
  end
end
