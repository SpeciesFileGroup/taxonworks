# Methods that use or facilitate logic

require 'logic_tools/logictree.rb'
require 'logic_tools/logicparse.rb'
require 'logic_tools/logicsimplify_es.rb'
include LogicTools

module Utilities::Logic

  # @param [String] expression
  # @return [String]
  def self.parse_logic(expression)
    parsed = string2logic(expression)
    simple = parsed.simplify
    simple.sort.to_s
  end

  # @param [String] expression
  # @return [Array]
  def self.or_queries(expression)
    parse_logic(expression).split('+')
  end

end

