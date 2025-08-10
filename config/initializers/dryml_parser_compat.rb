# Force DRYML to use legacy regex branch to avoid REXML differences
begin
  require 'dryml/parser/base_parser'
  Dryml::Parser::BaseParser.send(:remove_const, :NEW_REX) if Dryml::Parser::BaseParser.const_defined?(:NEW_REX)
  Dryml::Parser::BaseParser.const_set(:NEW_REX, false)
rescue LoadError
end


