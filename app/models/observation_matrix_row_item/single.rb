class ObservationMatrixRowItem::Single < ObservationMatrixRowItem
  belongs_to :observation_object, polymorphic: true

  validates_presence_of :observation_object
  validate :observation_object_is_unique_in_matrix

  def is_dynamic?
    false
  end

  def matrix_row_item_object
    observation_object
  end

  # Note:
  #   replaces deprecated `otus` and `collection_objects` methods
  def row_objects
    [ observation_object ]
  end

  private

  def observation_object_is_unique_in_matrix
    if ObservationMatrixRowItem::Single.where(
        observation_matrix_id: observation_matrix_id,
        observation_object: observation_object).where.not(id: id).any?
      errors.add(:observation_object, 'already exists in a row item in this matrix')
    end
  end


end
