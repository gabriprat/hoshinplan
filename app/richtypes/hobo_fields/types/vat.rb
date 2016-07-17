module HoboFields
  module Types
    class Vat < String

      COLUMN_TYPE = :string

      HoboFields.register_type(:vat, self)
    end
  end
end
