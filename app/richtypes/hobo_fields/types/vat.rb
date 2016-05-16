module HoboFields
  module Types
    class Vat < String

      COLUMN_TYPE = :string

      HoboFields.register_type(:vat, self)
    end
  end

  module SanitizeHtml
    PERMITTED_ATTRIBUTES = %w(href title class style align name src label target border width height)
  end

end
