module Jobs
    def self.say(text)
       Resque.logger.add(Logger::INFO, text)
       return text
    end
end