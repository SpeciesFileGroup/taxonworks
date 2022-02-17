class ObservationMatrixRowItem::Dynamic::Tag < ObservationMatrixRowItem::Dynamic

  validate :value_of_observation_object_type
  validate :keyword_is_unique

  def observation_objects
    d = []
    OBSERVABLE_TYPES.each do |t| # Currently assumes all types are may be tagged, could do a simple check
      d += t.safe_constantize.joins(:tags).where(tags: {keyword: observation_object}).to_a
    end
    d
  end

  def matrix_row_item_object
    controlled_vocabulary_term
  end

  private

  def keyword_is_unique
    errors.add(:observation_object, 'is already taken') if ObservationMatrixRowItem::Dynamic::Tag.where.not(id: id).where(
      observation_object: observation_object,
      observation_matrix_id: observation_matrix_id
    ).any?
  end

  def value_of_observation_object_type
    errors.add(:observation_object) if observation_object_type != 'ControlledVocabularyTerm'
  end


end
