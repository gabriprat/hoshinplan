class SendUpdateReminders
  
  def perform
   puts "Initiating send remainders job!"
   kpis = User.joins('INNER JOIN "indicators" ON "indicators"."responsible_id" = "users"."id"').where("reminder = true and next_update < current_date")
   tasks = User.joins('INNER JOIN "tasks" ON "tasks"."responsible_id" = "users"."id"').where("reminder = true and deadline < current_date and status = 'active'")
   (kpis | tasks).each { |user|
     UserCompanyMailer.reminder(user, "You have KPIs or tasks to update!", 
     "You can access all the KPIs and tasks you have to update at your dashboard:").deliver
   }
  end
  
  def say(text)
     Delayed::Worker.logger.add(Logger::ERROR, text)
   end
end