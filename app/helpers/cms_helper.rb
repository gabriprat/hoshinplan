module CmsHelper
  def cmsGet(key) 
    url = URI.parse('http://doc.hoshinplan.com/' + key)
    req = Net::HTTP::Get.new(url.path)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    if (res.code.to_i < 300) 
      res.body
    else
      ""
    end
  end 
end