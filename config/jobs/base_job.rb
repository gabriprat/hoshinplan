module Jobs
    def self.say(text)
       Resque.logger.add(Logger::INFO, text)
    end
end