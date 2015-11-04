module Housekeeping::AssociationHelpers
  extend ActiveSupport::Concern

  included do

  end


  def has_many_relationships
    Rails.application.eager_load!
    relationships = []

    self.class.reflect_on_all_associations(:has_many).each do |r|
      name = r.name.to_s
      if self.respond_to?(r.name) # && self.send(name).respond_to?(:in_project)
        relationships.push name
      end
    end
    relationships.sort
  end


end

