class ObservationMatrixColumn < ApplicationRecord
  include Housekeeping
  include Shared::IsData
  include Shared::Taggable
  include Shared::Notable

  belongs_to :observation_matrix
  belongs_to :descriptor

  after_initialize :set_reference_count

  def set_reference_count
    self.reference_count ||= 0
  end

  acts_as_list

  validates_presence_of :observation_matrix, :descriptor
  validates_uniqueness_of :descriptor_id, scope: [:observation_matrix_id, :project_id]

end
