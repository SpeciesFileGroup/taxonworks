# Helpers for queries that reference Identifier
#
# For filter queries:
# !! requires a `query_base` method
# !! requires `set_identifiers` be called in initialize()
# 
# See spec/lib/queries/collection_object/filter_spec.rb for existing spec tests
#
module Queries::Concerns::Identifiers

  extend ActiveSupport::Concern

  included do
    # Limit to this namespace 
    attr_accessor :namespace_id

    # @return [String]
    #   matches .identifier
    attr_accessor :identifier_start

    #  matches .identifier
    attr_accessor :identifier_end

    # USED?!
    # Match on cached
    attr_accessor :identifier

    # Match like or exact on cached 
    attr_accessor :identifier_exact

    # param identifier_type [Array]
    #   of identifier types
    attr_accessor :identifier_type

    def identifier_start
      ( @identifier_start.to_i - 1 ).to_s
    end

    def identifier_end
      ( @identifier_end.to_i + 1 ).to_s
    end
  end

  def set_identifier(params)
    @namespace_id = params[:namespace_id]
    @identifier_start = params[:identifier_start]
    @identifier_end = params[:identifier_end]
    @identifier = params[:identifier]

    @identifier_exact = (params[:identifier_exact]&.downcase == 'true' ? true : false) if !params[:identifier_exact].nil?
    @identifier_type = params[:identifier_type] || [] 
  end

  # @return [Arel::Table]
  def identifier_table
    ::Identifier.arel_table
  end

  def cast
    Arel::Nodes::NamedFunction.new('CAST', [substring])
  end

  def substring
    Arel::Nodes::NamedFunction.new('SUBSTRING', [ identifier_table[:identifier], Arel::Nodes::SqlLiteral.new("'([\\d]{1,9})$'") ]).as('integer')
  end

  def between
    Arel::Nodes::Between.new(
      cast,
      Arel::Nodes::And.new(
        [ Arel::Nodes::SqlLiteral.new(identifier_start),
          Arel::Nodes::SqlLiteral.new(identifier_end) ]
      )
    )
  end

  def identifier_facet
    return nil if identifier.blank?

    q = query_base.joins(:identifiers)
    w = identifier_exact ?
      identifier_table[:cached].eq(identifier) :
      identifier_table[:cached].matches('%' + identifier + '%')

    w = w.and(identifier_table[:namespace_id].eq(namespace_id)) if namespace_id
    q.where(w) 
  end

  def identifier_type_facet
    return nil if identifier_type.empty?
    q = query_base.joins(:identifiers)
    w = identifier_table[:type].eq_any(identifier_type)
    q.where(w) 
  end

  def identifier_namespace_facet
    return nil if namespace_id.blank?
    q = query_base.joins(:identifiers)
    q.where(identifier_table[:namespace_id].eq(namespace_id))
  end

  def identifier_between_facet
    return nil if @identifier_start.nil?
    @identifier_end = @identifier_start if @identifier_end.nil?

    w = between
    w = w.and(identifier_table[:namespace_id].eq(namespace_id)) if namespace_id

    query_base.joins(:identifiers).where(w)
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

  # TODO: make generic autcomplete include for all methos optimized

  # Autocomplete for tables *referencing* identifiers
  # See lib/queries/identifiers/autocomplete for autocomplete for identifiers
  #
  # May need to alter base query here
# 
  def autocomplete_identifier_cached_exact
    query_base.joins(:identifiers).where(with_identifier_cached.to_sql)
  end

  def autocomplete_identifier_identifier_exact
    query_base.joins(:identifiers).where(with_identifier_identifier.to_sql)
  end

  def autocomplete_identifier_cached_like
    query_base.joins(:identifiers).where(with_identifier_cached_wildcarded.to_sql)
  end

  def autocomplete_identifier_matching_cached_anywhere
    query_base.joins(:identifiers).where(with_identifier_cached_wildcarded.to_sql)
  end

  def autocomplete_identifier_matching_cached_fragments_anywhere
    query_base.joins(:identifiers).where(with_identifier_cached_like_fragments.to_sql)
  end

  private

  def query_base
    table.name.classify.safe_constantize
  end

end
