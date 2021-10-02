require 'date'

class DateValidator < Apipie::Validator::BaseValidator

  def initialize(param_description, argument)
    super(param_description)
    @type = argument
  end

  def validate(value)
    return true if value.nil?
    !!(Date.strptime(value, '%Y-%m-%d') rescue nil)
  end

  def self.build(param_description, argument, options, block)
    if argument == Date
      self.new(param_description, argument)
    end
  end

  def description
    "Must be #{@type}."
  end
end