# Shared code for...
#
module Shared::Depictions

  extend ActiveSupport::Concern

  included do
    has_many :depictions, as: :depiction_object, dependent: :destroy
    has_many :images, through: :depictions

    accepts_nested_attributes_for :depictions
  end

  def has_depictions?
    self.depictions.size > 0
  end

end
