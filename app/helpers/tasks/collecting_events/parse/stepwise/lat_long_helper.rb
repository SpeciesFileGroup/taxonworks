module Tasks::CollectingEvents::Parse::Stepwise::LatLongHelper

  # @param [Scope] collecting_events, usually the first five
  # @return [String] for collecting event, or failure text
  def show_ce_vl(collecting_events)
    # display_string = ''
    if collecting_events.empty?
      display_string = 'No collecting event available.'
    else
      display_string = "#{collecting_events.first.verbatim_label}"
    end
    display_string
  end

  def parse_label(label)
    retval = Utilities::Geo.hunt_wrapper(label)
    retval
  end

  def make_rows(label)
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
end
