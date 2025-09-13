
# Shared code for extending data-classes with Conveyances (sounds).
#
# TODO: Copy/pasta from Depictions. confirm
module Shared::Conveyances

  extend ActiveSupport::Concern

  included do
    ::Conveyance.related_foreign_keys.push self.name.foreign_key

    # Add a corresponding has_many in Sound
    Sound.has_many self.name.tableize.to_sym, through: :conveyances, source: :conveyance_object, source_type: self.name

    has_many :conveyances, as: :conveyance_object, dependent: :destroy, inverse_of: :conveyance_object, validate: true
    has_many :sounds, through: :conveyances, validate: true

    accepts_nested_attributes_for :conveyances, allow_destroy: true, reject_if: :reject_conveyances
    accepts_nested_attributes_for :sounds, allow_destroy: true, reject_if: :reject_sounds
  end

  def has_conveyances?
    self.conveyances.size > 0
  end

  def sound_array=(sounds)
    self.conveyances_attributes = sounds.collect{|i, file| { sound_attributes: {sound_file: file}}}
  end

  protected

  def reject_conveyances(attributed)
    attributed['sound_id'].blank? && !attributed['sounds_attributes'].nil?
  end

  def reject_sounds(attributed)
    attributed['sound_file'].blank?
  end

end
