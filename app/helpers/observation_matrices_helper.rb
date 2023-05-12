module ObservationMatricesHelper
  LABEL_REPLACEMENT = {
    '10' => 'A',
    '11' => 'B',
    '12' => 'C',
    '13' => 'D',
    '14' => 'E',
    '15' => 'F',
    '16' => 'G',
    '17' => 'H',
    '18' => 'I',
    '19' => 'J',
    '20' => 'K',
    '21' => 'L',
    '22' => 'M',
    '23' => 'N',
    '24' => 'O',
    '25' => 'P',
    '26' => 'R',
    '27' => 'S',
    '28' => 'T',
    '29' => 'U',
    '30' => 'V',
    '31' => 'W',
    '32' => 'X',
    '33' => 'Y',
    '34' => 'Z',
  }

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

  # TODO: This is only used in TNT exports, expand
  # to allow for other export formats
  def max_row_name_width(observation_matrix)
    max = 0

    observation_matrix.observation_matrix_rows.load.each do |r|
      s = observation_matrix_row_label_tnt(r).length
      max = s if max < s
    end
    max + 1
  end

  # @return [String]
  #   the fully formatted cell, handles polymorphisms
  #   show states in tnt or nexus format for a 'cell' (e.g. [ab])
  #   Mx.print_codings in mx
  def observations_cell_label(observations_hash, descriptor, hash_index, style = :tnt)

    case observations_hash[descriptor.id][hash_index].size
    when 0
      "?"
    when 1
      o = observations_hash[descriptor.id][hash_index][0]
      s = observation_export_value(o)
      s = LABEL_REPLACEMENT[s].nil? ? s : LABEL_REPLACEMENT[s]

      if s.length > 1 && (style == :nexus && style == :tnt) && o.type == 'Observation::Qualitative'
        "#{s} [WARNING STATE '#{s}' is TOO LARGE FOR PAUP (0-9, A-Z only).]"
      else
        s
      end
    else
      str = observations_hash[descriptor.id][hash_index].collect{|o| observation_export_value(o) }.sort

      case style
      when :csv
        str.join('|')
      when :nexus
        "{#{str.join("")}}"
      else
        "[#{str.join("")}]"
      end
    end
  end

  # @return [String]
  #   the value shown in the cell
  def observation_export_value(observation)
    case observation.type
    when 'Observation::Qualitative'
      LABEL_REPLACEMENT[observation.character_state.label].nil? ? observation.character_state.label : LABEL_REPLACEMENT[observation.character_state.label]
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
    when 'Observation::Sample'
      if observation.sample_max && observation.sample_max && observation.sample_max.to_f != observation.sample_min.to_f
        ("%g" % observation.sample_min).to_s + '-' + ("%g" % observation.sample_max).to_s
      elsif observation.sample_min
        ("%g" % observation.sample_min).to_s
      else
        '?'
      end
    else
      '-' # ? not sure
    end
  end

  def descriptor_list(observation_matrix)
    rows = []
    observation_matrix.descriptors.each do |d|
      l = d.name + ': '
      if d.qualitative?
        l << d.character_states.order(:position).collect{|cs| "#{cs.label}: " + cs.name }.join('; ')
      elsif d.presence_absence?
        l << '0: absent; 1: present'
      end
      rows.push l
    end
    rows.join("\n")
  end

end
