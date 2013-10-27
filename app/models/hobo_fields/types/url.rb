module HoboFields
  module Types
  	class Url < String
      COLUMN_TYPE = :string

      def validate
        return if self.blank?
        begin
          uri = URI.parse(self)
          unless uri.class.in? [URI::HTTP, URI::HTTPS, URI::FTP, URI::Generic]
            return 'Only HTTP protocol addresses can be used'
          end
        rescue URI::InvalidURIError
          return 'The format of the url is not valid.'
        end
        "improper format" unless self =~ /^((ftp|http|https):\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}(:[0-9]{1,5})?(\/.*)?$/ix
        # alternate that handles IP addresses "improper format" unless self =~ /^((ftp|http|https):\/\/)?([a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}|([1-9][0-9]{0,2}\.){3}[1-9][0-9]{0,2})(:[0-9]{1,5})?(\/.*)?$/ix
      end

      def to_html(xmldoctype = true)
        "<a href='#{'http://' unless self.slice(/https?:\/\//)}#{self}'>#{self}</a>" unless self.blank?
        "o"
      end
      
      HoboFields.register_type(:url, self)
    end
  end
end
