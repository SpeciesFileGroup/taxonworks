# An AssertedEnvironment is the assertion that an environment, drawn from the
# Environment Ontology (ENVO), characterizes some record - see
# ENVIRONMENT_ASSERTABLE_TYPES for what those records can be.
#
# Unlike AnatomicalPart, AssertedEnvironment does not accept a free-text
# `name` - only ENVO-backed uri/uri_label pairs are permitted (see
# Vendor::Envo). This is deliberate - we want to see how well ENVO alone can
# hold up rather than accumulate uncontrolled local terms.
#
# `position` provides a simple ordering, not a category - each larger
# position is understood to be some refinement of the ones before it (e.g.
# "terrestrial biome" then "temperate forest biome").
#
# @!attribute asserted_environment_object_type
#   @return [String]
#   polymorphic object type
#
# @!attribute asserted_environment_object_id
#   @return [Integer]
#   polymorphic object ID
#
# @!attribute uri
#   @return [String]
#   the ENVO term URI (OBO Library PURL)
#
# @!attribute uri_label
#   @return [String]
#   the label of the ENVO term at uri
#
# @!attribute position
#   @return [Integer]
#   for acts_as_list, scoped to the asserted environment object; larger values
#   are refinements of smaller ones
#
# @!attribute cached
#   @return [String]
#   cached uri_label
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class AssertedEnvironment < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include Shared::DataAttributes
  include Shared::Identifiers
  # Override the :uri defined by Identifiers, which otherwise shadows the
  # asserted_environment's own `uri` column/validations. Bad, same as
  # AnatomicalPart.
  def uri
    self[:uri]
  end
  include Shared::Notes
  include Shared::Tags
  include Shared::DwcOccurrenceHooks
  include Shared::IsData
  include Shared::BatchByFilterScope

  acts_as_list scope: [:project_id, :asserted_environment_object_type, :asserted_environment_object_id]

  belongs_to :asserted_environment_object, polymorphic: true

  after_save :set_cached

  validates_presence_of :asserted_environment_object
  validates_presence_of :uri
  validates_presence_of :uri_label
  validate :asserted_environment_object_has_allowed_type
  validate :uri_is_an_envo_term
  validates_uniqueness_of :uri, scope: [
    :project_id, :asserted_environment_object_type, :asserted_environment_object_id
  ]

  # @return [Scope]
  #   DwcOccurrence records potentially affected by this asserted environment;
  #   only CollectingEvent assertions feed dwc:habitat (see
  #   Shared::Dwc::CollectingEventExtensions#dwc_habitat), so other object
  #   types have no corresponding DwcOccurrence records to rebuild.
  def dwc_occurrences
    return DwcOccurrence.none unless asserted_environment_object_type == 'CollectingEvent'

    a = DwcOccurrence
      .joins("JOIN collection_objects co on dwc_occurrence_object_id = co.id AND dwc_occurrence_object_type = 'CollectionObject'")
      .where(co: {collecting_event_id: asserted_environment_object_id})

    b = DwcOccurrence
      .joins("JOIN field_occurrences fo on dwc_occurrence_object_id = fo.id AND dwc_occurrence_object_type = 'FieldOccurrence'")
      .where(fo: {collecting_event_id: asserted_environment_object_id})

    ::Queries.union(DwcOccurrence, [a, b])
  end

  # Only mode :add is supported - assert the ENVO term in params (uri,
  # uri_label) on every object returned by query, optionally with a citation
  # (params[:citation], like { source_id:, pages:, is_original: }).
  #
  # If the object already has an asserted environment for the term then the
  # citation, when provided and not already present, is added to that
  # existing asserted environment, otherwise the object is not updated.
  #
  # updated are AssertedEnvironment ids, not_updated are object ids.
  def self.process_batch_by_filter_scope(
    batch_response: nil, query: nil, hash_query: nil, mode: nil, params: nil,
    async: nil, project_id: nil, user_id: nil,
    called_from_async: false
  )
    # Don't call async from async (the point is we do the same processing in
    # async and not in async, and this function handles both that processing and
    # making the async call, so it's this much janky).
    async = false if called_from_async == true
    r = batch_response

    if mode.to_sym != :add
      r.errors["unsupported mode '#{mode}'"] = 1
      return r
    end

    object_type = query.klass.base_class.name
    if !ENVIRONMENT_ASSERTABLE_TYPES.include?(object_type)
      r.errors["asserted environments can not be added to #{object_type}"] = 1
      return r
    end

    if params[:uri].blank? || params[:uri_label].blank?
      r.errors['uri and uri_label are required'] = 1
      return r
    end

    if async && !called_from_async
      BatchByFilterScopeJob.perform_later(
        klass: self.name,
        hash_query:,
        mode:,
        params:,
        project_id:,
        user_id:
      )
    else
      citation_params = params[:citation]&.to_h&.symbolize_keys&.compact_blank

      query.find_each do |o|
        add_by_batch(o, params[:uri], params[:uri_label], citation_params, r)
      end
    end

    r
  end

  # @param citation_params [Hash, nil] attributes for a new Citation
  # @param r [BatchResponse] updated with the result for object
  def self.add_by_batch(object, uri, uri_label, citation_params, r)
    existing = AssertedEnvironment.find_by(
      asserted_environment_object: object, uri:
    )

    if existing
      if citation_params.blank?
        r.not_updated.push object.id
        r.validation_errors['asserted environment already exists'] += 1
        return
      end

      citation = existing.citations.create(citation_params)
      if citation.persisted?
        r.updated.push existing.id
      else
        r.not_updated.push object.id
        citation.errors.full_messages.each { |msg|
          r.validation_errors["citation not added to existing asserted environment: #{msg}"] += 1
        }
      end

      return
    end

    a = AssertedEnvironment.create(
      asserted_environment_object: object,
      uri:,
      uri_label:,
      citations_attributes: citation_params.present? ? [citation_params] : []
    )

    if a.persisted?
      r.updated.push a.id
    else
      r.not_updated.push object.id
      a.errors.full_messages.each { |msg|
        r.validation_errors[msg] += 1
      }
    end
  end

  protected

  def set_cached
    update_column(:cached, uri_label)
  end

  def asserted_environment_object_has_allowed_type
    t = asserted_environment_object_type&.to_s # STRING (not symbol)

    if !ENVIRONMENT_ASSERTABLE_TYPES.include?(t)
      errors.add(t || :base, " - the type of this asserted environment's object can only be one of #{ENVIRONMENT_ASSERTABLE_TYPES}, not '#{t}'")
    end
  end

  def uri_is_an_envo_term
    return if uri.blank?

    errors.add(:uri, 'must be an ENVO term URI') unless Vendor::Envo.valid_uri?(uri)
  end
end
