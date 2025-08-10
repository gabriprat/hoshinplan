require 'rubygems'

# Require built-in digest before bundler to avoid constant redefinition warnings
require 'digest'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

# Allow Rails 4.2 to accept pg >= 1.0 by overriding the specific version check
module Kernel
  def gem_with_pg_fix(dep, *reqs)
    if dep == 'pg'
      # Replace old requirement "~> 0.15" with a broad range that includes 1.x
      reqs = ['>= 0.15'] if reqs == ['~> 0.15']
    end
    gem_without_pg_fix(dep, *reqs)
  end
  alias_method :gem_without_pg_fix, :gem
  alias_method :gem, :gem_with_pg_fix
end

# Minimal DRYML/REXML compatibility for Ruby 2.7: define legacy constants before DRYML loads
require 'rexml/parsers/baseparser'
module REXML
  module Parsers
    class BaseParser
      NAME_STR = NAME unless const_defined?(:NAME_STR)
      NCNAME_STR = NCNAME unless const_defined?(:NCNAME_STR)
    end
  end
end

# Some versions of DRYML reference NAME_STR/NCNAME_STR unqualified
Object.const_set(:NAME_STR, REXML::Parsers::BaseParser::NAME_STR) unless Object.const_defined?(:NAME_STR)
Object.const_set(:NCNAME_STR, REXML::Parsers::BaseParser::NCNAME_STR) unless Object.const_defined?(:NCNAME_STR)