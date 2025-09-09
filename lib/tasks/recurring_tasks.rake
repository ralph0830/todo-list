namespace :recurring_tasks do
  desc "오늘 생성해야 하는 반복 할일들을 일반 할일로 생성합니다"
  task generate_daily: :environment do
    puts "🔄 반복 할일 생성 작업을 시작합니다..."
    
    generated_count = 0
    error_count = 0
    
    RecurringTask.active.each do |recurring_task|
      begin
        if recurring_task.should_generate_today?
          task = recurring_task.generate_task!
          generated_count += 1
          puts "✅ 생성됨: #{task.content}"
        else
          puts "⏭️  건너뜀: #{recurring_task.content} (오늘 생성 불필요 또는 이미 생성됨)"
        end
      rescue => e
        error_count += 1
        puts "❌ 오류: #{recurring_task.content} - #{e.message}"
      end
    end
    
    puts "\n📊 생성 결과:"
    puts "   - 생성된 할일: #{generated_count}개"
    puts "   - 오류 발생: #{error_count}개"
    puts "   - 총 활성 반복 할일: #{RecurringTask.active.count}개"
    puts "✨ 작업 완료!"
  end
  
  desc "반복 할일 상태를 확인합니다"
  task status: :environment do
    puts "📋 반복 할일 현황"
    puts "=" * 50
    
    total_count = RecurringTask.count
    active_count = RecurringTask.active.count
    inactive_count = total_count - active_count
    
    puts "전체 반복 할일: #{total_count}개"
    puts "활성 반복 할일: #{active_count}개"
    puts "비활성 반복 할일: #{inactive_count}개"
    puts
    
    if active_count > 0
      puts "📅 오늘 생성 예정인 반복 할일:"
      RecurringTask.active.each do |recurring_task|
        status = recurring_task.should_generate_today? ? "✅ 생성 예정" : "⏭️  건너뜀"
        frequency_text = case recurring_task.frequency
                        when 'daily' then '매일'
                        when 'weekly' then "매주 #{recurring_task.weekdays_array.map{|d| %w[일 월 화 수 목 금 토][d]}.join(', ')}"
                        when 'monthly' then "매월 #{recurring_task.monthly_day}일"
                        end
        puts "   #{status} - #{recurring_task.content} (#{frequency_text})"
      end
    else
      puts "활성화된 반복 할일이 없습니다."
    end
  end
  
  desc "테스트용 반복 할일을 생성합니다"
  task create_samples: :environment do
    puts "🧪 테스트용 반복 할일을 생성합니다..."
    
    sample_tasks = [
      {
        content: "아침 운동하기",
        frequency: "daily",
        description: "매일 아침 30분 운동"
      },
      {
        content: "주간 회의 참석",
        frequency: "weekly", 
        weekdays: "1,3,5", # 월, 수, 금
        description: "팀 미팅 참석"
      },
      {
        content: "월급 관리",
        frequency: "monthly",
        monthly_day: 25,
        description: "매월 가계부 정리"
      }
    ]
    
    created_count = 0
    
    sample_tasks.each do |task_data|
      begin
        RecurringTask.create!(task_data)
        created_count += 1
        puts "✅ 생성됨: #{task_data[:content]}"
      rescue => e
        puts "❌ 오류: #{task_data[:content]} - #{e.message}"
      end
    end
    
    puts "\n📊 #{created_count}개의 테스트 반복 할일이 생성되었습니다."
  end
end