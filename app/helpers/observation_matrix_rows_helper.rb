module ObservationMatrixRowsHelper

  # Display in app
  def observation_matrix_row_tag(observation_matrix_row)
    return nil if observation_matrix_row.nil?
    object_tag(observation_matrix_row.observation_object)
  end

  def observation_matrix_row_link(observation_matrix_row)
    return nil if observation_matrix_row.nil?
    link_to(observation_matrix_row_tag(observation_matrix_row).html_safe, observation_matrix_row)
  end

  # @return [String]
  #    The label used in for general purpose internal use
  def label_for_observation_matrix_row(observation_matrix_row)
    return observation_matrix_row.name if observation_matrix_row.name.present?
    label_for(observation_matrix_row.observation_object)
  end

  def observation_matrix_row_label_tnt(observation_matrix_row)
    # TODO: this return is not guarunteed to be legal TNT
    return observation_matrix_row.name if observation_matrix_row.name.present?
    o = observation_matrix_row.observation_object
    s = label_for(o)
    s.gsub!(/[^\w]/, '_')
    s.gsub!(/_+/, '_')
    s = '_' if s.blank?
    s + "_#{o.id}" # Code must return labels that will execute without error, ensure they are unique.
  end

  def observation_matrix_row_label_nexus(observation_matrix_row)
    # TODO: this return is not guarunteed to be legal nexus
    return observation_matrix_row.name if observation_matrix_row.name.present?
    o = observation_matrix_row.observation_object
    s = label_for(o)
    s.gsub!(/[^\w]/, '_').to_s
    s = '_' if s.blank?
    s.gsub!(/_+/, '_')
  end

  def observation_matrix_row_label_nexml(observation_matrix_row)
    return observation_matrix_row.name if observation_matrix_row.name.present?
    o = observation_matrix_row.observation_object
    label_for(o)
  end

  # @return [String, nil]
  #   the object_label with any commas replaced by pipes
  def observation_matrix_row_label_csv(observation_matrix_row)
    return observation_matrix_row.name if observation_matrix_row.name.present?
    o = observation_matrix_row.observation_object
    ('"' + label_for(o).gsub('"', "'") + '"').html_safe
  end

  # ONLY CACHE IF count == 1 ?!
  # @return [ObservationMatrixRow#id, nil]
  #   if destroyable (represented by only a single OMRI of type Single) then return the ID
  def observation_matrix_row_destroyable?(observation_matrix_row)
    if observation_matrix_row.cached_observation_matrix_row_item_id.present? && observation_matrix_row.reference_count == 1
      return observation_matrix_row.cached_observation_matrix_row_item_id
    end
  end

end
