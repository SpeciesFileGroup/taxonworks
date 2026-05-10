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

    validate :project_foreign_keys_are_in_same_project, if: not_self

    #  before_save :prevent_alteration_in_other_projects
    #  before_destroy :prevent_alteration_in_other_projects

    # extend Project
    Project.class_eval do
      raise 'Class name collision for Project#has_many' if self.methods and self.methods.include?(:related_instances)
      has_many related_instances, class_name: related_class, dependent: :restrict_with_error, inverse_of: :project
    end
  end

  module ClassMethods
    # These overrides scope bare class-level finder calls (e.g.
    # Otu.find_or_create_by!(...)) to Current.project_id when neither
    # project nor project_id is provided.
    #
    # This primarily matters for the find step: without project scoping,
    # a finder could match a record from another project. If the call ends
    # up creating instead, project_id is also passed explicitly, though
    # set_project_id would normally handle that as well.
    def find_or_create_by(attributes, &block)
      super(with_current_project(attributes), &block)
    end

    def find_or_create_by!(attributes, &block)
      super(with_current_project(attributes), &block)
    end

    def find_or_initialize_by(attributes, &block)
      super(with_current_project(attributes), &block)
    end

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

    private

    def with_current_project(attributes)
      h = (attributes || {}).to_h.with_indifferent_access
      return h if h[:project_id].present? || h[:project].present?
      Current.project_id ? h.merge(project_id: Current.project_id) : h
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

  private

  def project_foreign_keys_are_in_same_project
    return unless project_id.present?

    self.class.reflect_on_all_associations(:belongs_to).each do |reflection|
      next if reflection.name == :project

      foreign_key = reflection.foreign_key.to_sym
      next if public_send(foreign_key).blank?

      # Note this is currently n+1 (though very fast fk lookups). We may
      # eventually want to combine these into a single query.
      associated_project_id = associated_project_id_for_validation(reflection, foreign_key)
      next unless associated_project_id.present?
      next if associated_project_id == project_id

      errors.add(foreign_key, "must belong to the same project (record id: #{id} is in project_id: #{project_id}, #{foreign_key}: #{public_send(foreign_key)} is in project_id: #{associated_project_id})")
    end
  end

  def associated_project_id_for_validation(reflection, foreign_key)
    if reflection.polymorphic?
      associated_class_name = public_send(reflection.foreign_type)
      return nil if associated_class_name.blank?

      klass = associated_class_name.safe_constantize
    else
      klass = reflection.klass
    end

    return nil unless klass&.column_names&.include?('project_id')

    klass.where(id: public_send(foreign_key)).pick(:project_id)
  end

end
