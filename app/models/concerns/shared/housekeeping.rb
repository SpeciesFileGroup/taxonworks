module Shared::ProjectHouseKeeping

  extend ActiveSupport::Concern

  included do
    belongs_to :project
    belongs_to :creator
    belongs_to :modifier 
  end

 end
