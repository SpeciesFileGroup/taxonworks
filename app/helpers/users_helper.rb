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

end
