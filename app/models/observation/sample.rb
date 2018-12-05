#   
# See Descriptor::Sample
#
class Observation::Sample < Observation 

  validates_presence_of :sample_min
  
  validate :valid_min_max_boundary
  validate :median_between_min_max
  validate :valid_sample_mean

  protected
 
  def valid_min_max_boundary
    errors.add(:sample_min, 'minimum is greater than maximum' ) if sample_min && sample_max && ( sample_min > sample_max )
    errors.add(:sample_max, 'maximum is less than minimum' ) if sample_min && sample_max && (sample_max < sample_min)
  end

  def median_between_min_max
    if sample_min.present? && sample_max.present? && sample_median.present?
      errors.add(:sample_median, 'is not between min and max)') if !(sample_median <= sample_max) || !(sample_median >= sample_min)
    end
  end

  def valid_sample_mean
    if sample_min.present? && sample_max.present? && sample_mean.present?
      errors.add(:sample_mean, 'is not between min and max)') if !(sample_mean <= sample_max) || !(sample_mean >= sample_min)
    end
  end
  
end
