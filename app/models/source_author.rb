# Namespaced at root for convenience sake (so we don't have to reference it as Role::SourceRole::SourceAuthor)
class SourceAuthor < Role::SourceRole

  def self.human_name
    'Author'
  end

  # Technically this can be wrong, when published post-humously,
  # however, our definition of "active" is not locked in stone.
  def year_active_year
    y = role_object.year
    y ||= role_object.stated_year
    y
  end

end
