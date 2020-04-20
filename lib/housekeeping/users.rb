# Concern that provides housekeeping and related methods for models that belong_to a creator and updator
module Housekeeping::Users
  extend ActiveSupport::Concern

  included do
    related_instances = self.name.demodulize.underscore.pluralize.to_sym # if 'One::Two::Three' then :threes
    related_class = self.name

    belongs_to :creator, foreign_key: :created_by_id, class_name: 'User'
    belongs_to :updater, foreign_key: :updated_by_id, class_name: 'User'

#   scope :created_by_user, ->(user) { where(created_by_id: User.get_user_id(user) ) }
#   scope :updated_by_user, ->(user) { where(updated_by_id: User.get_user_id(user) ) }

    scope :created_or_updated_by, -> (user_id) { where(created_by_id: user_id).or(where(updated_by_id: user_id)) }

    unless_user = lambda { self.class.name == 'User' && self.self_created }
    validates :creator, presence: true, unless: unless_user # lambda, proc, or block
    validates :updater, presence: true, unless: unless_user

    before_validation(on: :create, unless: unless_user) do
      set_updated_by_id
      set_created_by_id
    end

    before_validation(on: :update) do
      set_updated_by_id
    end

    # And extend User
    User.class_eval do
      raise 'Class name collision for User#has_many' if self.methods and self.methods.include?(:related_instances)
      has_many "created_#{related_instances}".to_sym, class_name: related_class, foreign_key: :created_by_id, inverse_of: :creator, dependent: :restrict_with_error
      has_many "updated_#{related_instances}".to_sym, class_name: related_class, foreign_key: :updated_by_id, inverse_of: :updater, dependent: :restrict_with_error
    end
  end

  module ClassMethods

    # @return [Scope]
    #   for all uniq Users that created this class
    def all_creators
      User.joins("created_#{self.name.demodulize.underscore.pluralize}".to_sym).uniq
    end

    # @return [Scope]
    #   scope for all uniq Users that updated this class (as currently recorded, does not include Papertrail)
    def all_updaters
      User.joins("updated_#{self.name.demodulize.underscore.pluralize}".to_sym).uniq
    end
  end

  # A convenience.  When provided creator and updater are set.  If creator exists updater is set.  Overrides creator/updater if provided second.  See tests.
  #   Otu.new(name: 'Aus', by: @user)
  attr_accessor :by

  # rubocop:disable Lint/ReturnInVoidContext
  # @return [self, nil]
  #   a new_record settor to set both creator and updater
  def by=(value)
    @by = value
    return nil if value.nil? || !value.class == User # || !self.created_by_id.blank? || !self.updated_by_id.blank?
    self.created_by_id = value.to_param if self.created_by_id.blank?
    self.updated_by_id = value.to_param
    self
  end

  protected

  def set_created_by_id
    self.created_by_id ||= Current.user_id
  end

  # TODO: This method _is not_ called in an 'after_save' operation (in User), so this deprecation warning
  # does not apply (?) It _may_ be called in an 'after_save' situation through some other model.
  # It may help to unwind the logic.
  # WRT .changed? vs .saved_changes? Deprecation warning
  def set_updated_by_id
    if (changed? || new_record?) && !updated_by_id_changed? && by.blank?
      self.updated_by_id = Current.user_id
    end
  end

end
