module CmsHelper  
  def cmsCachedGet(key, expires, async, cache_key, clear)
    controller.expire_fragment(cache_key) if clear
    Rails.logger.debug "=========== CMS Get #{key} async=#{async}"
    ret = CmsGetter.fetch_or_store(key, cache_key, expires, async)
    Rails.logger.debug "=========== CMS Get result present=#{ret.present?}"
    ret
  end    
end

class CmsGetter
  
  def self.fetch_or_store(key, cache_key, expires, async)
    Rails.logger.debug "========"
    _fetch_or_store(cache_key, expires) do 
      if async && Rails.configuration.action_controller.perform_caching
        self.delay._cmsGet(key)
        ""
      else
        _cmsGet(key)
      end
    end
  end
  
private

  def self._cmsGet(key)
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

  def self._fetch_or_store(cache_key, expires)
    fail "No block given" unless block_given?
    return yield unless Rails.configuration.action_controller.perform_caching
    Rails.logger.debug "=========== Fecth or store #{cache_key}"
    cont = ActionController::Base.new
    ret = cont.read_fragment(cache_key) 
    Rails.logger.debug "=========== Fecth or store: cached=#{!ret.nil?}"      
    if ret.nil?
          ret = yield
          ret = cont.write_fragment(cache_key, ret, {expires: expires}) unless ret.nil?
          Rails.logger.debug "=========== Fecth or store retrieved from cms"      
    end
    Rails.logger.debug "=========== Fecth or store END present=#{ret.present?}"
    ret
  end
end

