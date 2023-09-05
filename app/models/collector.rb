class Collector < Role::ProjectRole

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
