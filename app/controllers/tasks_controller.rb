class TasksController < ApplicationController
  before_action :set_task, only: [:update, :destroy]

  def index
    @incomplete_tasks = Task.where(done: false).order(created_at: :desc)
    @completed_tasks = Task.where(done: true).order(done_at: :desc)
    @recurring_tasks = RecurringTask.active.order(created_at: :desc)
    @task = Task.new
  end

  def create
    # 반복 주기가 설정된 경우 RecurringTask도 생성
    recurring_frequency = params[:task][:recurring_frequency]
    
    if recurring_frequency.present?
      # 반복 할일로 생성
      recurring_task_params = {
        content: task_params[:content],
        frequency: recurring_frequency,
        active: true
      }
      
      # 주기별 설정
      case recurring_frequency
      when 'daily'
        # 월~금 (1,2,3,4,5)
        recurring_task_params[:weekdays] = "1,2,3,4,5"
      when 'weekly'
        # 매주 월요일 (1)
        recurring_task_params[:weekdays] = "1"
      when 'monthly'
        # 매월 1일
        recurring_task_params[:monthly_day] = 1
      end
      
      recurring_task = RecurringTask.new(recurring_task_params)
      
      if recurring_task.save
        # 오늘 생성해야 하는 경우 즉시 일반 할일도 생성
        if recurring_task.should_generate_today?
          task = recurring_task.generate_task!
          redirect_to root_path, notice: '반복 할일이 등록되었고, 오늘의 할일도 추가되었습니다.'
        else
          redirect_to root_path, notice: '반복 할일이 성공적으로 등록되었습니다.'
        end
      else
        @incomplete_tasks = Task.where(done: false).order(created_at: :desc)
        @completed_tasks = Task.where(done: true).order(done_at: :desc)
        @task = Task.new
        flash.now[:alert] = '반복 할일 등록에 실패했습니다.'
        render :index, status: :unprocessable_entity
      end
    else
      # 일반 할일로 생성
      @task = Task.new(task_params)
      if @task.save
        redirect_to root_path, notice: 'Task was successfully created.'
      else
        @incomplete_tasks = Task.where(done: false).order(created_at: :desc)
        @completed_tasks = Task.where(done: true).order(done_at: :desc)
        render :index, status: :unprocessable_entity
      end
    end
  end

  def update
    # 체크박스에서 전송된 done 파라미터 사용, 없으면 현재 상태 반전
    new_done_state = params[:task][:done] == '1' ? true : false
    done_at_value = new_done_state ? Time.current : nil
    
    if @task.update(done: new_done_state, done_at: done_at_value)
      redirect_to root_path, notice: "Task status was successfully updated."
    else
      redirect_to root_path, alert: 'Failed to update the task status.'
    end
  end

  def destroy
    @task.destroy
    redirect_to root_path, notice: 'Task was successfully deleted.'
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:content, :done)
  end
end
