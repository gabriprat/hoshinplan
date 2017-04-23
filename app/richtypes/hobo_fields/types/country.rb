module HoboFields
  module Types
    class Country < String

      require 'countries/global'
  
    	COLUMN_TYPE = :string
            
      def initialize(value)
        super(value)
        @country = ISO3166::Country.new(value)
      end
      
    	def validate
        I18n.t("errors.messages.invalid") unless valid? || blank?
    	end
      
      def valid?
        !@country.nil? 
      end
      
      def to_html(xmldoctype = true)
        @country.translation(I18n.locale) if valid?
      end
      
      def id
        @country.nil? ? nil : @country.alpha2.to_s
      end
      
      def quoted_id
        id.gsub(/'/, "''")
      end
      
      def to_s
        @country.nil? ? super.to_s : @country.alpha2.to_s
      end
      
      def method_missing(method, *args)
         @country.send(method, *args, &block) if valid? && @country.respond_to?(method)
      end
      
    	HoboFields.register_type(:country, self)
      
    end
  end
end