class AreaTag < Tag
  belongs_to :area, :inverse_of => :area_tags

  after_initialize :add_defaults

  def add_defaults
    self.hoshin_id = self.area.hoshin_id if self.area
  end
end
