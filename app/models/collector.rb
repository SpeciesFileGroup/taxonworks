class Collector < Role::ProjectRole

  include Shared::DwcOccurrenceHooks

  def dwc_occurrences
    DwcOccurrence
      .joins("JOIN collection_objects co on dwc_occurrence_object_id = co.id AND dwc_occurrence_object_type = 'CollectionObject'")
      .joins('JOIN collecting_events ce on co.collecting_event_id = ce.id')
      .joins("JOIN roles r on r.type = 'Collector' AND r.role_object_type = 'CollectingEvent' AND r.role_object_id = ce.id")
      .where(r: {id:})
      .distinct
  end

  def do_not_set_cached
    true
  end

  # Collectors should not trigger spatial updates
  # def cached_triggers
  #   return { }  #  { CollectingEvent: [:set_cached_cached ] } # does not yet reference Collecotrs
  # end

  def self.human_name
    'Collector'
  end

  def year_active_year
    [ role_object.end_date_year,
      role_object.start_date_year
    ].compact.first
  end

end
