# Patches to existing modules

require 'logical_query'

# These extensions could be normalized to variable 
# use the to_sql methods instead of replicating them
# in full.
module LogicalQuery

  # 
  # to_sequence_relationship_sql
  #
  module ExpNode
    def to_sequence_relationship_sql(opts = {}, sql = '')
      any.to_sequence_relationship_sql(opts, sql)
    end
  end

  module ExpParenNode
    def to_sequence_relationship_sql(opts, sql = '')
      lparen.to_sql(opts, sql)

      puts '--- EXP ---'
      exp.to_sequence_relationship_sql(opts, sql)
      rparen.to_sql(opts, sql)
    end
  end

  module CondNode
    def to_sequence_relationship_sql(opts, sql = '')
      lexp.to_sequence_relationship_sql(opts, sql)
      logic.to_sql(opts, sql)
      puts '--- COND ---'
      rexp.to_sequence_relationship_sql(opts, sql)
    end
  end

  module LiteralSeqNode
    def to_sequence_relationship_sql(opts, sql = '')
      lliteral.to_sequence_relationship_sql(opts, sql)

      sql << ' AND '

      puts '--- AND ---'
      rliteral.to_sequence_relationship_sql(opts, sql)
    end
  end

  module LiteralNode
    def to_sequence_relationship_sql(opts, sql = '')
      operator, logic = negative.elements.size > 0 ? [:not_eq, :or] : [:eq, :or]
      unquoted = LogicalQuery.unquote(word.text_value)
      
      a, b = unquoted.split('.')

      arel_table = SequenceRelationship.arel_table
      relations = [arel_table[:type].send(operator, a).and(arel_table[:subject_sequence_id].send(operator, b))].reduce(logic) # #{unquoted}
      sql << relations.to_sql 
    end
  end

  # end to_sequence_relationship_sql

end


