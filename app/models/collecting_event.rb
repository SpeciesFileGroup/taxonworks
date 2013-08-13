class CollectingEvent < ActiveRecord::Base
  belongs_to :geographic_area
  belongs_to :confidence

  validate :minimal_data_is_provided

  protected

  def minimal_data_is_provided
    [:verbatim_label, :print_label, :document_label, :field_notes].each do |v|
      return true if !self.send(v).blank?
    end

    errors.add(:cached_display, 'At least one label type, or field notes, need to be minimally provided.')
  end


end
