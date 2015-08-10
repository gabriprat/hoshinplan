class Percentage < Float
  COLUMN_TYPE = :float
  HoboFields.register_type(:percentage, self)
end
