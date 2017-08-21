# Patches to existing modules

require 'logical_query'

module LogicalQuery
  module LiteralNode

    def sequence_sql 
      operator, logic = negative.elements.size > 0 ? [:not_eq, :and] : [:eq, :or]
      unquoted = LogicalQuery.unquote(word.text_value)

      a, b = unquoted.split(':')

      arel_table = SequenceRelationship.arel_table
      relations = arel_table[:foo].send(operator, a).and(arel_table[:bar].send(operator, b)) # #{unquoted}
      sql << relations.to_sql
    end

  end
end


