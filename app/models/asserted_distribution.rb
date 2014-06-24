class AssertedDistribution < ActiveRecord::Base

  include Housekeeping::Users
  include SoftValidation

  belongs_to :otu
  belongs_to :geographic_area
  belongs_to :source
  belongs_to :project

  validates_presence_of :otu_id, :geographic_area_id

  scope :with_otu_id, -> (otu_id) {where(otu_id: otu_id)}
  scope :with_geographic_area_id, -> (geographic_area_id) {where(geographic_area_id: geographic_area_id)}
  scope :not_self, -> (id) {where('asserted_distribution.id <> ?', id )}


  #  validates_uniqueness_of :name, scope: :taxon_name_id

  before_validation :check_required_fields

  soft_validate(:sv_missing_source, set: :missing_source)


  #region Soft validation

  def sv_missing_source
    soft_validations.add(:source_id, 'Source is missing') if self.source_id.nil?
  end

  #end region

end
