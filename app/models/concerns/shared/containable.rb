module Shared::Containable
  extend ActiveSupport::Concern

  included do
    has_one :container_item
    has_one :container, through: :container_item
  end 

  def contained?
    !self.container.nil?
  end

  protected
end
