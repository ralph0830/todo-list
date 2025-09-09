# Preview all emails at http://localhost:3000/rails/mailers/todo_reminder_mailer
class TodoReminderMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/todo_reminder_mailer/daily_reminder
  def daily_reminder
    TodoReminderMailer.daily_reminder
  end
end
