module Shared::Permissions

  extend ActiveSupport::Concern


  # Returns whether it is permissible to try to destroy
  # the record based on its relationships to projects
  # the user is in.  I.e. false if it is related to data in
  # a project in which they user is not a member.
  # !! Does not look at :dependendant assertions
  # @return [Boolean]
  #   true - there is at least some related data in another projects
  # @param user [user_id or User]
  #   an id or User object
  def is_destroyable?(user)
    u = user
    u = User.find(user) if !user.kind_of?(User)
    return true if u.is_administrator?

    p = u.projects.pluck(:id)

    # TODO: !! replace with a simple wrapped transaction and roll it back

    self.class.reflect_on_all_associations(:has_many).each do |r|
      if r.klass.column_names.include?('project_id')
        # If this has any related data in another project, we can't destroy it
        #    if !send(r.name).nil?
        return false if send(r.name).where.not(project_id: p).any? # count(:all) > 0
        #     end
      end
    end

    self.class.reflect_on_all_associations(:has_one).each do |r|
      if is_community? # *this* object is community, others we don't care about
        if o = send(r.name)
          return false if o.respond_to?(:project_id) && !p.include?(o.project_id)
        end
      end
    end
    true
  end


  def is_in_users_projects?(user)
    user.projects.pluck(:id).include?(project_id)
  end

  def is_editable?(user)
    u = user
    u = User.find(user) if !user.kind_of?(User)
    return true if u.is_administrator? || is_community?
    return false if !is_in_users_projects?(u)
    true
  end

end
