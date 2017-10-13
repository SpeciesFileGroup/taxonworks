module UsersHelper

  def user_tag(user)
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
    if !user.last_sign_in_at.blank?
      time_ago_in_words(user.last_sign_in_at) + '  ago'
    else
      content_tag(:em, 'never')
    end
  end

# @param [Symbol, String] user_element
# @param [String] default_name, if supplied, must be a user.name, user.email, or user.if
# @return [HTML]
  def user_select_tag(user_element, default_name = nil)
    # options_list = ['All users', 0]

    # options_list.push(User.in_project(sessions_current_project_id).collect { |u| User.find(u).name })
    # options_list.push(User.in_project(sessions_current_project_id).collect { |u| User.find(u).name},{value: u})

    # select_tag(user_element, options_for_select(options_list.flatten, default_name))
    select_tag(user_element,
               options_for_select(User.in_project(sessions_current_project_id)
                                    .collect { |u| [User.find(u).name, User.find(u).id] }
                                    .unshift(['All users', 'All users']),
                                  default_name))

  end
end
