module ObservationsHelper
  include RecordNavigationHelper

  def observation_tag(observation)
    return nil if observation.nil?
    a = descriptor_tag(observation.descriptor)
    b = observation_cell(observation, 'tag', true)
    c = send(
      "#{observation.observation_object_type.underscore}_tag",
      observation.observation_object
    )

    "#{a}: #{b} on #{c}".html_safe
  end

  def observation_autocomplete_tag(observation, on: nil)
    t = observation_tag(observation)
    if on == 'Otu'
      [t, 'on:', otu_tag(observation.observation_object)].join(' ').html_safe
    else
      t
    end
  end

  def label_for_observation(observation)
    return nil if observation.nil?
    a = observation.descriptor.name
    b = observation_cell(observation, 'label', true)
    c = send(
      "label_for_#{observation.observation_object_type.underscore}",
      observation.observation_object
    )

    if b.empty?
      "#{a} on #{c}".html_safe
    else
      "#{a}: #{b} on #{c}".html_safe
    end
  end

  def observation_type_label(observation)
    observation.type.split('::').last
  end

  # Joins multiple observations to concat for cells
  def observation_matrix_cell_tag(observation_object, descriptor)
    q = Observation.object_scope(observation_object).where(descriptor: descriptor)
    q.collect{|o| observation_cell(o, 'tag')}.sort.join(' ').html_safe
  end

  def observation_cell(observation, label_or_tag = 'tag', verbose = false)
    case observation.type
    when 'Observation::Qualitative'
      qualitative_observation_cell_label(observation, verbose)
    when 'Observation::Continuous'
      continuous_observation_cell_label(observation)
    when 'Observation::Sample'
      if label_or_tag == 'tag'
        sample_observation_cell_tag(observation)
      else
        # TODO
        ''
      end
    when 'Observation::PresenceAbsence'
      if label_or_tag == 'tag'
        presence_absence_observation_cell_tag(observation)
      else
        presence_absence_observation_cell_label(observation)
      end
    when 'Observation::Working' # TODO: Validate in format
      if label_or_tag == 'tag'
        tag.span('X', title: observation.description)
      else
        # TODO
        ''
      end
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

  def qualitative_observation_cell_label(observation, verbose = false)
    if verbose
      observation.character_state.label + ': ' + observation.character_state.name
    else
      observation.character_state.label
    end
  end

  def continuous_observation_cell_label(observation)
    [observation.continuous_value, observation.continuous_unit].compact.join(' ')
  end

  def presence_absence_observation_cell_tag(observation)
    # TODO: messing with visualization here, do something more clean
    observation.presence ? '&#10003;' : '&#x274c;'
  end

  def presence_absence_observation_cell_label(observation)
    observation.presence ? 'present' : 'absent'
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

  # @return !!Array!!
  def previous_records(observation)
    # !! Note we only return observations on Otus currently.
    o = ::Observation
      .joins("JOIN otus ON observations.observation_object_type = 'Otu' AND observations.observation_object_id = otus.id")
      .where(project_id: observation.project_id)
      .where('observations.id < ?', observation.id)
      .order(id: :desc)
      .first

    [o].compact
  end

  # @return !!Array!!
  def next_records(observation)
    # !! Note we only return observations on Otus currently.
    o = ::Observation
      .joins("JOIN otus ON observations.observation_object_type = 'Otu' AND observations.observation_object_id = otus.id")
      .where(project_id: observation.project_id)
      .where('observations.id > ?', observation.id)
      .order(:id)
      .first

    [o].compact
  end
end
