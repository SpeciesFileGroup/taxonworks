module Shared::Depictions

  extend ActiveSupport::Concern

  included do
    has_many :depiction, as: :role_object, dependent: :destroy
    # should this be :depictions?
  end

  def has_depictions?
    self.depiction.size > 0
  end

end
