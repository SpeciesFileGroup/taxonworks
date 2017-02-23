module Tasks::CollectingEvents::Parse::Stepwise::LatLongHelper

  # @param [Scope] collecting_events, usually the first five
  # @return [String] for collecting event, or failure text
  def show_ce_vl(collecting_events)
    if collecting_events.empty?
      '<h3>No collecting event available.</h3>'
    else
      "<h3>#{collecting_events.first.verbatim_label}</h3>"
    end
  end

  def parse_label(label)
    retval = Utilities::Geo.hunt_wrapper(label)
    retval
  end

  def make_rows(label)
    tests  = Utilities::Geo.hunt_wrapper(label)
    retval = ''
    tests.keys.each { |kee|
      trial = tests[kee]
      next if tests.empty?
      retval = '<tr>'
      retval += "<td>#{kee}</td>"
      retval += "<td>#{Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees(trial[:lat])}</td>"
      retval += "<td>#{Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees(trial[:long])}</td>"
      retval += "<td>#{radio_button_tag('select', 0, false)}</td>"
      retval += '</tr>'
    }
    retval
  end

  def test_lat
    '123.456'
  end

  def test_long
    '456.123'
  end
end
