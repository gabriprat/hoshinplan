module CmsHelper
  def cmsGet(key) 
    begin
      url = URI.parse('http://doc.hoshinplan.com/' + key)
      req = Net::HTTP::Get.new(url.path)
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.read_timeout = 10 #Default is 60 seconds
        http.request(req)
      }
      if (res.code.to_i < 300) 
        res.body
      else
        ""
      end
    rescue SocketError => e
      fail e unless Rails.env.development?
      "cmsGet failed: " + e.to_s
    rescue Net::ReadTimeout => e  
      unless Rails.env.development?
        track_exception(e)
        ""
      else
        "cmsGet failed: " + e.to_s
      end
    end
  end
  
  def cmsAsyncGet(key, cache_key, expires)
    controller = ActionController::Base.new
    res = controller.read_fragment(cache_key)
    if res.nil?
      logger.debug "==================calling cms: #{key}" 
      res = ""
      conn = Faraday.new 'http://doc.hoshinplan.com' do |con|
          con.adapter :excon
      end
      resp = conn.get '/' + key
      resp.on_complete {
        res = resp.body if resp.status.to_i < 300
        controller.write_fragment(cache_key, res, :expires_in => expires)
        logger.debug "================== returned cms: #{key}" 
        
      }
    end
    return res
  end 
end