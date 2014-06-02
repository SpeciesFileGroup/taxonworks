# Concern the provides housekeeping and related methods for models that belong_to a Project
module Housekeeping::Projects 
  extend ActiveSupport::Concern

  included do
   # not added to the model, just used to extend models here
   related_instances = self.name.demodulize.underscore.pluralize.to_sym # if 'One::Two::Three' gives :threes
   related_class = self.name

   # these are added to the model 
   belongs_to :project, inverse_of: related_instances 

   before_validation :set_project_id, on: :create
   validates :project, presence: true

   before_save :prevent_alteration_in_other_projects
   before_destroy :prevent_alteration_in_other_projects

    # Also extend the project 
    Project.class_eval do
      raise 'Class name collision for Project#has_many' if self.methods and self.methods.include?(:related_instances)
      has_many related_instances, class_name: related_class # inverse_of: :project,
    end
  end

  module ClassMethods

    # Scopes
    def in_project(project)
      where(project: project)
    end

    def with_project_id(project_id)
      where(project_id: project_id)
    end

  end

  def set_project_id
    self.project_id ||= $project_id
  end

  # This will have to be extended via role exceptions, maybe.  It is a loose
  # check here, ripped right from mx.
  def prevent_alteration_in_other_projects 
  # unless (self.project_id == $project_id)
  #   raise 'Not owned by current project: ' + self.name + '#' + self.id.to_s
  # end
  end

end

