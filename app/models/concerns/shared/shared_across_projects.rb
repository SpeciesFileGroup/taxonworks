# All models that are referenced across projects include this code
#
module Shared::SharedAcrossProjects
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
  end

  def can_destroy?(user)
    !self.is_in_use? && ( user.is_administrator? || self.creator == user )
  end

end
