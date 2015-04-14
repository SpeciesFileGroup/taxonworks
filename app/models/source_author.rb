# Namespaced at root for convenience sake (so we don't have to reference it as Role::SourceRole::SourceAuthor)
class SourceAuthor < Role::SourceRole
  include Housekeeping::Users

  def self.human_name
    'Author'
  end

end
