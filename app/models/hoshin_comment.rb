class HoshinComment < GenericComment
  belongs_to :hoshin, :inverse_of => :hoshin_comments
  index [:hoshin_id, :created_at]
end