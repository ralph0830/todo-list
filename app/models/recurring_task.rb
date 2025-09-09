class RecurringTask < ApplicationRecord
  FREQUENCIES = %w[daily weekly monthly].freeze
  
  has_many :tasks, dependent: :destroy
  
  validates :content, presence: true
  validates :frequency, presence: true, inclusion: { in: FREQUENCIES }
  validates :weekdays, presence: true, if: :weekly?
  validates :monthly_day, presence: true, numericality: { in: 1..31 }, if: :monthly?
  
  scope :active, -> { where(active: true) }
  scope :daily, -> { where(frequency: 'daily') }
  scope :weekly, -> { where(frequency: 'weekly') }
  scope :monthly, -> { where(frequency: 'monthly') }
  
  def daily?
    frequency == 'daily'
  end
  
  def weekly?
    frequency == 'weekly'
  end
  
  def monthly?
    frequency == 'monthly'
  end
  
  def weekdays_array
    return [] unless weekdays.present?
    weekdays.split(',').map(&:to_i)
  end
  
  def weekdays_array=(days)
    self.weekdays = days.join(',') if days.is_a?(Array)
  end
  
  # 오늘 생성해야 하는지 체크
  def should_generate_today?
    return false unless active?
    
    today = Time.current.beginning_of_day
    
    # 이미 오늘 생성했는지 체크
    return false if last_generated_at&.beginning_of_day == today
    
    case frequency
    when 'daily'
      true
    when 'weekly'
      weekdays_array.include?(Time.current.wday)
    when 'monthly'
      Time.current.day == monthly_day
    else
      false
    end
  end
  
  # Task 생성
  def generate_task!
    return unless should_generate_today?
    
    task = Task.create!(
      content: content,
      done: false,
      recurring_task_id: id
    )
    
    update!(last_generated_at: Time.current)
    task
  end
end