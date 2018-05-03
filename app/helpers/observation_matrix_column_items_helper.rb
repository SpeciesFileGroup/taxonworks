module ObservationMatrixColumnItemsHelper

  # TODO: write a meaningful name generator, requires
  # subclass instance methods(?) or subclass helper methods
  def observation_matrix_column_item_tag(observation_matrix_column_item)
    return nil if observation_matrix_column_item.nil?
    if observation_matrix_column_item.is_dynamic?
      (controlled_vocabulary_term_tag(observation_matrix_column_item.controlled_vocabulary_term) + ' (tag keyword)').html_safe
    else
      (descriptor_tag(observation_matrix_column_item.descriptor) + ' (single descriptor)').html_safe
    end
  end

end
