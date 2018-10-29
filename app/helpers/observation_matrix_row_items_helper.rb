module ObservationMatrixRowItemsHelper

  # !! when dynamic rows are extended this will have to reflect other types than tags 
  def observation_matrix_row_item_tag(observation_matrix_row_item)
    return nil if observation_matrix_row_item.nil?
    if observation_matrix_row_item.is_dynamic?
      (controlled_vocabulary_term_tag(observation_matrix_row_item.controlled_vocabulary_term) + ' (tag keyword)').html_safe
    else
      [
        object_tag(observation_matrix_row_item.matrix_row_item_object),
        "(single #{observation_matrix_row_item.matrix_row_item_object.class})"
      ].compact.join(' ').html_safe
    end 
  end

  def observation_matrix_row_item_link(observation_matrix_row_item)
    return nil if observation_matrix_row_item.nil?
    link_to(observation_matrix_row_item_tag(observation_matrix_row_item).html_safe, observation_matrix_row_item.metamorphosize)
  end

end


