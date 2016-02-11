module HoboFields
  module Types
    class TextilePlusString < TextileString

      include SanitizeHtml
      include ActionView::Helpers
      include ActionDispatch::Routing
      include Rails.application.routes.url_helpers
      
      @@user_regex = Regexp.new('@(\d+):')
      
      def to_html(xmldoctype = true)
        require 'redcloth'

        if blank?
          ""
        else
          textilized = RedCloth.new(self, [ :hard_breaks ])
          textilized.hard_breaks = true if textilized.respond_to?("hard_breaks=")
          textilized = EmojiParser.parse(textilized) do |emoji|
            src = 'https://d4i78hkg1rdv3.cloudfront.net/assets/emoji/' + emoji.image_filename
            %Q(<img src="#{src}" class="emoji">).html_safe
          end
          
          textilized = textilized.gsub(@@user_regex) do |match|
            user = Company.current_company.comp_users[$1.to_i] 
            if user.present?
              user =  (link_to user.name, user) + ": "
            else
              user = match
            end
            user.html_safe
          end
          HoboFields::SanitizeHtml.sanitize(textilized.to_html)
        end
      end

      HoboFields.register_type(:textile, self)
    end
  end
end
