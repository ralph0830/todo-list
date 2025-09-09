class CreateRecurringTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :recurring_tasks do |t|
      t.string :content, null: false                    # 할 일 내용
      t.string :frequency, default: "daily"            # "daily", "weekly", "monthly"
      t.text :weekdays                                  # 주간일 때 요일 (1,2,3,4,5)
      t.integer :monthly_day                            # 월간일 때 일자 (1-31)
      t.boolean :active, default: true                  # 활성 상태
      t.datetime :last_generated_at                     # 마지막 생성 시간
      t.string :description                             # 설명 (선택사항)

      t.timestamps
    end

    add_index :recurring_tasks, :active
    add_index :recurring_tasks, :frequency
  end
end
