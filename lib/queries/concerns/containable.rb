# Helpers for queries that reference Containers, largely
# expanding their linkages to Identifiers.

# TODO: !? Requires that Query includes Queries::Concerns::Identifiers
module Queries::Concerns::Containable
  include Queries::Helpers

  extend ActiveSupport::Concern

  def self.params
    [ ] # params come from Identifiers so far
  end

  included do
  end

  def set_containable_params(params)
  end

  def container_table
    ::Container.arel_table
  end

  def self.merge_clauses
    [ ]
  end

  def identified_containers
    # TODO: Ultimately replace with Containers filter
    ::Container.joins(:identifiers).where(project_id: project_id)
  end

  # referenced_klass referenceable in any ContainerItem
  def referenced_klass_with_container_items
    referenced_klass.joins(:container_item)
      .joins('JOIN container_item_hierarchies cih on cih.descendant_id = container_items.id')
      .joins('JOIN container_items ci2 on ci2.id = cih.ancestor_id')
  end

  def referenced_klass_containers
    referenced_klass_with_container_items
      .joins("JOIN containers on containers.id = ci2.contained_object_id and ci2.contained_object_type = 'Container'")
  end

  def referenced_klass_container_identifiers
    referenced_klass_containers
      .joins("JOIN identifiers on identifiers.identifier_object_id = containers.id and identifiers.identifier_object_type = 'Container'")
  end

  def identifier_namespace_container_match
    return nil if namespace_id.blank?
    referenced_klass_container_identifiers.where(identifiers: {namespace_id: namespace_id})
  end

  def identifier_type_container_match
    return nil if identifier_type.empty?
    referenced_klass_container_identifiers.where(identifiers: {type: identifier_type})
  end

  def identifier_container_match
    return nil if identifier.blank?

    w = identifier_exact ?
      identifier_table[:cached].eq(identifier) :
      identifier_table[:cached].matches('%' + identifier.to_s + '%')

    w = w.and(identifier_table[:namespace_id].eq(namespace_id)) if namespace_id

    referenced_klass_container_identifiers.where(w)
  end

  def identifier_between_container_match
    return nil if @identifier_start.nil?
    @identifier_end = @identifier_start if @identifier_end.nil?

    w = between
    w = w.and(identifier_table[:namespace_id].eq(namespace_id)) if namespace_id # TODO: redundant with namespace facet likely

    referenced_klass_container_identifiers.where(w)
  end

  # Objects with/out local identifiers by proxy of
  # of their containment.
  def local_identifiers_container_match
    return nil if local_identifiers.nil?

    s = "WITH identified_containers AS (#{identified_containers.where("identifiers.type ILIKE 'Identifier::Local%'").to_sql}) "
    s << referenced_klass_with_container_items
      .joins("JOIN identified_containers AS identified_containers1 on identified_containers1.id = ci2.contained_object_id and ci2.contained_object_type = 'Container'").to_sql

    q = referenced_klass.from( "(#{s}) as #{table.name}")

    if local_identifiers
      q
    else
      # If we don't need to exclude objects from containers that don't have (local) identifiers.
      nil
    end
  end

  def identifiers_container_match
    return nil if identifiers.nil?

    s = "WITH identified_containers AS (#{identified_containers.to_sql}) "
    s << referenced_klass_with_container_items
      .joins("JOIN identified_containers AS identified_containers1 on identified_containers1.id = ci2.contained_object_id and ci2.contained_object_type = 'Container'").to_sql

    q = referenced_klass.from( "(#{s}) as #{table.name}")

    if identifiers
      q
    else
      s = "WITH co_with_identifier_containers as (#{q.to_sql}) " +
      referenced_klass_with_container_items.joins("LEFT JOIN co_with_identifier_containers AS co_with_identifier_containers1 on co_with_identifier_containers1.id = #{table.name}.id")
          .where('co_with_identifier_containers1.id IS NULL').to_sql

      referenced_klass.from( "(#{s}) as #{table.name}")
    end
  end

  def match_identifiers_container_match
    return nil if match_identifiers.blank?
    ids = identifiers_to_match
    return nil if ids.empty?

    if match_identifiers_type&.downcase == 'identifier'
      referenced_klass_container_identifiers.where(identifiers: {cached: ids})
    elsif match_identifiers_type&.downcase == 'dwc_occurrence_id'
      referenced_klass_container_identifiers.where(identifiers: {cached: ids, type: 'Identifier::Global::Uuid::TaxonworksDwcOccurrence' })
    else
      nil # don't match on internal IDs of containers, it doesn't make sense
    end
  end

end
