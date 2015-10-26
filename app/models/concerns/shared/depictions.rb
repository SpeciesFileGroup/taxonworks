# Shared code for...
#
module Shared::Depictions

  extend ActiveSupport::Concern

  included do
    has_many :depictions, validate: true, as: :depiction_object, dependent: :destroy, inverse_of: :depiction_object
    has_many :images, validate: true, through: :depictions

    accepts_nested_attributes_for :depictions, allow_destroy: true, reject_if: :reject_depictions
    accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :reject_images 
  end

  def has_depictions?
    self.depictions.size > 0
  end

  protected

  # Not tested!
  def reject_depictions(attributed)
    attributed['image_attributes'].blank? ||  attributed['image_attributes']['image_file'].blank?
  end

  def reject_images(attributed)
    attributed['image_file'].blank? 
  end

end
