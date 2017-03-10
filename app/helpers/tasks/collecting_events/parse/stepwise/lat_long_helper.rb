module Tasks::CollectingEvents::Parse::Stepwise::LatLongHelper

  def parse_label(label)
    retval = Utilities::Geo.hunt_wrapper(label)
    retval
  end

  def make_method_headers
    list         = Utilities::Geo::REGEXP_COORD
    selector_row = ""
    list.keys.each { |kee|
      selector_row += content_tag(:th, kee.to_s.upcase)
    }
    selector_row.html_safe
  end


  # @param [Array] must be array of symbols from Utilities::Geo::REGEXP_COORD
  def make_selected_method_boxes(filters = Utilities::Geo::REGEXP_COORD.keys)
    list    = Utilities::Geo::REGEXP_COORD
    box_row = ""
    list.keys.each { |kee|
      checked = filters.include?(kee)
      box_row += content_tag(:td, check_box_tag("filters[]", kee.to_s, checked))
    }
    box_row.html_safe
  end

  def make_rows(label)
    return nil if label.nil?
    tests = Utilities::Geo.hunt_wrapper(label)
    tests.keys.collect.with_index do |kee, dex|
      trial  = tests[kee]
      method = trial.delete(:method)
      next if trial.blank?
      content_tag(:tr, class: :extract_row) do
        content_tag(:td, method) +
          # content_tag(:td, kee == method ? '' : kee) +
          content_tag(:td, trial[:piece]) +
          content_tag(:td, trial[:lat], class: :latitude_value) +
          content_tag(:td, trial[:long], class: :longitude_value) +
          content_tag(:td, radio_button_tag('select', dex, false, class: :select_lat_long))
      end
    end.join.html_safe
  end

  def test_lat
    @collecting_event.verbatim_latitude unless @collecting_event.nil?
  end

  def test_long
    @collecting_event.verbatim_longitude unless @collecting_event.nil?
  end

  def parse_lat_long_skip(current_collecting_event_id, filters)
    # TODO: Now this has to be bound to next hit
    # filters = Utilities::Geo::REGEXP_COORD.keys
    next_id = Queries::CollectingEventLatLongExtractorQuery.new(
      collecting_event_id: current_collecting_event_id,
      filters:             filters).all.with_project_id(sessions_current_project_id).first.try(:id)
    if next_id
      button_tag('Skip to next record', value: 'skip')
      # link_to('Skip to next record', collecting_event_lat_long_task_path(collecting_event_id: next_id))
    else
      content_tag(:span, 'no more matches')
    end
  end

  def scan_c_e
    pile = Queries::CollectingEventLatLongExtractorQuery.new(
      collecting_event_id: 0,
      filters:             DEFAULT_SQL_REGEXS).all.with_project_id(sessions_current_project_id).order(:id)
    pile.each { |c_e|
      trials = Utilities::Geo.hunt_lat_long_full(c_e.verbatim_label)
      puts(c_e.id)
    }
    pile
  end

end
