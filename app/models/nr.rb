class Nr
  
  def self.add_custom_parameters(options)
    return unless defined?(NewRelic)
    ::NewRelic::Agent.add_custom_attributes(options)
  end
  
  def self.track_exception(exception, request)
    return unless defined?(NewRelic)
    options = {}
    options = {
      :uri => request.url,
      :referrer => request.referrer,
      :request_params => request.params
    } unless request.nil?
    NewRelic::Agent.notice_error(exception, options)
  end
  
end