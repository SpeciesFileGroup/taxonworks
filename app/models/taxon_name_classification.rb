class TaxonNameClassification < ActiveRecord::Base
  belongs_to :taxon_name

  validates_presence_of  :taxon_name_id, :type

  include SoftValidation
  before_validation :validate_taxon_name_class_class
  soft_validate(:sv_proper_classification)

  def type_name
    TAXON_NAME_CLASS_NAMES.include?(self.type) ? self.type.to_s : nil
  end

  def type_class=(value)
    write_attribute(:type, value.to_s)
  end

  def type_class
    r = read_attribute(:type)
    TAXON_NAME_CLASS_NAMES.include?(r) ? r.constantize : r
  end

  def validate_taxon_name_class_class
    errors.add(:type, "status not found") if !TAXON_NAME_CLASS_NAMES.include?(self.type.to_s)
  end

  #region Soft validation

  def sv_proper_classification
    if TAXON_NAME_CLASS_NAMES.include?(self.type.to_s)
      t = self.type.constantize
      if !t.applicable_ranks.include?(self.taxon_name.rank_class.to_s)
        soft_validation.add(:type, 'The status is unapplicable to the name of ' + self.taxon_name.rank_class.rank_name + ' rank')
      end
    end
  end

  #endregion
end
