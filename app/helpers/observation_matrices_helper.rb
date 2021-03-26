module ObservationMatricesHelper

  def observation_matrix_tag(observation_matrix)
    return nil if observation_matrix.nil?
    observation_matrix.name
  end

  def observation_matrix_label(observation_matrix)
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

  def keywords_on_addable_row_items
    Keyword.joins(:tags).where(project_id: sessions_current_project_id).where(tags: {tag_object_type: ['Otu', 'CollectionObject']}).distinct.all
  end

  def keywords_on_addable_column_items
    Keyword.joins(:tags).where(project_id: sessions_current_project_id).where(tags: {tag_object_type: 'Descriptor'}).distinct.all
  end

  # Matrix export helpers

  def max_row_name_width(observation_matrix)
    max = 0

    observation_matrix.observation_matrix_rows.load.each do |r|
      s = observation_matrix_row_label_nexus(r).length
      max = s if max < s
    end
    max + 1
  end

  # @return [String]
  #   the fully formatted cell, handles polymorphisms
  #   show states in tnt or nexus format for a 'cell' (e.g. [ab]) 
  #   Mx.print_codings in mx
  def observations_cell_label(observations_hash, descriptor, row_object_global_id, style = :tnt)
    case observations_hash[descriptor.id][row_object_global_id].size
    when 0
      "?"
    when 1
      o = observations_hash[descriptor.id][row_object_global_id][0] 
      s = observation_export_value(o)

      if s.length > 1 && style == :nexus && o.type == 'Observation::Qualitative'
        "#{s} [WARNING STATE '#{s}' is TOO LARGE FOR PAUP (0-9, A-Z only).]"
      else
        s
      end
    else
      str = observations_hash[descriptor.id][row_object_global_id].collect{|o| observation_export_value(o) }.sort.join("")
      case style
      when :nexus
        "{#{str}}"
      else
        "[#{str}]"
      end
    end
  end

  # @return [String]
  #   the value shown in the cell
  def observation_export_value(observation)
    case observation.type
    when 'Observation::Qualitative'
      observation.character_state.label
    when 'Observation::PresenceAbsence' 
      case observation.presence
      when true
        '1'
      when false
        '0'
      when nil
        '?'
      else
        'INTERNAL ERROR'
      end
    when 'Observation::Continuous'
      observation.converted_value.to_s
    else
      '-' # ? not sure 
    end
  end

end
