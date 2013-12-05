class TaxonNameClassification < ActiveRecord::Base

  include Housekeeping

  belongs_to :taxon_name

  validates_presence_of  :taxon_name_id, :type
  before_validation :validate_taxon_name_class_class

  include SoftValidation
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

  #TODO: validate, that all the taxon_classes in the table could be linked to taxon_classes in classes (if those had changed)

  #region Soft validation

  def sv_proper_classification
    # type is a string already 
    if TAXON_NAME_CLASS_NAMES.include?(self.type)
      # self.type_class is a Class
      if not self.type_class.applicable_ranks.include?(self.taxon_name.rank_class.to_s)
        soft_validations.add(:type, 'The status is unapplicable to the name of ' + self.taxon_name.rank_class.rank_name + ' rank')
      end
    end
    y = self.taxon_name.year_of_publication
    if not y.nil?
      if y > self.type_class.code_applicability_end_year || y < self.type_class.code_applicability_start_year
        soft_validations.add(:type, 'The status is unapplicable to the name published in ' + y.to_s)
      end
    end
  end

  #endregion
end
