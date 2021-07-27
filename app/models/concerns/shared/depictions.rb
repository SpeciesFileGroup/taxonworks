# Shared code for extending data-classes with Depictions.
#
module Shared::Depictions

  extend ActiveSupport::Concern

  included do
    ::Depiction.related_foreign_keys.push self.name.foreign_key

    # Add a corresponding has_many in Image
    Image.has_many self.name.tableize.to_sym, through: :depictions, source: :depiction_object, source_type: self.name

    has_many :depictions, validate: true, as: :depiction_object, dependent: :destroy, inverse_of: :depiction_object
    has_many :images, validate: true, through: :depictions

    accepts_nested_attributes_for :depictions, allow_destroy: true, reject_if: :reject_depictions
    accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :reject_images 
  end

  def has_depictions?
    self.depictions.size > 0
  end

  def image_array=(images)
    self.depictions_attributes = images.collect{|i, file| { image_attributes: {image_file: file}}}
  end

  protected

  def reject_depictions(attributed)
    attributed['image_id'].blank? && !attributed['images_attributes'].nil?
  end

  def reject_images(attributed)
    attributed['image_file'].blank?
  end

end
