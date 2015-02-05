class GeographicItem::Point < GeographicItem
  SHAPE_COLUMN = :point
  validates_presence_of :point
  validate :check_point_limits

  def to_a
    point_to_a(self.point)
  end

  # @return [RGeo::Feature::Point] 
  #   the first POINT of self 
  def st_start_point
    self.geo_object
  end

  def rendering_hash
    point_to_hash(self.point)
  end

  protected

  def check_point_limits
    unless point.nil?
      errors.add(:point_limit, 'Longitude exceeds limits: 180.0 to -180.0.') if point.x > 180.0 || point.x < -180.0
    end
  end




end
