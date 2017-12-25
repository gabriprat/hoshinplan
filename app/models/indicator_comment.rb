class IndicatorComment < GenericComment
  belongs_to :indicator, :inverse_of => :indicator_comments
  index [:indicator_id, :created_at]
end