class AreaLog < Log
  belongs_to :area, :inverse_of => :log
end
