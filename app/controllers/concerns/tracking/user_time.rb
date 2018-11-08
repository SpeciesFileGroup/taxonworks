module Tracking::UserTime
  extend ActiveSupport::Concern

  included do
    before_action :notice_user
  end

  protected

  private

  def notice_user
    if sessions_current_user
      sessions_current_user.update_last_seen_at
    end
  end

end
