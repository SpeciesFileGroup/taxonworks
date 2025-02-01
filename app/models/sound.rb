require "wahwah"

# A Sound is digital representation of some noise.  They are linked ivia Conveyances as Images aer linked via Depictions.
#
class Sound < ApplicationRecord
  include Housekeeping
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

  def self.used_recently(user_id, project_id, used_on = '')
    i = arel_table
    d = Conveyance.arel_table

    # i is a select manager
    j = d.project(d['sound_id'], d['updated_at'], d['conveyance_object_type']).from(d)
      .where(d['updated_at'].gt( 1.week.ago ))
      .where(d['updated_by_id'].eq(user_id))
      .where(d['project_id'].eq(project_id))
      .order(d['updated_at'].desc)

    z = j.as('recent_i')

    k = Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(
      z['sound_id'].eq(i['id']).and(z['conveyance_object_type'].eq(used_on))
    ))

    joins(k).distinct.pluck(:id)
  end

  # @params target [String] required, one of nil, `CollectionObject`, FieldOccurrence`, `Otu'
  # @return [Hash] sounds optimized for user selection
  def self.select_optimized(user_id, project_id, target = nil)
    r = used_recently(user_id, project_id, target)
    h = {
      quick: [],
      pinboard: Sound.pinned_by(user_id).where(project_id:).to_a,
      recent: []
    }

    if target && !r.empty?
      h[:recent] = (
        Sound.where('"sounds"."id" IN (?)', r.first(5) ).to_a +
        Sound.where(project_id:, created_by_id: user_id, created_at: 3.hours.ago..Time.now)
        .order('updated_at DESC')
        .limit(3).to_a
      ).uniq.sort{|a,b| a.updated_at <=> b.updated_at}

      h[:quick] = (
        Sound.pinned_by(user_id).pinboard_inserted.where(project_id:).to_a +
        Sound.where('"sounds"."id" IN (?)', r.first(4) ).to_a)
        .uniq.sort{|a,b| a.updated_at <=> b.updated_at}
    else
      h[:recent] = Sound.where(project_id:).order('updated_at DESC').limit(10).to_a
      h[:quick] = Sound.pinned_by(user_id).pinboard_inserted.where(pinboard_items: {project_id:}).order('updated_at DESC')
    end

    h
  end

end
