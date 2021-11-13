# A geographic point.
#
class GeographicItem::Point < GeographicItem
  SHAPE_COLUMN = :point
  validates_presence_of :point
  validate :check_point_limits

  # @return [Array] a point
  def to_a
    point_to_a(self.point)
  end

  # @return [RGeo::Point] the first POINT of self
  def st_start_point
    self.geo_object
  end

  # @return [Hash]
  def rendering_hash
    point_to_hash(self.point)
  end

  protected

  # @return [Boolean]
  # true iff point.x is between -180.0 and +180.0
  def check_point_limits
    unless point.nil?
      errors.add(:point_limit, 'Longitude exceeds limits: 180.0 to -180.0.') if point.x > 180.0 || point.x < -180.0
    end
  end

end
