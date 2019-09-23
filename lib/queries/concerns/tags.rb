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
    k = table.name.classify.safe_constantize
    t = ::Tag.arel_table
    k.where(
      ::Tag.where(
        t[:tag_object_id].eq(table[:id]).and(
          t[:tag_object_type].eq(table.name.classify)).and(
            t[:keyword_id].eq_any(keyword_ids)
          )
      ).arel.exists
    )
  end

end
