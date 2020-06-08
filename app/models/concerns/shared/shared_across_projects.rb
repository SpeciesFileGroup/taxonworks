# All models that users can create recrods for that are referenced across projects include this code.  For example Sources.
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

  def can_edit?(user)
    # stub
  end

end
