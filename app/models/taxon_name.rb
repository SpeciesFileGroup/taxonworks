class TaxonName < ActiveRecord::Base

  validates_presence_of :name, :rank_class
  validate :rank_class_is_a_nomenclatural_rank
  before_validation :check_format_of_name,
                    :validate_rank_class,
                    :serialize_rank_class

  after_validation :set_cached_name

  def rank
    rank_class.constantize.rank_name
  end

  def rank_class
    
    if rank.nil?
      nil
    else
      self.rank.to_s.constantize 
    end
  end


  def rank_class=(rank_class)
    rank_class ||= "blorf"
    rank_class 
  end

  protected 

  def validate_rank_class 
    errors.add(:rank_class, "rank not found") if !::RANKS.include?(self.classified_rank)
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
