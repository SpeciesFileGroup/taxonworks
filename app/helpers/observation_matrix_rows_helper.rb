module ObservationMatrixRowsHelper

  def observation_matrix_row_tag(observation_matrix_row)
    return nil if observation_matrix_row.nil?
    get_observation_matrix_row_name(observation_matrix_row)
  end

  def observation_matrix_row_link(observation_matrix_row)
    return nil if observation_matrix_row.nil?
    link_to(observation_matrix_row_tag(observation_matrix_row).html_safe, observation_matrix_row)
  end

  def get_observation_matrix_row_name(observation_matrix_row)
    object_tag(observation_matrix_row.row_object)
  end
end
