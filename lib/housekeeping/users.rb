# Concern that provides housekeeping and related methods for models that belong_to a creator and updator
module Housekeeping::Users 
  extend ActiveSupport::Concern

  included do
   related_instances = self.name.demodulize.underscore.pluralize.to_sym # if 'One::Two::Three' gives :threes
   related_class = self.name

    belongs_to :creator, foreign_key: :created_by_id, class_name: 'User'
    belongs_to :updater, foreign_key: :updated_by_id, class_name: 'User'

    validates :creator, presence: true 
    validates :updater, presence: true

    before_validation(on: :create) do
      set_created_by_id
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
    # Returns a scope for all uniq Users that created this class
    def all_creators
     User.joins("created_#{self.name.demodulize.underscore.pluralize}".to_sym).uniq
   end

    # Returns a scope for all uniq Users that updated this class (as currently recorded, does not include Papertrail)
    def all_creators
     User.joins("updated_#{self.name.demodulize.underscore.pluralize}".to_sym).uniq
   end
  end

  # What was intent? recent touch?
  # def alive?
  # end

  def set_created_by_id
    self.created_by_id ||= $user_id
  end

  def set_updated_by_id
    self.updated_by_id ||= $user_id
  end

end

