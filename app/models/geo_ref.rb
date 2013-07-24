class GeoRef < ActiveRecord::Base
  belongs_to :geographic_area
  belongs_to :confidence

  validate :minimal_data_is_provided

  protected

  def minimal_data_is_provided
    [:a_point, :a_line, :a_polygon, :a_multi_polygon].each do |ref|
      return true if !self.send(ref).blank?
    end

    error.add(:cached_display, 'Must contain at least one of [a_point, a_line, a_polygon, :a_multi_polygon].')
  end
end
