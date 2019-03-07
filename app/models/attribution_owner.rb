class AttributionOwner < Role::AttributionRole

  include Roles::Organization

  def self.human_name
    'Owner'
  end

end
