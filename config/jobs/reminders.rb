class SendUpdateReminders
  
  def perform
   puts "Initiating send remainders job!"
   kpis = Indicator.unscoped.where("reminder = true and next_update < current_date").each { |kpi|
     user = kpi.responsible
     company = kpi.company
     next if (user.nil? || company.nil?)
     UserCompanyMailer.reminder(user, kpi, "KPI #{kpi.name} needs to be updated!", 
     "You have to update the KPI #{kpi.name} for the hoshinplan " +
      "of the company #{company.name}. To updated click the following link:").deliver
   }
   tasks = Task.unscoped.where("reminder = true and deadline < current_date and status = 'active'").each { |task|
     user = task.responsible
     company = task.company
     next if (user.nil? || company.nil?)
     UserCompanyMailer.reminder(user, task, "Task #{task.name} needs to be updated!", 
     "You have to update the task #{task.name} for the hoshinplan " +
      "of the company #{company.name}. To updated click the following link:").deliver
   }
    
    
  end
  
  def say(text)
     Delayed::Worker.logger.add(Logger::ERROR, text)
   end
end