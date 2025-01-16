class Sound < ApplicationRecord
  include Housekeeping

  # TODO: add
  include Shared::MatrixHooks::Member

  include Shared::OriginRelationship
  include Shared::Observations
  include Shared::Confidences
  include Shared::Citations
  include Shared::Attributions
  include Shared::DataAttributes
  include Shared::Identifiers
  include Shared::Notes
  include Shared::Tags
  include Shared::IsData 

  # See canonical list at
  ALLOWED_CONTENT_TYPES = %w{
    audio/wma 
    audio/aac
    audio/aiff
    audio/flac
    audio/mp4
    audio/mp3
    audio/ogg
    audio/wav
    audio/x-wav
    audio/x-ms-wma
    audio/x-aiff
    audio/mpeg
  }

  originates_from 'Specimen', 'Lot', 'RangedLot', 'Otu', 'CollectionObject', 'FieldOccurrence', 'CollectingEvent'

  has_one_attached :sound_file
  has_many :conveyances, inverse_of: :sound, dependent: :restrict_with_error

  after_destroy :purge_sound_file

  validate :file_type

  accepts_nested_attributes_for :conveyances, allow_destroy: false

  private

  def file_type
    if !ALLOWED_CONTENT_TYPES.include?(sound_file.content_type)
      errors.add(:sound_file, "#{sound_file.content_type} is not allowed") 
    end
  end

  def purge_sound_file
  end

end
