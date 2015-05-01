class EnumBase < HoboFields::Types::EnumString
  
  def self.for(*values)
    options = values.extract_options!
    values = values.*.to_s
    with_values(*values)
    values.each do |v|
      const_name = v.upcase.gsub(/[^a-z0-9_]/i, '_').gsub(/_+/, '_')
      const_name = "V" + const_name if const_name =~ /^[0-9_]/ || const_name.blank?
      const_set(const_name, self.new(v)) unless const_defined?(const_name)
      
      method_name = "is_#{v.underscore}?"
      define_method(method_name) { self == v } unless self.respond_to?(method_name)
    end
  end
  
end