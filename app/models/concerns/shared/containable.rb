module Shared::Containable
  extend ActiveSupport::Concern

  included do
    has_one :container_item, as: :contained_object
    has_one :container, through: :container_item
  end 

  def contained?
    !self.container.nil?
  end

  # @return [Array of Object]
  #   self and others in selfs smallest container
  def container_siblings
    self.container.contained_objects
  end

end
