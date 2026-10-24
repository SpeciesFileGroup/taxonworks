module Tag::MatrixHooks
  extend ActiveSupport::Concern

  included do
  
    after_create do
      if %w{Descriptor Otu CollectionObject Extract}.include?(tag_object_type)
        increment_matrix_counts
      end
    end

    after_destroy :purge_from_matrices, if: -> { %w{Descriptor Otu CollectionObject Extract}.include? tag_object_type } # was cleanup_matrices

    # e.g. when unify moves tags to the kept object
    after_update :move_in_matrices, if: -> {
      saved_change_to_tag_object_id? || saved_change_to_tag_object_type?
    }

  end

  # MatrixColumn/RowItem interface 
  #  
  # _change methods use the array to see how the record was updated
  # new -> [nil, 1]
  # change -> [1, 2]
  #  
  def in_scope_observation_matrix_row_items
    return [] unless keyword_id_changed?
    ObservationMatrixRowItem::Dynamic::Tag.where(observation_object_type: 'ControlledVocabularyTerm', observation_object_id:  keyword_id_change.last)
  end

  def out_of_scope_observation_matrix_row_items
    return [] unless keyword_id_changed? && keyword_id_change.first
    ObservationMatrixRowItem::Dynamic::Tag.where(observation_object_type: 'ControlledVocabularyTerm', observation_object_id:  keyword_id_change.first)
  end

  def in_scope_observation_matrix_column_items
    return [] unless keyword_id_changed?
    ObservationMatrixColumnItem::Dynamic::Tag.where(controlled_vocabulary_term_id: keyword_id_change.last)
  end

  def out_of_scope_observation_matrix_column_items
    return [] unless keyword_id_changed? && keyword_id_change.first
    ObservationMatrixColumnItem::Dynamic::Tag.where(controlled_vocabulary_term_id: keyword_id_change.first)
  end

  protected

  def purge_from_matrices
    case tag_object_type 
    when 'Descriptor'
      ObservationMatrixColumnItem::Dynamic::Tag.where(controlled_vocabulary_term_id: keyword_id).each do |mci|
        mci.cleanup_single_matrix_column(tag_object_id) # a descriptor_id
      end
    when 'Otu', 'CollectionObject', 'Extract'
      ObservationMatrixRowItem::Dynamic::Tag.where(observation_object_type: 'ControlledVocabularyTerm', observation_object_id:  keyword_id).each do |mri|
        mri.cleanup_single_matrix_row(tag_object)
      end
    else
      true
    end 
  end

  # Decrement the previous tag_object's dynamic row/column, increment the new
  # tag_object's.
  def move_in_matrices
    previous_type = tag_object_type_before_last_save
    previous_id = tag_object_id_before_last_save

    if previous_type == 'Descriptor'
      ObservationMatrixColumnItem::Dynamic::Tag.where(controlled_vocabulary_term_id: keyword_id_before_last_save).each do |mci|
        mci.cleanup_single_matrix_column(previous_id)
      end
    elsif OBSERVABLE_TYPES.include?(previous_type)
      previous_object = previous_type.constantize.find_by(id: previous_id)
      if previous_object
        ObservationMatrixRowItem::Dynamic::Tag.where(observation_object_type: 'ControlledVocabularyTerm', observation_object_id: keyword_id_before_last_save).each do |mri|
          mri.cleanup_single_matrix_row(previous_object)
        end
      end
    end

    if tag_object_type == 'Descriptor'
      ObservationMatrixColumnItem::Dynamic::Tag.where(controlled_vocabulary_term_id: keyword_id).each do |mci|
        mci.update_single_matrix_column(tag_object)
      end
    elsif OBSERVABLE_TYPES.include?(tag_object_type)
      ObservationMatrixRowItem::Dynamic::Tag.where(observation_object_type: 'ControlledVocabularyTerm', observation_object_id: keyword_id).each do |mri|
        mri.update_single_matrix_row(tag_object)
      end
    end
  end

  # This is a dynamic check.
  # For all row items that reference this keyword, increment the reference of just that object.  
  def increment_matrix_counts
    ObservationMatrixRowItem::Dynamic::Tag.where(observation_object_type: 'ControlledVocabularyTerm', observation_object_id: keyword_id).each do |mri|
      mri.update_single_matrix_row(tag_object)
    end
  end

end

