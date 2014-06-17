class Otu < ActiveRecord::Base
  include Housekeeping
  include Shared::Identifiable
  include Shared::Citable        # TODO: have to think hard about this vs. using Nico's framework
  include Shared::Notable
  include Shared::DataAttributes
  include Shared::Taggable
  include Shared::AlternateValues
  include SoftValidation

  belongs_to :taxon_name

  has_many :contents, inverse_of: :otu
  has_many :taxon_determinations, inverse_of: :otu
  has_many :collection_profiles
  has_many :topics, through: :contents, source: :topic

  before_validation :check_required_fields

  soft_validate(:sv_taxon_name, set: :taxon_name)

  def otu_name
    if !self.name.blank?
      self.name
    elsif !self.taxon_name_id.nil?
      self.taxon_name.cached_name + ' ' + self.taxon_name.cached_author_year
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

  #endregion

end
