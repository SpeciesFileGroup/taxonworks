# OTU is defined by name or by taxon_name_id.
# The name should be unique in scope of taxon_name_id.

class Otu < ActiveRecord::Base
  include Housekeeping
  include SoftValidation
  include Shared::Identifiable
  include Shared::Citable        # TODO: have to think hard about this vs. using Nico's framework
  include Shared::Notable
  include Shared::DataAttributes
  include Shared::Taggable
  include Shared::AlternateValues

  belongs_to :taxon_name

  has_many :contents, inverse_of: :otu
  has_many :taxon_determinations, inverse_of: :otu
  has_many :collection_profiles
  has_many :topics, through: :contents, source: :topic

  scope :with_taxon_name_id, -> (taxon_name_id) {where(taxon_name_id: taxon_name_id)}
  scope :with_name, -> (name) {where(name: name)}
  scope :not_self, -> (id) {where('otus.id <> ?', id )}


  #  validates_uniqueness_of :name, scope: :taxon_name_id

  before_validation :check_required_fields

  soft_validate(:sv_taxon_name, set: :taxon_name)
  soft_validate(:sv_duplicate_otu, set: :duplicate_otu)

  def otu_name
    if !self.name.blank?
      self.name
    elsif !self.taxon_name_id.nil?
      self.taxon_name.cached_name_and_author_year
    else
      nil
    end
  end

  #region Validation

  def check_required_fields
    if self.taxon_name_id.nil? && self.name.blank?
      errors.add(:taxon_name_id, 'Name and/or Taxon should be selected')
      errors.add(:name, 'Name and/or Taxon should be selected')
    end
  end

  #end region

  #region Soft validation

  def sv_taxon_name
    soft_validations.add(:taxon_name_id, 'Taxon is not selected') if self.taxon_name_id.nil?
  end

  def sv_duplicate_otu
    unless Otu.with_taxon_name_id(self.taxon_name_id).with_name(self.name).not_self(self.id).with_project_id(self.project_id).empty?
      soft_validations.add(:taxon_name_id, 'Duplicate Taxon and Name combination')
      soft_validations.add(:name, 'Duplicate Taxon and Name combination')
    end
  end
  #endregion

end
