class SourceEditor < Role::SourceRole

  def self.human_name
    'Editor'
  end

  def year_active_year
    y = role_object.year
    y ||= role_object.year_of_publication
    y
  end

end
