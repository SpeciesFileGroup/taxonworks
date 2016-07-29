# Shared code for...
#
module Shared::Containable
  extend ActiveSupport::Concern

  included do

    attr_accessor :contained_in

    after_save :contain, if: '!contained_in.blank?'

    has_one :container_item, as: :contained_object
    has_one :parent_container_item, through: :container_item, source: :parent, class_name: 'ContainerItem'
    has_one :container, through: :parent_container_item, source: :contained_object, source_type: 'Container'
  end 

  def contain
    put_in_container(contained_in)
  end

  # @return [Boolean]
  #   true if item is placed in container, false if not
  def put_in_container(kontainer)
    return false if self.new_record? || kontainer.new_record?
    kontainer.add_container_items([self])
  end

  # @return [Array]
  #    return all Containers containing this container
  def enclosing_containers
    return [] if !contained?
    container_item.ancestors.map(&:contained_object)
  end

  # @return [True]
  #   this instance is containable
  def containable?
    true
  end

  # return [Boolean]
  #   whether this item is contained in something else
  def contained?
    !container.nil?
  end

  # return [Boolean]
  #   whether this object is contained by the passed container 
  def contained_by?(kontainer)
    enclosing_containers.include?(kontainer)
  end


  # @return [String, nil]
  #    a string representation of the containers location, includes disposition of the containers if provided
 #def location 
 #  parts = [] 
 #  enclosing_containers.each do |c| 
 #    s = c.name.blank? ? c.class.class_name : c.name
 #    s += " [#{c.disposition}]" if !c.disposition.blank? 
 #    parts.push s 
 #  end
 #  parts.join("; ") 
 #end




  
end
