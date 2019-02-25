class AttributionCopyrightHolder < Role::AttributionRole

  include Roles::Organization

  def self.human_name
    'Copyright holder'
  end

end
