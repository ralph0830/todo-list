class Task < ApplicationRecord
  belongs_to :recurring_task, optional: true
  
  def recurring?
    recurring_task_id.present?
  end
  
  def recurring_frequency_display
    return nil unless recurring?
    
    case recurring_task.frequency
    when 'daily'
      '일일'
    when 'weekly'
      '주간'
    when 'monthly'
      '월간'
    else
      nil
    end
  end
end
