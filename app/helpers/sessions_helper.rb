module SessionsHelper

  def sessions_signed_in?
    !sessions_current_user.nil?
  end

  def sessions_current_user=(user)
    @sessions_current_user = user
  end

  def sessions_current_user
    remember_token = User.encrypt(cookies[:remember_token])
    @sessions_current_user ||= User.find_by(remember_token: remember_token)
  end

  def sessions_sign_in(user)
    remember_token = User.secure_random_token
    cookies.permanent[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.encrypt(remember_token))
    self.sessions_current_user = user
  end

  def sessions_sign_out
    self.sessions_current_user = nil
    cookies.delete(:remember_token)
  end

end
