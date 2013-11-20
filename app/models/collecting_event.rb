class CollectingEvent < ActiveRecord::Base

  include Shared::Citable  # ?

  # several lines commented out per Matt ('old stuff')
  # belongs_to :geographic_area
  # belongs_to :confidence

  has_many :collector_roles, class_name: 'Role::Collector', as: :role_object
  has_many :collectors, through: :collector_roles, source: :person

  # validate :minimal_data_is_provided
  # protected

=begin
  def minimal_data_is_provided
    [:verbatim_label, :print_label, :document_label, :field_notes].each do |v|
      return true if !self.send(v).blank?
    end

    errors.add(:cached_display, 'At least one label type, or field notes, need to be minimally provided.')
  end
=end


end
