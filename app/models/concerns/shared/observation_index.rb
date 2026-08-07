# Shared code for referencing observation_object
module Shared::ObservationIndex 
  extend ActiveSupport::Concern

  included do

    def observation_index
      observation_object_type + observation_object_id.to_s
    end
  end
end
