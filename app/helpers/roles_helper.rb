module RolesHelper

  def roles_names(roles)
    people_names(roles.collect{|p| p.person}) 
  end

end
