module ObservationMatricesHelper

  def observation_matrix_tag(observation_matrix)
    return nil if observation_matrix.nil?
    observation_matrix.name
  end

  def observation_matrices_search_form
    render('/observation_matrices/quick_search_form')
  end

  def observation_matrix_link(observation_matrix)
    return nil if observation_matrix.nil?
    link_to(observation_matrix_tag(observation_matrix).html_safe, observation_matrix)
  end

end
