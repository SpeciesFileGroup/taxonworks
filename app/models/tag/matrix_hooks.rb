module Tag::MatrixHooks
  extend ActiveSupport::Concern

  included do
  
    after_create do
      if %w{Descriptor Otu CollectionObject}.include?(tag_object_type)
        increment_matrix_counts
      end
    end

    after_destroy :purge_from_matrices, if: -> { %w{Descriptor Otu CollectionObject}.include? tag_object_type } # was cleanup_matrices

  end

  # MatrixColumn/RowItem interface 
  #  
  # _change methods use the array to see how the record was updated
  # new -> [nil, 1]
  # change -> [1, 2]
  #  
  def in_scope_observation_matrix_row_items
    return [] unless keyword_id_changed?
    ObservationMatrixRowItem::Dynamic::Tag.where(controlled_vocabulary_term_id: keyword_id_change.last)
  end

  def out_of_scope_observation_matrix_row_items
    return [] unless keyword_id_changed? && keyword_id_change.first
    ObservationMatrixRowItem::Dynamic::Tag.where(controlled_vocabulary_term_id: keyword_id_change.first)
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
    when 'Otu', 'CollectionObject'
      ObservationMatrixRowItem::Dynamic::Tag.where(controlled_vocabulary_term_id: keyword_id).each do |mri|
        mri.cleanup_single_matrix_row(tag_object)
      end
    else
      true
    end 
  end

  # This is a dynamic check. 
  # For all row items that reference this keyword, increment the reference of just that object.  
  def increment_matrix_counts
    ObservationMatrixRowItem::Dynamic::Tag.where(controlled_vocabulary_term_id: keyword_id).each do |mri|
      mri.update_single_matrix_row(tag_object)
    end
  end

end

