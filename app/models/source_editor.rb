class SourceEditor < Role::SourceRole
  include Housekeeping::Users

  def self.human_name
    'Editor'
  end

end
