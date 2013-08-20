class Geographic_Item < ActiveRecord::Base
  belongs_to :geographic_area
  belongs_to :confidence

  validate :minimal_data_is_provided

  protected

  def minimal_data_is_provided
    [:a_point,
     :a_simple_line,
     :a_complex_line,
     :a_linear_ring,
     :a_polygon,
     :a_multi_point,
     :a_multi_line_string,
     :a_multi_polygon,
     :a_geometry_collection].each do |item|
      #return true if !self.send(item).blank?
      if (self.send(item).blank?)
        # continue checking
      else
        return true
      end
    end

    error.add(:cached_display, 'Must contain at least one of [a_point, a_line_string, a_polygon, :a_multi_polygon].')
  end
end
