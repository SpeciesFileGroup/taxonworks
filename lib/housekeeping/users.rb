
# Concern the provides housekeeping and related methods for models that belong_to a creator and updator
module Housekeeping::Users 
  extend ActiveSupport::Concern

  included do
    belongs_to :creator, foreign_key: :created_by_id
    belongs_to :updater, foreign_key: :updated_by_id
  end

  module ClassMethods
  end

end

