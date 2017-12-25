class AreaComment < GenericComment
  belongs_to :area, :inverse_of => :area_comments
  index [:area_id, :created_at]
end