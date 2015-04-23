module UsersHelper

  def user_tag(user)
    user.name
  end

  def user_link(user)
    if @sessions_current_user == user || @sessions_current_user.is_administrator?
      link_to(user_tag(user), user)
    else
      content_tag :span, user_tag(user), class: :subtle
    end
  end

end
