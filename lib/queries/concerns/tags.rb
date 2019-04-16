# Helpers for queries that reference Identifier
module Queries::Concerns::Tags

  extend ActiveSupport::Concern

  attr_accessor :keyword_ids

  # @return [Arel::Table]
  def tag_table 
    ::Tag.arel_table
  end

  def matching_keyword_ids
    return nil if keyword_ids.empty?
    o = table
    t = ::Tag.arel_table

    a = o.alias("a_")
    b = o.project(a[Arel.star]).from(a)

    c = t.alias('t1')

    b = b.join(c, Arel::Nodes::OuterJoin)
      .on(
        a[:id].eq(c[:tag_object_id])
      .and(c[:tag_object_type].eq(table.name.classify))
    )

    e = c[:keyword_id].not_eq(nil)
    f = c[:keyword_id].eq_any(keyword_ids)

    b = b.where(e.and(f))
    b = b.group(a['id'])
    b = b.as('tz5_')

    _a = table.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(o['id']))))
  end

end
