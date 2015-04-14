class SourceSource < Role::SourceRole
  include Housekeeping::Users

  def self.human_name
    'Source'
  end
end
