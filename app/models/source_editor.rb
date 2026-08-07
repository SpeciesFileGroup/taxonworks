class SourceEditor < Role::SourceRole

  def self.human_name
    'Editor'
  end

  def year_active_year
    y = role_object.year
    y ||= role_object.stated_year
    y
  end

end
