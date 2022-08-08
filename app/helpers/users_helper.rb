module UsersHelper

  def user_tag(user)
    return nil if user.nil?
    user.name
  end

  def user_link(user)
    if sessions_current_user == user || sessions_current_user.is_administrator?
      link_to(user_tag(user), user)
    else
      content_tag :span, user_tag(user), class: :subtle
    end
  end

  def user_last_seen_tag(user)
    if !user.last_seen_at.blank?
      time_ago_in_words(user.last_seen_at) + '  ago'
    else
      content_tag(:em, 'never')
    end
  end

  # @param [Symbol, String] user_element
  # @param [Array] user_id_list
  # @param [String] default_name, if supplied, must be a user.name, user.email, or user.if
  # @return [HTML]
  def user_select_tag(user_element, user_id_list, default_name = nil)
    select_tag(user_element,
               options_for_select(user_id_list
      .collect { |u| [User.find(u).name, User.find(u).id] }
      .unshift(['All users', 'All users']),
    default_name))
  end

  def project_users_select_tag(user_element, default_name = nil)
    user_id_list = User.in_project(sessions_current_project_id)
    user_select_tag(user_element, user_id_list, default_name)
  end

  def user_select_tag_2(user_element, *users)
    a = users
    select_tag(user_element, options_for_select(
      User
      .in_project(sessions_current_project_id)
      .collect { |u| [User.find(u).name, User.find(u).id] }))
  end
end
