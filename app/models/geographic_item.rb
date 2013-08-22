class GeographicItem < ActiveRecord::Base

  DATA_TYPES = [:point,
                :line_string,
                :polygon,
                :multi_point,
                :multi_line_string,
                :multi_polygon,
                :geometry_collection]

  belongs_to :geographic_area
  belongs_to :confidence

  validate :proper_data_is_provided

  def object
    return false if self.new_record?
    DATA_TYPES.each do |t|
      return self.send(t) if !self.send(t).nil?
    end
  end

  def contains?(item)
    self.object.contains?(item.object)
    #true
  end
  protected

  def proper_data_is_provided
    data = []
    DATA_TYPES.each do |item|
      data.push(item) if !self.send(item).blank?
    end

    case
      when data.length == 0
        errors.add(:point, 'Must contain at least one of [point, line_string, etc.].')
      when data.length > 1
        data.each do |object|
          errors.add(object, 'Only one of [point, line_string, etc.] can be provided.')
        end
      else
        true
    end
  end
end
