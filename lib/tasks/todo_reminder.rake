# Array에 limit 메서드 추가 (ActiveRecord와 호환성을 위해)
class Array
  def limit(count)
    self.first(count)
  end
end

namespace :todo_reminder do
  desc "Send daily todo reminder emails to configured recipients"
  task send_reminders: :environment do
    puts "🚀 Starting todo reminder email sending task..."
    puts "Time: #{Time.current.strftime('%Y-%m-%d %H:%M:%S %Z')}"
    
    # 환경 변수에서 이메일 목록 가져오기
    reminder_emails = ENV.fetch('REMINDER_EMAILS', '').split(',').map(&:strip).reject(&:empty?)
    
    if reminder_emails.empty?
      puts "⚠️  No reminder emails configured in REMINDER_EMAILS environment variable."
      puts "Please set REMINDER_EMAILS in your .env file."
      exit(1)
    end
    
    puts "📧 Configured recipients: #{reminder_emails.join(', ')}"
    
    # 할 일 데이터 가져오기 (완료된 할 일은 오늘 것만)
    incomplete_tasks = Task.where(done: false).order(:created_at)
    completed_tasks = Task.where(done: true)
                         .where('done_at >= ?', Time.current.beginning_of_day)
                         .order(:created_at)
    
    puts "📊 Task summary:"
    puts "   - Total tasks: #{incomplete_tasks.count + completed_tasks.count}"
    puts "   - Incomplete tasks: #{incomplete_tasks.count}"
    puts "   - Completed tasks: #{completed_tasks.count}"
    
    # 각 수신자에게 이메일 발송
    successful_sends = 0
    failed_sends = 0
    
    reminder_emails.each do |email|
      begin
        puts "📤 Sending reminder email to: #{email}"
        
        TodoReminderMailer.daily_reminder(
          email,
          incomplete_tasks,
          completed_tasks
        ).deliver_now
        
        successful_sends += 1
        puts "✅ Successfully sent to #{email}"
        
      rescue => e
        failed_sends += 1
        puts "❌ Failed to send to #{email}: #{e.message}"
        puts "   Error details: #{e.class}: #{e.backtrace&.first}"
      end
    end
    
    puts "\n📈 Email sending summary:"
    puts "   - Successful sends: #{successful_sends}"
    puts "   - Failed sends: #{failed_sends}"
    puts "   - Total recipients: #{reminder_emails.count}"
    
    if failed_sends > 0
      puts "\n⚠️  Some emails failed to send. Please check your SMTP configuration in .env file."
      puts "Current SMTP settings:"
      puts "   - Host: #{ENV['SMTP_ADDRESS']}"
      puts "   - Port: #{ENV['SMTP_PORT']}"
      puts "   - Username: #{ENV['SMTP_USERNAME']}"
      puts "   - From email: #{ENV['MAILER_SENDER']}"
    else
      puts "\n🎉 All reminder emails sent successfully!"
    end
    
    puts "✨ Todo reminder task completed at #{Time.current.strftime('%Y-%m-%d %H:%M:%S %Z')}"
  end
  
  desc "Test email sending (send to first configured recipient only)"
  task test_email: :environment do
    puts "🧪 Testing todo reminder email functionality..."
    
    # 환경 변수에서 첫 번째 이메일 가져오기
    reminder_emails = ENV.fetch('REMINDER_EMAILS', '').split(',').map(&:strip).reject(&:empty?)
    
    if reminder_emails.empty?
      puts "❌ No test email configured. Please set REMINDER_EMAILS in your .env file."
      exit(1)
    end
    
    puts "📧 Test recipients: #{reminder_emails.join(', ')}"
    
    # 테스트 데이터 생성 (실제 DB 데이터가 없는 경우)
    incomplete_tasks = Task.where(done: false).order(:created_at)
    completed_tasks = Task.where(done: true)
                         .where('done_at >= ?', Time.current.beginning_of_day)
                         .order(:created_at)
    
    if incomplete_tasks.empty? && completed_tasks.empty?
      puts "⚠️  No tasks found in database. Creating sample tasks for testing..."
      
      # 임시로 샘플 task 객체들을 생성 (DB에 저장하지 않음)
      TaskStruct = Struct.new(:content, :done)
      sample_incomplete = [
        TaskStruct.new("테스트 할 일 1", false),
        TaskStruct.new("테스트 할 일 2", false),
        TaskStruct.new("중요한 회의 참석", false)
      ]
      
      sample_completed = [
        TaskStruct.new("이메일 확인", true),
        TaskStruct.new("문서 정리", true)
      ]
      
      incomplete_tasks = sample_incomplete
      completed_tasks = sample_completed
    end
    
    # 각 수신자에게 테스트 이메일 발송
    successful_sends = 0
    failed_sends = 0
    
    reminder_emails.each do |email|
      begin
        puts "📤 Sending test email to: #{email}"
        
        TodoReminderMailer.daily_reminder(
          email,
          incomplete_tasks,
          completed_tasks
        ).deliver_now
        
        successful_sends += 1
        puts "✅ Successfully sent to #{email}"
        
      rescue => e
        failed_sends += 1
        puts "❌ Failed to send to #{email}: #{e.message}"
        puts "   Error details: #{e.class}: #{e.backtrace&.first}"
      end
    end
    
    puts "\n📈 Test email summary:"
    puts "   - Successful sends: #{successful_sends}"
    puts "   - Failed sends: #{failed_sends}"
    puts "   - Total recipients: #{reminder_emails.count}"
    
    if failed_sends > 0
      puts "\n⚠️  Some test emails failed. Please check your SMTP configuration."
      puts "💡 SMTP settings:"
      puts "   - SMTP_ADDRESS: #{ENV['SMTP_ADDRESS']}"
      puts "   - SMTP_PORT: #{ENV['SMTP_PORT']}"
      puts "   - SMTP_USERNAME: #{ENV['SMTP_USERNAME']}"
      puts "   - MAILER_SENDER: #{ENV['MAILER_SENDER']}"
      
      puts "\n🔍 Common issues:"
      puts "   1. Incorrect SMTP credentials"
      puts "   2. App-specific password required (Gmail, etc.)"
      puts "   3. SMTP server blocking connections"
      puts "   4. Firewall/network restrictions"
    else
      puts "\n🎉 All test emails sent successfully!"
      puts "📱 Please check your email inbox/spam folders."
    end
  end
  
  desc "Show current reminder configuration"
  task show_config: :environment do
    puts "📋 Todo Reminder Configuration"
    puts "=" * 50
    puts "Current time: #{Time.current.strftime('%Y-%m-%d %H:%M:%S %Z')}"
    puts "Timezone: #{ENV.fetch('TZ', Time.zone.name)}"
    puts ""
    
    puts "📧 Email Configuration:"
    puts "SMTP Host: #{ENV['SMTP_ADDRESS'] || 'Not configured'}"
    puts "SMTP Port: #{ENV['SMTP_PORT'] || 'Not configured'}"
    puts "SMTP Username: #{ENV['SMTP_USERNAME'] || 'Not configured'}"
    puts "From Email: #{ENV['MAILER_SENDER'] || 'Not configured'}"
    puts ""
    
    puts "📬 Recipients:"
    reminder_emails = ENV.fetch('REMINDER_EMAILS', '').split(',').map(&:strip).reject(&:empty?)
    if reminder_emails.any?
      reminder_emails.each_with_index do |email, index|
        puts "#{index + 1}. #{email}"
      end
    else
      puts "⚠️  No recipients configured"
    end
    puts ""
    
    puts "⏰ Scheduled Times:"
    reminder_times = ENV.fetch('REMINDER_TIMES', '08:00,13:00,17:00').split(',').map(&:strip)
    reminder_times.each_with_index do |time, index|
      puts "#{index + 1}. #{time}"
    end
    puts ""
    
    puts "🌐 App URL: #{ENV.fetch('APP_URL', 'http://localhost:3000')}"
    puts ""
    
    puts "📊 Current Task Statistics:"
    incomplete_count = Task.where(done: false).count rescue 0
    completed_count = Task.where(done: true).count rescue 0
    total_count = incomplete_count + completed_count
    
    puts "Total Tasks: #{total_count}"
    puts "Incomplete: #{incomplete_count}"
    puts "Completed: #{completed_count}"
    puts "Completion Rate: #{total_count > 0 ? ((completed_count.to_f / total_count * 100).round(1)) : 0}%"
  end
end