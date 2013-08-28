class TaxonName < ActiveRecord::Base

  validates_presence_of :name, :rank_class
  before_validation :check_format_of_name,
                    :validate_rank_class_class

  after_validation :set_cached_name

  def rank
    rank_class.constantize.rank_name
  end

  protected 

  def validate_rank_class_class
    errors.add(:rank_class, "rank not found") if !::RANK_CLASS_NAMES.include?(self.rank_class.to_s) 
  end

  # TODO: This should be based on the logic of the related rank
  def set_cached_name
    true 
  end

  def check_format_of_name
    if self.rank_class && self.rank_class.respond_to?(:validate_name_format)
      self.rank_class.validate_name_format(self)
    end
  end

end
