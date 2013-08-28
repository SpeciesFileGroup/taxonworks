class TaxonName < ActiveRecord::Base

  validates_presence_of :name, :rank_class, :type
  
  before_validation :set_type_if_empty,
                    :check_format_of_name,
                    :validate_rank_class_class


  after_validation :set_cached_name

  def rank
    if ::RANK_CLASS_NAMES.include?(self.rank_class.to_s) 
      rank_class.constantize.rank_name 
    else
      nil
    end
  end

  protected 

  def set_type_if_empty
    self.type = Protonym if self.type.nil?
  end

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
