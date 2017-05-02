class DecimalValidator < Apipie::Validator::BaseValidator
  def validate(value)
    self.class.validate(value)
  end

  def self.build(param_description, argument, options, block)
    if argument == :decimal
      self.new(param_description)
    end
  end

  def description
    "Must be a decimal number."
  end

  def self.validate(value)
    value.to_s =~ /\A[0-9]+([,.][0-9]+)?\Z$/
  end
end
