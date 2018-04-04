module ObservationMatrixRowItemsHelper
  def observation_matrix_row_item_tag(observation_matrix_row_item)
    return nil if observation_matrix_row_item.nil?
    [
      observation_matrix_tag(observation_matrix_row_item.observation_matrix),
      object_tag(observation_matrix_row_item.matrix_row_item_object)
    ].compact.join(': ')
  end

  def observation_matrix_row_item_link(observation_matrix_row_item)
    return nil if observation_matrix_row_item.nil?
    link_to(observation_matrix_row_item_tag(observation_matrix_row_item).html_safe, observation_matrix_row_item)
  end

end
