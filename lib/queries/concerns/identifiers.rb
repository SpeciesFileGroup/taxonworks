# Helpers for queries that reference Identifier
module Queries::Concerns::Identifiers

  extend ActiveSupport::Concern

  # @return [Arel::Table]
  def identifier_table
    ::Identifier.arel_table
  end

  # @return [Arel::Nodes::Equality]
  def with_identifier_identifier
    identifier_table[:identifier].eq(query_string)
  end

  # @return [Arel::Nodes::Equality]
  def with_identifier_cached
    identifier_table[:cached].eq(query_string)
  end

  def with_identifier_wildcard_end
    identifier_table[:identifier].matches(end_wildcard)
  end

  # @return [Arel::Nodes::Equality]
  def with_identifier_cached_wildcard_end
    identifier_table[:cached].matches(end_wildcard)
  end

  # @return [Arel::Nodes::Equality]
  def with_identifier_cached_wildcarded
    identifier_table[:cached].matches(start_and_end_wildcard)
  end
 
  # !! We do not need identifier_cached_wildcarded

  # @return [Arel::Nodes::Grouping]
  def with_identifier_cached_like_fragments
    a = [ start_and_end_wildcard ]
    a = a + wildcard_wrapped_integers
    identifier_table[:cached].matches_any(a)
  end

  #
  # Autocomplete for tables *referencing* identifiers
  # See lib/queries/identifiers/autocomplete for autocomplete for identifiers
  #
  def autocomplete_identifier_cached_exact
    base_query.joins(:identifiers).where(with_identifier_cached.to_sql)
  end

  def autocomplete_identifier_identifier_exact
    base_query.joins(:identifiers).where(with_identifier_identifier.to_sql)
  end

  def autocomplete_identifier_cached_like
    base_query.joins(:identifiers).where(with_identifier_cached_wildcarded.to_sql)
  end

  def autocomplete_identifier_matching_cached_anywhere
    base_query.joins(:identifiers).where(with_identifier_cached_wildcarded.to_sql)
  end

  def autocomplete_identifier_matching_cached_fragments_anywhere
    base_query.joins(:identifiers).where(with_identifier_cached_like_fragments.to_sql)
  end

end
