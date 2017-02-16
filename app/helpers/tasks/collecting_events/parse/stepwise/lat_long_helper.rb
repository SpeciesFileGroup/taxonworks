module Tasks::CollectingEvents::Parse::Stepwise::LatLongHelper

  # @param [Object] collecting_event
  # @return [String] for collecting event, or failure text
  def show_ce_vl(collecting_event)
    if collecting_event.blank?
      'No collecting event available.'
    else
      collecting_event.verbatim_label
    end
    end

  # TODO: How we figure out which one is next is still outstanding
  # @return [Integer] as a string
  def set_next
    0.to_s
  end
end
