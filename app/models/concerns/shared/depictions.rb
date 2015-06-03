module Shared::Depictions

  extend ActiveSupport::Concern

  included do
    has_many :depictions, as: :depiction_object, dependent: :destroy
    # should this be :depictions?
  end

  def has_depictions?
    self.depictions.size > 0
  end

end
