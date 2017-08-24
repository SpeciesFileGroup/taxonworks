# Methods that recieve or generate a String. This methods in this library should be completely independant (i.e. ultimately gemifiable) from TaxonWorks.

require "logic_tools/logictree.rb"
require "logic_tools/logicparse.rb"
require "logic_tools/logicsimplify_es.rb"
include LogicTools


module Utilities::Logic

  # @return [String]
  def self.parse_logic(expression)
    parsed = string2logic(expression)
    simple = parsed.simplify
    simple.sort.to_s 
  end

end

