class IndicatorLog < Log
  belongs_to :indicator, :inverse_of => :log
end
