# Helpers for queries that reference Identifier
module Queries::Concerns::Identifiers

  extend ActiveSupport::Concern

  # @return [Arel::Table]
  def identifier_table
    ::Identifier.arel_table
  end

  # @return [Arel::Nodes::Grouping]
  def with_identifier_like
    a = [ start_and_end_wildcard ]
    a = a + wildcard_wrapped_integers
    identifier_table[:cached].matches_any(a)
  end


  # @return [Arel::Nodes::Equality]
  def with_identifier
    identifier_table[:identifier].eq(query_string)
  end

  # @return [Arel::Nodes::Equality]
  def with_cached
    identifier_table[:cached].eq(query_string)
  end

  # @return [Arel::Nodes::Equality]
  def with_identifier_wildcard_end
    identifier_table[:cached].matches(end_wildcard)
  end

  # @return [Arel::Nodes::Equality]
  def with_identifier_wildcard_anywhere
    identifier_table[:cached].matches(start_and_end_wildcard)
  end

  #
  # Autocomplete
  #
  def autocomplete_identifier_cached_exact
    base_query.joins(:identifiers).where(with_identifier.to_sql)
  end

  def autocomplete_identifier_cached_like
    base_query.joins(:identifiers).where(with_identifier_like.to_sql)
  end

end
