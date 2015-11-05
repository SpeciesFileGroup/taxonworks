# Shared code for...
#
module Shared::Containable
  extend ActiveSupport::Concern

  included do
    has_one :container_item, as: :contained_object
    has_one :container, through: :container_item

    accepts_nested_attributes_for :container
  end 

  def contained?
    !self.container.nil?
  end

  # @return [Array of {Container}s]
  #   the full Russian doll stack
  def all_containers
    return [] if container.nil?
    container.self_and_ancestors.to_a
  end

  # @return [String, nil]
  #    a string representation of the containers location, includes disposition of the containers if provided
  def location 
    parts = [] 
    all_containers.each do |c| 
      s = c.name.blank? ? c.class.class_name : c.name
      s += " [#{c.disposition}]" if !c.disposition.blank? 
      parts.push s 
    end
    parts.join("; ") 
  end

end
