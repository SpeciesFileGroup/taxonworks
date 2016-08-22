class Observation::Sample < Observation 

  validates_presence_of :sample_n
  validates_presence_of :sample_min
  validates_presence_of :sample_max
  validates_presence_of :sample_median
  validates_presence_of :sample_mean
  validates_presence_of :sample_units
  validates_presence_of :sample_standard_deviation
  validates_presence_of :sample_standard_error

  validate :valid_min_max_boundary
  validate :valid_sample_median

  protected
 
  def valid_min_max_boundary
    :sample_min < :sample_max
  end

  def valid_sample_median
    :sample_median >= :sample_min && :sample_median <= :sample_max
  end
end
