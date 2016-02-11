module Differ
  class Diff
    @@user_regex = Regexp.new('@(\d+):')
    def new_mentions
      @raw.inject({}) do |arr,part|
        if part.is_a?(Change) && part.insert.present?
          part.insert.gsub(@@user_regex) do |match|
              user = Company.current_company.comp_users[$1.to_i] 
              if user.present?
                if $`.strip.blank? && $'.strip.blank?
                  message = nil
                else
                  message = ::HoboFields::Types::TextilePlusString.new($` + $& + $').to_html
                end
                arr[user] = message
              end
          end
        end
        arr
      end
    end
  end
end
