module CollectingEventsHelper
  def collecting_event_tag(collecting_event)
    collecting_event.cached.blank? ? 'CACHED VALUE NOT BUILT - CONTACT ADMIN' : collecting_event.cached
  end
end
