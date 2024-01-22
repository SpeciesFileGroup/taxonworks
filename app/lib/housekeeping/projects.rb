# Concern the provides housekeeping and related methods for models that belong_to a Project
module Housekeeping::Projects
  extend ActiveSupport::Concern

  included do
    # Not added to the model, just used to extend models here
    # !! you must singularize then pluralize to get in inflections applied
    related_instances = self.name.demodulize.underscore.singularize.pluralize.to_sym # if 'One::Two::Three' gives :threes
    related_class     = self.name

    # these are added to the model
    belongs_to :project, inverse_of: related_instances

    not_self = lambda {!self.annotates_community_object?}
    before_validation :set_project_id, if: not_self # 'self.annotates? && self.annotates_community?'
    validates :project, presence: true, if: not_self # 'self.annotates? && self.annotates_community?'

    #  before_save :prevent_alteration_in_other_projects
    #  before_destroy :prevent_alteration_in_other_projects

    # extend Project
    Project.class_eval do
      raise 'Class name collision for Project#has_many' if self.methods and self.methods.include?(:related_instances)
      has_many related_instances, class_name: related_class, dependent: :restrict_with_error, inverse_of: :project
    end
  end

  module ClassMethods
    # Scopes
    # @param [Project] project
    # @return [Scope]
    def in_project(project)
      where(project:)
    end

    # @param [Integer] project_id
    # @return [Scope]
    def with_project_id(project_id)
      where(project_id:)
    end
  end

  def set_project_id
    if self.new_record?
      self.project_id ||= Current.project_id
    end
  end

  # This will have to be extended via role exceptions, maybe.  It is a loose
  # check here, ripped right from mx.
  #def prevent_alteration_in_other_projects
  #  # unless (self.project_id == Current.project_id)
  #  #   raise 'Not owned by current project: ' + self.name + '#' + self.id.to_s
  #  # end
  #end

  # @return [Boolean]
  def annotates_community_object?
    self.respond_to?(:is_community_annotation?) && self.is_community_annotation?
  end

  # @return [Boolean]
  def is_community?
    (self.class <= Shared::SharedAcrossProjects) ? true : false
  end

end
