# Concern that provides housekeeping and related methods for models that belong_to a creator and updator
module Housekeeping::Users 
  extend ActiveSupport::Concern

  included do
    belongs_to :creator, foreign_key: :created_by_id, class_name: 'User'
    belongs_to :updater, foreign_key: :updated_by_id, class_name: 'User'

    validates :creator, presence: true 
    validates :updater, presence: true

    before_validation(on: :create) do
      set_created_by_id
      set_updated_by_id 
    end
  end

  module ClassMethods

    def all_creators
      #User
    end

  end

  def alive?
  end

  def set_created_by_id
    self.created_by_id ||= $user_id
  end

  def set_updated_by_id
    self.updated_by_id ||= $user_id
  end

end

