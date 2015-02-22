module Jobs
  class BaseJob
    def say(text)
       Delayed::Worker.logger.add(Logger::ERROR, text)
    end
    
    def perform
      say self.class.do_it
    end
  end
end