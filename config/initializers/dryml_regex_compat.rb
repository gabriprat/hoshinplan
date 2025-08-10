# Align DRYML regexes with legacy behavior known to work in Ruby 2.5.x
begin
  require 'dryml/parser/base_parser'
  module Dryml
    module Parser
      class BaseParser < REXML::Parsers::BaseParser
        # Force legacy branch and use regexes independent of REXML internals
        remove_const(:NEW_REX) if const_defined?(:NEW_REX)
        NEW_REX = false
        remove_const(:DRYML_ATTRIBUTE_PATTERN) if const_defined?(:DRYML_ATTRIBUTE_PATTERN)
        DRYML_ATTRIBUTE_PATTERN = /\s*([A-Za-z_:][-A-Za-z0-9_:.]*)\s*(?:=\s*(["'])(.*?)\2)?/um
        remove_const(:DRYML_TAG_MATCH) if const_defined?(:DRYML_TAG_MATCH)
        DRYML_TAG_MATCH = /^<((?>[A-Za-z_:][-A-Za-z0-9_:.]*))\s*((?>\s+[A-Za-z_:][-A-Za-z0-9_:.]*(?:\s*=\s*(["']).*?\3)?)*)\s*(\/)?>/um
      end
    end
  end
rescue LoadError
end


