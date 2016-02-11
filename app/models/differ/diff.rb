module Differ
  class Diff
    @@user_regex = Regexp.new('^(.*)@(\d+):(.*)$')
    def new_mentions
      @raw.inject({}) do |arr,part|
        if part.is_a?(Change) && part.insert.present?
          part.insert.gsub(@@user_regex) do |match|
              user = Company.current_company.comp_users[$2.to_i] 
              if user.present?
                if $1.blank? && $3.blank?
                  message = nil
                else
                  message = ($1 + " " + user.name + ": " + $3).strip
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
