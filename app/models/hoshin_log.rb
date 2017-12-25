class HoshinLog < Log
  belongs_to :hoshin, :inverse_of => :log
end
