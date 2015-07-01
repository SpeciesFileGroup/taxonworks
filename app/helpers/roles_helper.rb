module RolesHelper

  def role_tag(role)
    return nil if role.nil?
    person_tag(role.person) 
  end


end
