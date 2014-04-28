class Color < String
  COLUMN_TYPE = :string
  HoboFields.register_type(:color, self)
end
