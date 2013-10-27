module HoboFields
  module Types
  	class ImageUrl < Url
        
      def to_html(xmldoctype = true)
        "<img src='#{'http://' unless self.slice(/https?:\/\//)}#{self}'/>" unless self.blank?
      end
      
      HoboFields.register_type(:image_url, self)
    end
  end
end