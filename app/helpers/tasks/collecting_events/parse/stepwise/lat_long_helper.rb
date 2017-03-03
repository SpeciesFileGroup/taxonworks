module Tasks::CollectingEvents::Parse::Stepwise::LatLongHelper

  def parse_label(label)
    retval = Utilities::Geo.hunt_wrapper(label)
    retval
  end

  def make_rows(label)
    return nil if label.nil?
    tests = Utilities::Geo.hunt_wrapper(label)
    tests.keys.collect.with_index do |kee, dex|
      trial  = tests[kee]
      method = trial.delete(:method)
      # next if trial.blank?
      content_tag(:tr, class: :extract_row) do
        content_tag(:td, method) +
          content_tag(:td, kee) +
          content_tag(:td, trial[:lat], class: :latitude_value) +
          content_tag(:td, trial[:long], class: :longitude_value) +
          content_tag(:td, radio_button_tag('select', dex, false, class: :select_lat_long))
      end
    end.join.html_safe
  end

  def test_lat
    ''
  end

  def test_long
    ''
  end

  def parse_lat_long_skip_link(current_collecting_event_id)
    # TODO: Now this has to be bound to next hit
    next_id = Queries::CollectingEventLatLongExtractorQuery.new(
      collecting_event_id: current_collecting_event_id,
      filters: [:dd, :d_dm]).all.with_project_id(sessions_current_project_id).first.try(:id)
    if next_id
      link_to('Skip to next record', collecting_event_lat_long_task_path(collecting_event_id: next_id))
    else
      content_tag(:span, 'no more matches')
    end
  end

end
