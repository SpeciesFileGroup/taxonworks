class AssertedDistribution < ActiveRecord::Base

  include Housekeeping
  include SoftValidation
  include Shared::Notable

  belongs_to :otu
  belongs_to :geographic_area
  belongs_to :source
  #belongs_to :project

  validates_presence_of :otu_id, message: 'Taxon is not specified'
  validates_presence_of :geographic_area_id, message: 'Geographic area is not selected'

  scope :with_otu_id, -> (otu_id) {where(otu_id: otu_id)}
  scope :with_geographic_area_id, -> (geographic_area_id) {where(geographic_area_id: geographic_area_id)}
  scope :with_geographic_area_array, -> (geographic_area_array) {where('geographic_area_id IN (?)', geographic_area_array ) }
  scope :with_is_absent, -> {where('is_absent = true')}
  scope :without_is_absent, -> {where('is_absent = false OR is_absent is Null')}
  scope :not_self, -> (id) {where('asserted_distribution.id <> ?', id )}

  before_validation :check_required_fields

  soft_validate(:sv_missing_source, set: :missing_source)
  soft_validate(:sv_conflicting_geographic_area, set: :conflicting_geographic_area)


  #region Soft validation

  def sv_missing_source
    soft_validations.add(:source_id, 'Source is missing') if self.source_id.nil?
  end

  def sv_conflicting_geographic_area
    unless ga.nil?
      ga = self.geographic_area
      if self.is_absent = TRUE
        presence = AssertedDistribution.without_is_absent.with_geographic_area_id(self.geographic_area_id)
        soft_validations.add(:otu_id, "Taxon is reported as present in #{presence.geographic_area.name}") unless presence.empty?
      else
        areas = [ga.level0_id, ga.level1_id, ga.level2_id].compact
        presence = AssertedDistribution.with_is_absent.with_geographic_area_array(areas)
        soft_validations.add(:otu_id, "Taxon is reported as missing in #{presence.geographic_area.name}") unless presence.empty?
      end
    end
  end

  #end region

end
