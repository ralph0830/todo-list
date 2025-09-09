class RecurringTasksController < ApplicationController
  before_action :set_recurring_task, only: [:show, :edit, :update, :destroy]

  def index
    @recurring_tasks = RecurringTask.all.order(created_at: :desc)
    @recurring_task = RecurringTask.new
  end

  def show
  end

  def create
    @recurring_task = RecurringTask.new(recurring_task_params)
    
    if @recurring_task.save
      redirect_to recurring_tasks_path, notice: '반복 할일이 성공적으로 생성되었습니다.'
    else
      @recurring_tasks = RecurringTask.all.order(created_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @recurring_task.update(recurring_task_params)
      redirect_to recurring_tasks_path, notice: '반복 할일이 성공적으로 수정되었습니다.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recurring_task.destroy
    redirect_to root_path, notice: '반복 할일이 성공적으로 삭제되었습니다.'
  end

  def toggle_active
    @recurring_task = RecurringTask.find(params[:id])
    @recurring_task.update(active: !@recurring_task.active)
    redirect_to recurring_tasks_path, notice: "반복 할일이 #{@recurring_task.active? ? '활성화' : '비활성화'}되었습니다."
  end

  private

  def set_recurring_task
    @recurring_task = RecurringTask.find(params[:id])
  end

  def recurring_task_params
    params.require(:recurring_task).permit(:content, :frequency, :weekdays, :monthly_day, :active, :description)
  end
end