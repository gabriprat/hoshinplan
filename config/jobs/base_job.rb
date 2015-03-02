module Jobs
    def say(text)
       Delayed::Worker.logger.add(Logger::INFO, text)
    end
end