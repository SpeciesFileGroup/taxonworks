class Collector < Role::ProjectRole

  def self.human_name
    'Collector'
  end

  def year_active_year
    [ role_object.end_date_year,
      role_object.start_date_year
    ].compact.first
  end

end
