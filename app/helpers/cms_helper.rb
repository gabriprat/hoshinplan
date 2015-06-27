module CmsHelper
  def cmsGet(key) 
    Rails.logger.debug "=========== CMS Get #{key}"
    ret = CmsJob.new(key).cmsGet
    Rails.logger.debug "=========== CMS Get result: #{ret}"
    ret
  end
  
  def cmsAsyncGet(key, cache_key, expires)
    Rails.logger.debug "=========== CMS Async Get #{cache_key}"
    ret = controller.read_fragment(cache_key)
    logger.debug "=========== CMS Async Get 1: #{ret}"
    if ret.nil?
      logger.debug "=========== CMS Async Get Enqueuing job!!!!!"
      Resque.enqueue CmsJob, key, cache_key, expires
      ret = ""
    end
    Rails.logger.debug "=========== CMS Async Get 2: #{ret}"
    ret
  end
  
private

class CmsJob    
    @queue = :cms
    
    def self.cmsGet
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
    
    def self.perform(key, cache_key, expires)
      Rails.logger.debug "=========== CMS Job #{cache_key}"
      controller = ActionController::Base.new
      _fetch_or_store(cache_key, controller, expires) do |cache_key|
        cmsGet(key, cache_key, expires)
      end
    end
    
    def self._fetch_or_store(cache_key, controller, expires)
      fail "No block given" unless block_given?
      Rails.logger.debug "=========== Fecth or store #{cache_key}"
      ret = controller.read_fragment(cache_key) 
      Rails.logger.debug "=========== Fecth or store 1: #{ret}"      
      if ret.nil?
            ret = controller.write_fragment(cache_key, yield(cache_key), {expires: expires})
            Rails.logger.debug "=========== Fecth or store 2: #{ret}"      
            
      end
      Rails.logger.debug "=========== Fecth or store 3: #{ret}"
      ret
    end
  end
    
end