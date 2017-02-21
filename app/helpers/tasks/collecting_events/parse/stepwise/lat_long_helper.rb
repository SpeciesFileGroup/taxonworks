module Tasks::CollectingEvents::Parse::Stepwise::LatLongHelper

  # @param [Scope] collecting_events, usually the first five
  # @return [String] for collecting event, or failure text
  def show_ce_vl(collecting_events)
    if collecting_events.empty?
      'No collecting event available.'
    else
      collecting_events.first.verbatim_label
    end
    end

  # TODO: How we figure out which one is next is still outstanding
  # @return [Integer] as a string
  def set_next
    0.to_s
  end
end
