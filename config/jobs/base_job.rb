module Jobs
  class BaseJob
    def say(text)
       Delayed::Worker.logger.add(Logger::INFO, text)
    end
    
    def perform
      say self.class.do_it
    end
  end
end