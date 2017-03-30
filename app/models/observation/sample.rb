#   
# See Descriptor::Sample
#
class Observation::Sample < Observation 

  validates_presence_of :sample_min
  
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
