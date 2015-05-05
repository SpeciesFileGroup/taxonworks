module Shared::Depictions

  extend ActiveSupport::Concern

  included do
    has_many :depiction, as: :role_object
  end

  def has_depictions?
    self.depiction.size > 0
  end

end
