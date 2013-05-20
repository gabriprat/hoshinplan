class SendUpdateReminders
  
  def perform
    rascatela!
    say "Hello log!"
    puts "Hello puts!"
  end
  
  def say(text)
     Delayed::Worker.logger.add(Logger::ERROR, text)
   end
end