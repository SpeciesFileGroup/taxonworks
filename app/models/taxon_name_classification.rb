class TaxonNameClassification < ActiveRecord::Base
  belongs_to :taxon_name

  validates_presence_of  :taxon_name_id, :type

  before_validation :validate_taxon_name_class_class

  def validate_taxon_name_class_class
    errors.add(:type, "status not found") if !TAXON_NAME_CLASS_NAMES.include?(self.type.to_s)
  end
end
