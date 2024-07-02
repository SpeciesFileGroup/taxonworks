module Queries

  def self.venn(a_query, b_query, mode)
    case mode
    when :a
      except(a_query, b_query)
    when :b
      except(b_query, a_query)
    when :ab
      intersect(a_query.klass, [a_query, b_query])
    else
      raise
    end
  end

  def self.intersect(target, queries)
    table = target.table_name
    q = queries.compact.collect{|y| y.unscope(:select).select(:id) }

    # We can return this directly, though we get conflicts with `from:` on merge clauses
    z = target.from("( #{q.collect{|i| '(' + i.to_sql + ')' }.join(' INTERSECT ')}) as #{table}")

    z
  end

  def self.union(target, queries)
    table = target.name.tableize
    q = queries.compact.collect{|y| y.unscope(:select).select(:id) }

    target.from("( #{q.collect{|i| '(' + i.to_sql + ')' }.join(' UNION ')}) as #{table}")
  end

  def self.except(target, query)
    table = target.name.tableize
    target.from("((#{target.to_sql}) EXCEPT (#{query.to_sql}) ) as #{table}")
  end

end
