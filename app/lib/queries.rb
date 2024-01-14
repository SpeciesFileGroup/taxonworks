module Queries

  def self.intersect(target, queries)

    table = target.name.tableize

    q = queries.compact

    # We can return this directly, though we get conflicts with `from:` on merge clauses
    z = target.from("( #{q.collect{|i| '(' + i.to_sql + ')' }.join(' INTERSECT ')}) as #{table}")

    # Probably need a global counter, and this may not be needed
    s = Utilities::Strings.random_string(5)
    a = table + s

    # Here we probably get conflicts with join: clauses
    target.joins("INNER JOIN ( #{z.to_sql}  ) AS #{a} ON #{a}.id = #{table}.id")
  end

  def self.union(target, queries)
    q = queries.compact
    table = target.name.tableize
    target.from("( #{q.collect{|i| '(' + i.to_sql + ')' }.join(' UNION ')}) as #{table}")
  end

  def self.except(target, query)
    table = target.name.tableize
    target.from("((#{target.to_sql}) EXCEPT (#{query.to_sql}) ) as #{table}")
  end

end
