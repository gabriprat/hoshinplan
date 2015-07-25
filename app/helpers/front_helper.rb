module FrontHelper 
  include ActionView::Helpers::DateHelper
  
  def date_format_default
    begin
          d=I18n.t(:"date.formats.default")
          {"%Y" => "yyyy",
           "%y" => "yy",
           "%m" => "mm",
           "%_m" => "m",
           "%-m" => "m",
           "%B" => "MM",
           "%^B" => "MM",
           "%b" => "M",
           "%^b" => "M",
           "%h" => "M",
           "%d" => "dd",
           "%-d" => "d",
           "%j" => "oo",
           "%D" => "mm/dd/yy",
           "%F" => "yy-mm-dd",
           "%x" => "mm/dd/yy"}.each {|rb, js| d.gsub!(rb,js)}
         d
    end
  end
  
end
