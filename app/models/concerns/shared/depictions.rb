module Shared::Depictions

  extend ActiveSupport::Concern

  included do
    has_many :depictions, as: :depiction_object 
  end

  def has_depictions?
    self.depiction.size > 0
  end

end
