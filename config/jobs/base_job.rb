module Jobs
    def say(text)
       Resque.logger.add(Logger::INFO, text)
    end
end