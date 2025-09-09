class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.string :content
      t.boolean :done, default: false
      t.datetime :done_at

      t.timestamps
    end
  end
end
