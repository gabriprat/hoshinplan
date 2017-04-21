module Faye
  module Authentication
    def self.validate(signature, channel, clientId, creatorId, secret)
      payload = self.decode(signature, secret)
      raise PayloadError if channel.to_s.empty? || clientId.to_s.empty?
      raise PayloadError unless channel == payload['channel'] && clientId == payload['clientId'] && creatorId == payload['creatorId'] || creatorId == 'dont_validate'
      true
    end
  end
end
