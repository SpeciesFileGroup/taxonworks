# Concern that provides housekeeping and related methods for models that belong_to a creator and updator
module Housekeeping::Users 
  extend ActiveSupport::Concern

  included do
   related_instances = self.name.demodulize.underscore.pluralize.to_sym # if 'One::Two::Three' gives :threes
   related_class = self.name

    belongs_to :creator, foreign_key: :created_by_id, class_name: 'User'
    belongs_to :updater, foreign_key: :updated_by_id, class_name: 'User'

    validates :creator, presence: true, unless: 'self.class.name == "User" && self.self_created'
    validates :updater, presence: true, unless: 'self.class.name == "User" && self.self_created'

    before_validation(on: :create, unless: 'self.class.name == "User" && self.self_created') do
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

  protected

  def set_created_by_id
    self.created_by_id ||= $user_id
  end

  # TODO: test this
  def set_updated_by_id
    if !self.updated_by_id_changed?
      self.updated_by_id = $user_id
    end
  end

end

