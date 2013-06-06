module Shared::Containable
  extend ActiveSupport::Concern

  included do
    acts_as_nested_set
  end

  def contained?
    !self.root?
  end

  protected

end
