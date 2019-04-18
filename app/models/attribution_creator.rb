# Namespaced at root for convenience sake (so we don't have to reference it as Role::SourceRole::SourceAuthor)
class AttributionCreator < Role::AttributionRole

  def self.human_name
    'Creator'
  end

end
