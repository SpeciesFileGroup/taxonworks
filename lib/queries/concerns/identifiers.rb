# Helpers for queries that reference Identifier
#
# TODO: Some of this is only for autocomplete !!
# See anything refencing terms, query_string
#
# These queries are impacted by Shared::Containable.
# When Containable identifiers have to match, potentially
# targets directly, and indirectly through virtual containers.
#
module Queries::Concerns::Identifiers
  include Queries::Helpers

  extend ActiveSupport::Concern

  def self.params
    [
      :identifier,
      :identifier_end,
      :identifier_exact,
      :identifier_start,
      :identifier_type,
      :identifiers,
      :local_identifiers,
      :global_identifiers,
      :match_identifiers,
      :match_identifiers_delimiter,
      :match_identifiers_type,
      :namespace_id,
      identifier_type: [],
    ]
  end

  included do
    # Matches on cached
    attr_accessor :identifier

    #  matches .identifier
    attr_accessor :identifier_end

    # Match like or exact on cached
    attr_accessor :identifier_exact

    # @return [String]
    #   matches .identifier
    attr_accessor :identifier_start

    # @param identifier_type [Array]
    #   of identifier types
    attr_accessor :identifier_type

    # @return [True, False, nil]
    #   true - has an identifier
    #   false - does not have an identifier
    #   nil - not applied
    attr_accessor :identifiers

    # @return [True, False, nil]
    #   true - has a local identifier
    #   false - does not have a local identifier
    #   nil - not applied
    attr_accessor :local_identifiers

    # @return [True, False, nil]
    #   true - has an global identifier
    #   false - does not have a global identifier
    #   nil - not applied
    attr_accessor :global_identifiers

    # @param match_identifiers [String]
    # @return [String, nil]
    #   a list of delimited identifiers
    # !! Requires match_identifiers_delimiter to be present
    attr_accessor :match_identifiers

    # @param match_identifiers_delimiter [String]
    # A listr delimiter, defaults to ','.  Is applied to `match_identifiers` to build an Array.
    #    Any reference is possible.
    # '\t' is translated to "\t"
    # '\n' is translated to "\n"
    attr_accessor :match_identifiers_delimiter

    # @return [String, nil]
    #  one of 'internal' or 'identifier'
    # if 'internal' then references the internal id of the object
    attr_accessor :match_identifiers_type

    # Limit to this namespace
    attr_accessor :namespace_id

    def identifier_start
      @identifier_start.to_s
    end

    def identifier_end
      @identifier_end.to_s
    end

    def match_identifiers_delimiter
      return ',' if @match_identifiers_delimiter.nil?

      case @match_identifiers_delimiter
      when '\n'
        return "\n"
      when '\t'
        return "\t"
      else
        return @match_identifiers_delimiter
      end
    end

    def identifier_type
      [@identifier_type].flatten.compact.uniq
    end

    def match_identifiers_type
      @match_identifiers_type&.downcase
    end
  end

  def set_identifier_params(params)
    @global_identifiers = boolean_param(params, :global_identifiers)
    @identifier = params[:identifier]
    @identifier_end = params[:identifier_end]
    @identifier_exact = boolean_param(params, :identifier_exact)
    @identifier_start = params[:identifier_start]
    @identifier_type = params[:identifier_type]
    @identifiers = boolean_param(params, :identifiers)
    @local_identifiers = boolean_param(params, :local_identifiers)
    @match_identifiers = params[:match_identifiers]
    @match_identifiers_delimiter = params[:match_identifiers_delimiter]
    @match_identifiers_type = params[:match_identifiers_type]
    @namespace_id = params[:namespace_id]
  end

  # @return [Arel::Table]
  def identifier_table
    ::Identifier.arel_table
  end

  def self.merge_clauses
    [
      :global_identifiers_facet,
      :identifier_between_facet,
      :identifier_facet,
      :identifier_namespace_facet,
      :identifier_type_facet,
      :identifiers_facet,
      :local_identifiers_facet,
      :match_identifiers_facet,
    ]
  end

  def between
    Arel::Nodes::Between.new(
      identifier_table[:cached_numeric_identifier],
      Arel::Nodes::And.new(
        [ Arel::Nodes::SqlLiteral.new(identifier_start),
          Arel::Nodes::SqlLiteral.new(identifier_end) ]
      )
    )
  end

  # @return Array
  def identifiers_to_match
    ids = match_identifiers.strip.split(match_identifiers_delimiter).flatten.map(&:strip).uniq
    if match_identifiers_type == 'internal'
      ids = ids.select{|i| i =~ /^\d+$/}
    end
    ids
  end

  def match_identifiers_facet
    return nil if match_identifiers.blank?
    ids = identifiers_to_match

    return nil if ids.empty?

    a = nil

    case match_identifiers_type
    when 'internal'
      a = referenced_klass.where(id: ids)
    when 'identifier'
      a = referenced_klass.joins(:identifiers).where(identifiers: {cached: ids})
    when 'dwc_occurrence_id'
      a = referenced_klass.joins(:identifiers).where(identifiers: {cached: ids, type: 'Identifier::Global::Uuid::TaxonworksDwcOccurrence' })
    else
      return nil
    end

    a = referenced_klass_union([a, match_identifiers_container_match ]) if referenced_klass.is_containable?
    a
  end

  def identifiers_facet
    return nil if identifiers.nil?
    a = nil
    if identifiers
      a = referenced_klass.joins(:identifiers).distinct
    else
      a = referenced_klass.where.missing(:identifiers).distinct
    end

    if referenced_klass.is_containable?
      c = referenced_klass_union([a, identifiers_container_match ])
      @identifiers = !identifiers
      except = identifiers_container_match
      @identifiers = !identifiers

      return referenced_klass.from('(' + c.to_sql + " EXCEPT #{except.to_sql}) as #{table.name}")
    end

    a
  end

  def global_identifiers_facet
    return nil if global_identifiers.nil?
    a = nil

    if global_identifiers
      a = referenced_klass.joins(:identifiers).where("identifiers.type ILIKE 'Identifier::Global%'").distinct
    else
      i = ::Identifier.arel_table[:identifier_object_id].eq(table[:id]).and(
        ::Identifier.arel_table[:identifier_object_type].eq( table.name.classify.to_s )
      )
      a = referenced_klass.where.not(::Identifier::Local.where(i).arel.exists)
    end

    # TODO: this logic can almost certainly be simplified.  Test coverage is decent for attempts to do so.
    if referenced_klass.is_containable?
      c = referenced_klass_union([a, global_identifiers_container_match ].compact)

      @global_identifiers = !local_identifiers
      except = global_identifiers_container_match
      @global_identifiers = !local_identifiers

      if except
        return referenced_klass.from('(' + c.to_sql + " EXCEPT #{except.to_sql}) as #{table.name}")
      else
        return referenced_klass.from('(' + c.to_sql + ") as #{table.name}")
      end
    end

    a
  end

  def local_identifiers_facet
    return nil if local_identifiers.nil?
    a = nil

    if local_identifiers
      a = referenced_klass.joins(:identifiers).where("identifiers.type ILIKE 'Identifier::Local%'").distinct
    else
      i = ::Identifier.arel_table[:identifier_object_id].eq(table[:id]).and(
        ::Identifier.arel_table[:identifier_object_type].eq( table.name.classify.to_s )
      )
      a = referenced_klass.where.not(::Identifier::Local.where(i).arel.exists)
    end

    # TODO: this logic can almost certainly be simplified.  Test coverage is decent for attempts to do so.
    if referenced_klass.is_containable?
      c = referenced_klass_union([a, local_identifiers_container_match ].compact)

      @local_identifiers = !local_identifiers
      except = local_identifiers_container_match
      @local_identifiers = !local_identifiers

      if except
        return referenced_klass.from('(' + c.to_sql + " EXCEPT #{except.to_sql}) as #{table.name}")
      else
        return referenced_klass.from('(' + c.to_sql + ") as #{table.name}")
      end
    end

    a
  end


  # TODO: Simplify local/global copy-pasta
  def global_identifiers_facet
    return nil if global_identifiers.nil?
    a = nil

    if global_identifiers
      a = referenced_klass.joins(:identifiers).where("identifiers.type ILIKE 'Identifier::Global%'").distinct
    else
      i = ::Identifier.arel_table[:identifier_object_id].eq(table[:id]).and(
        ::Identifier.arel_table[:identifier_object_type].eq( table.name.classify.to_s )
      )
      a = referenced_klass.where.not(::Identifier::Global.where(i).arel.exists)
    end

    # TODO: this logic can almost certainly be simplified.  Test coverage is decent for attempts to do so.
    if referenced_klass.is_containable?
      c = referenced_klass_union([a, global_identifiers_container_match ].compact)

      @global_identifiers = !global_identifiers
      except = global_identifiers_container_match
      @global_identifiers = !global_identifiers

      if except
        return referenced_klass.from('(' + c.to_sql + " EXCEPT #{except.to_sql}) as #{table.name}")
      else
        return referenced_klass.from('(' + c.to_sql + ") as #{table.name}")
      end
    end

    a
  end

  def identifier_facet
    return nil if identifier.blank?

    q = referenced_klass.joins(:identifiers)

    w = identifier_exact ?
      identifier_table[:cached].eq(identifier) :
      identifier_table[:cached].matches('%' + identifier.to_s + '%')

    w = w.and(identifier_table[:namespace_id].eq(namespace_id)) if namespace_id
    a = q.where(w)

    a = referenced_klass_union([a, identifier_container_match]) if referenced_klass.is_containable?
    a
  end

  def identifier_type_facet
    return nil if identifier_type.empty?
    q = referenced_klass.joins(:identifiers)
    w = identifier_table[:type].eq_any(identifier_type)
    a = q.where(w)

    a = referenced_klass_union([a, identifier_type_container_match ]) if referenced_klass.is_containable?
    a
  end

  def identifier_namespace_facet
    return nil if namespace_id.blank?
    q = referenced_klass.joins(:identifiers)
    a = q.where(identifier_table[:namespace_id].eq(namespace_id))

    a = referenced_klass_union([a, identifier_namespace_container_match ]) if referenced_klass.is_containable?
    a
  end

  def identifier_between_facet
    return nil if @identifier_start.nil?
    @identifier_end = @identifier_start if @identifier_end.nil?

    w = between
    w = w.and(identifier_table[:namespace_id].eq(namespace_id)) if namespace_id # TODO: redundant with namespace facet likely

    a = referenced_klass.joins(:identifiers).where(w)
    a = referenced_klass_union([a, identifier_between_container_match]) if referenced_klass.is_containable?
    a
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
    referenced_klass.joins(:identifiers).where(with_identifier_cached.to_sql)
  end

  def autocomplete_identifier_identifier_exact
    referenced_klass.joins(:identifiers).where(with_identifier_identifier.to_sql)
  end

  def autocomplete_identifier_cached_like
    referenced_klass.joins(:identifiers).where(with_identifier_cached_wildcarded.to_sql)
  end

  def autocomplete_identifier_matching_cached_anywhere
    referenced_klass.joins(:identifiers).where(with_identifier_cached_wildcarded.to_sql)
  end

  def autocomplete_identifier_matching_cached_fragments_anywhere
    referenced_klass.joins(:identifiers).where(with_identifier_cached_like_fragments.to_sql)
  end

  # def substring
  #   Arel::Nodes::NamedFunction.new('SUBSTRING', [ identifier_table[:identifier], Arel::Nodes::SqlLiteral.new("'([\\d]{1,9})$'") ]).as('integer')
  # end

end
