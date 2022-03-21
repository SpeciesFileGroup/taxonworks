module ObservationsHelper

  def observation_tag(observation)
    return nil if observation.nil?
    "#{observation.descriptor.name}: #{observation.id}"
  end

  def label_for_observation(observation)
    return nil if observation.nil?
    observation.descriptor.name # TODO: add values
  end

  def observation_matrix_cell_tag(observation_object, descriptor)
    q = Observation.object_scope(observation_object).where(descriptor: descriptor)
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

    when 'Observation::Working' # TODO: Validate in format
      tag.span('X', title: observation.description)
    else
      '!! display not done !!'
    end
  end

  def observation_made_on_tag(observation)
    return nil if observation.nil?

    [observation.year_made,
     observation.month_made,
     observation.day_made,
     observation.time_made ].compact.join('-')
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
    o = observation
    r = []

    r.push [o.sample_min, o.sample_max].compact.join('-')
    r.push "#{o.sample_units}" if o.sample_units.present?

    m = []

    m.push "median = #{o.sample_median}" if o.sample_median.present?
    m.push "&#956; = #{o.sample_mean}" if o.sample_mean.present?
    m.push ["s = #{o.sample_standard_error}", (o.sample_units.present? ? " #{o.sample_units}" : nil)].compact.join if o.sample_standard_error.present?
    m.push "n = #{o.sample_n}" if o.sample_n.present?
    m.push "&#963; = #{o.sample_standard_deviation}" if o.sample_standard_deviation.present?

    r.push '(' + m.join(', ') + ')' if m.any?

    r.compact.join(' ').html_safe
  end

end
