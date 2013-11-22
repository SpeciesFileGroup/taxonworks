# Concern the provides housekeeping and related methods for models that belong_to a Project
module Housekeeping::Projects 
  
  extend ActiveSupport::Concern
  included do
    belongs_to :project
  end

  module ClassMethods
  end
end

