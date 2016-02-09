module HoboFields
  module Types
    class TextilePlusString < TextileString

      include SanitizeHtml

      def to_html(xmldoctype = true)
        require 'redcloth'

        if blank?
          ""
        else
          textilized = RedCloth.new(self, [ :hard_breaks ])
          textilized.hard_breaks = true if textilized.respond_to?("hard_breaks=")
          textilized = EmojiParser.parse(textilized) do |emoji|
            src = ActionController::Base.helpers.image_path("emoji/" + emoji.image_filename) 
            %Q(<img src="#{src}" class="emoji">).html_safe
          end
          HoboFields::SanitizeHtml.sanitize(textilized.to_html)
        end
      end

      HoboFields.register_type(:textile, self)
    end
  end
end
