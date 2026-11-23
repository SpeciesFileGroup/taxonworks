# Claude provided > 50% of the code for this class.
module ApplicationCable
  # Deny by default: only a signed in User (same remember_token cookie as
  # Workbench::SessionsHelper#sessions_current_user) may connect.
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      remember_token = cookies[:remember_token]
      user = User.find_by(remember_token: User.encrypt(remember_token)) if remember_token.present?
      user || reject_unauthorized_connection
    end
  end
end
