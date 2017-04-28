class IndicatorTag < Tag
  belongs_to :indicator, :inverse_of => :indicator_tags

  after_initialize :add_defaults

  def add_defaults
    self.hoshin_id = self.indicator.hoshin_id if self.indicator
  end
end
