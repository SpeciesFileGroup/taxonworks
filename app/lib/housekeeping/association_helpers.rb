module Housekeeping::AssociationHelpers
  extend ActiveSupport::Concern

  # @return [Array of Strings]
  #   the non-abstract has_many class names for this instance
  def has_many_relationships
    # Rails.application.eager_load!
    relationships = []

    self.class.reflect_on_all_associations(:has_many).each do |r|
      name = r.name.to_s
      if self.respond_to?(r.name) && !r.klass.abstract_class?
        relationships.push name
      end
    end
    relationships.sort
  end

  # @return [Array of Classes]
  #   the non-abstract has_many Classes for this instance
  def has_many_relationship_classes
    # Rails.application.eager_load!
    relationships = []

    self.class.reflect_on_all_associations(:has_many).each do |r|
      name = r.name.to_s
      if self.respond_to?(r.name) && !r.klass.abstract_class?
        relationships.push r.klass
      end
    end
    relationships.sort{|a,b| a.name <=> b.name}
  end


end
