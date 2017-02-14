module Tasks::CollectingEvents::Parse::LatLongHelper

  def show_ce_vl(collecting_event)
    if collecting_event.nil?
      'No collecting event available.'
    else
      collecting_event.verbatim_label
    end
  end
end
