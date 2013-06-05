class SpecimenContainer < ActiveRecord::Base
  belongs_to :specimen_id
  belongs_to :container_id
end
