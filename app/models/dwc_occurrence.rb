
# A Darwin Core Record for the Occurence core.  Field generated from Ruby dwc-meta, which references
# the same spec that is used in the IPT, and the Dwc Assistant.  Each record
# references a specific CollectionObject or AssertedDistribution.
#
# Important: This is a cache/index, data here are periodically (regenerated) from multiple tables in TW.
#
# TODO: The basisOfRecord CVTs are not super informative.
#    We know collection object is definitely 1:1 with PreservedSpecimen, however
#    AssertedDistribution could be HumanObservation (if source is person), or ... what? if
#    its a published record.  Seems we need a 'PublishedAssertation', just like we model the data.
#
# DWC attributes are camelCase to facilitate matching
# dwcClass is a replacement for the Rails reserved 'Class'
#
#
# All DC attributes (attributes not in DwcOccurrence::TW_ATTRIBUTES) in this table are namespaced to dc ("http://purl.org/dc/terms/", "http://rs.tdwg.org/dwc/terms/")
#
class DwcOccurrence < ApplicationRecord
  self.inheritance_column = nil

  include Housekeeping

  DC_NAMESPACE = 'http://rs.tdwg.org/dwc/terms/'.freeze

  # Not yet implemented, but likely needed
  # ? :id
  TW_ATTRIBUTES = [
    :project_id,
    :created_at,
    :updated_at,
    :created_by_id,
    :updated_by_id,
    :dwc_occurrence_object_type,
    :dwc_occurence_object_id
  ].freeze

  HEADER_CONVERTERS = {
    'dwcClass' => 'class',
  }.freeze

  CSV::HeaderConverters[:dwc_headers] = lambda do |field|
    d = DwcOccurrence::HEADER_CONVERTERS[field]
    d ? d : field
  end

  belongs_to :dwc_occurrence_object, polymorphic: true

  def self.collection_objects_join
    a = arel_table
    b = ::CollectionObject.arel_table 
    j = a.join(b).on(a[:dwc_occurrence_object_type].eq('CollectionObject').and(a[:dwc_occurrence_object_id].eq(b[:id])))
    joins(j.join_sources)
#    joins("JOIN collection_objects on collection_objects.id = dwc_occurrences.dwc_occurrence_object_id AND dwc_occurrence_object_type = 'CollectionObject'")
  end

  before_validation :set_basis_of_record
  validates_presence_of :basisOfRecord

  validates :dwc_occurrence_object, presence: true
  validates_uniqueness_of :dwc_occurrence_object_id, scope: [:dwc_occurrence_object_type, :project_id]

  # @return [Scope]
  def self.computed_columns
    select(['id', 'basisOfRecord'] + CollectionObject::DwcExtensions::DWC_OCCURRENCE_MAP.keys)
  end

  def basis
    case dwc_occurrence_object_type
    when 'CollectionObject'
      return 'PreservedSpecimen'
    when 'AssertedDistribution'
      case dwc_occurrence_object.source.try(:type)
      when 'Source::Bibtex'
        return 'Occurrence'
      when 'Source::Human'
        return 'HumanObservation'
      end
    end
    'Undefined'
  end

  def stale?
    dwc_occurrence_object.updated_at > updated_at
  end

  protected

  def set_basis_of_record
    write_attribute(:basisOfRecord, basis)
  end

end
