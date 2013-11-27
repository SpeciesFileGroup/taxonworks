# Concern the provides housekeeping and related methods for models that belong_to a Project
module Housekeeping::Projects 

  extend ActiveSupport::Concern

  included do
    related_instances = self.name.demodulize.underscore.pluralize.to_sym
    related_class = self.name

    belongs_to :project, inverse_of: related_instances 

    before_validation :set_project_id, on: :create

    validates :project, presence: true

     Project.class_eval do
       raise 'Class name collision for Project#has_many' if self.methods.include?(:related_instances)
       has_many related_instances, inverse_of: :project, class_name: related_class
     end
  end

  module ClassMethods
  end

  def set_project_id
    self.project_id ||= $project_id
  end

end

