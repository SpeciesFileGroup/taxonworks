class ObservationMatrixRow < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include Shared::Identifiers
  include Shared::IsData
  include Shared::Tags
  include Shared::Notes

  acts_as_list

  belongs_to :observation_matrix, inverse_of: :observation_matrix_rows
  belongs_to :otu, inverse_of: :observation_matrix_rows
  belongs_to :collection_object, inverse_of: :observation_matrix_rows

  after_initialize :set_reference_count

  validates_presence_of :observation_matrix
  validate :otu_and_collection_object_blank
  validate :otu_and_collection_object_given
  validates_uniqueness_of :otu_id, scope: [:observation_matrix_id], if: -> {!otu_id.nil?}
  validates_uniqueness_of :collection_object_id, scope: [:observation_matrix_id], if: -> {!collection_object_id.nil?}

  def set_reference_count
    self.reference_count ||= 0
  end

  def row_object
    [otu, collection_object].compact.first
  end

  private

  def otu_and_collection_object_blank
    if otu_id.nil? && collection_object_id.nil?
      errors.add(:base, 'Specify otu OR collection object!')
    end
  end

  def otu_and_collection_object_given
    if !otu_id.nil? && !collection_object_id.nil?
      errors.add(:base, 'Specify otu OR collection object, not both!')
    end
  end
end
