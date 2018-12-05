module ObservationsHelper

  def observation_tag(observation)
    return nil if observation.nil?
    "#{observation.descriptor.name}: #{observation.id}"
  end

  def observation_matrix_cell_tag(row_object, descriptor)
    q = Observation.object_scope(row_object).where(descriptor: descriptor)
    q.collect{|o| observation_cell_tag(o)}.sort.join(' ').html_safe
  end

  def observation_cell_tag(observation)
    case observation.type
    when 'Observation::Qualitative'
      qualitative_observation_cell_tag(observation)
    when 'Observation::Continuous'
      continuous_observation_cell_tag(observation)
    when 'Observation::Sample'
      sample_observation_cell_tag(observation)
    when 'Observation::PresenceAbsence'
      presence_absence_observation_cell_tag(observation)
    else 
      '!! display not done !!'
    end
  end

  def qualitative_observation_cell_tag(observation)
    observation.character_state.label
  end

  def continuous_observation_cell_tag(observation)
    [observation.continuous_value, observation.continuous_unit].compact.join(' ')
  end

  def presence_absence_observation_cell_tag(observation)
    # TODO: messing with visualization here, do something more clean
    observation.presence ? '&#10003;' : '&#x274c;' 
  end

  def sample_observation_cell_tag(observation)
    r = []
    # TODO: rangify
    r.push "min: #{observation.sample_min}" if observation.sample_min.present?
    r.push "max: #{observation.sample_max}" if observation.sample_max.present?
    r.push " #{observation.sample_units}" if observation.sample_units.present?
    r.push "max: #{observation.sample_median}" if observation.sample_median.present?
    r.push " &#956; #{observation.sample_mean}" if observation.sample_mean.present?
    r.push " &#963; #{observation.sample_standard_deviation}" if observation.sample_standard_deviation.present?
    r.push " STD ERR: #{observation.sample_standard_error}" if observation.sample_standard_error.present?
    r.push " (n: #{observation.sample_n})" if observation.sample_n.present?

    r.compact.join(', ').html_safe
  end




end
