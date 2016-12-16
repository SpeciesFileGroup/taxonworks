
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
class DwcOccurrence < ActiveRecord::Base
  self.inheritance_column = nil 

  include Housekeeping

  belongs_to :dwc_occurrence_object, polymorphic: true 

  before_validation :set_basis_of_record
  validates_presence_of :basisOfRecord

  validates :dwc_occurrence_object, presence: true
  validates_uniqueness_of :dwc_occurrence_object_id, scope: [:dwc_occurrence_object_type, :project_id]

  def basis 
    case dwc_occurrence_object_type
    when 'CollectionObject'
     'PreservedSpecimen'
    when 'AssertedDistribution'
      case dwc_occurrence_object.source.try(:type)
      when 'Source::Bibtex'
        'Occurrence'
      when 'Source::Human'
        'HumanObservation'
      else
        nil
      end
    else
      nil 
    end
  end

  def stale? 
     dwc_occurrence_object.updated_at > updated_at
  end

  protected
 
  def set_basis_of_record
    write_attribute(:basisOfRecord, basis)
  end

end
