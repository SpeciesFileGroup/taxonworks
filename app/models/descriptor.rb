# Descriptors are the general mechanism for describing CollectionObjects (individual specimens) or Otus (taxa).
#
# They come in various types, reflecting the approaches commonly used to describe specimens and OTUs:
#
#  Working - raw notes or images, "primal" observations, not yet refined to states or measurements
#  Qualitative - Represents character/character_state expressions as traditionally understood.
#  Quantitative - Single measurements.
#  Sample - Summaries of multiple observations recorded in a statistical manner. Only valid for Otus. For example "length 42-77mm (n=5, min: 42, max:Only valid for Otus."
#
class Descriptor < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include Shared::Identifiers
  include Shared::IsData
  include Shared::Tags
  include Shared::Notes
  include Shared::DataAttributes
  include Shared::AlternateValues
  include Shared::Confidences
  include Shared::Documentation
  include SoftValidation

  acts_as_list scope: [:project_id]

  ALTERNATE_VALUES_FOR = [:name, :short_name].freeze

  validates_presence_of :name, :type
  validate :type_is_subclassed
  validate :short_name_is_shorter

  has_many :observations, inverse_of: :descriptor, dependent: :restrict_with_error
  has_many :otus, through: :observations, inverse_of: :descriptors
  has_many :observation_matrix_column_items, inverse_of: :descriptor
  has_many :observation_matrix_columns, inverse_of: :descriptor

  has_many :observation_matrices, through: :observation_matrix_columns

  soft_validate(:sv_short_name_is_short)

  def self.human_name
    self.name.demodulize.humanize
  end

  def qualitative?
    type == 'Descriptor::Qualitative'
  end

  def presence_absence?
    type == 'Descriptor::PresenceAbsence'
  end

  def gene?
    type == 'Descriptor::Gene'
  end

  protected

  def type_is_subclassed
    if !DESCRIPTOR_TYPES[type]
      errors.add(:type, 'type must be a valid subclass')
    end
  end

  def short_name_is_shorter
    errors.add(:short_name, 'is longer than name!') if short_name && name && (short_name.length > name.length)
  end

  def sv_short_name_is_short
    soft_validations.add(:short_name, 'should likely be less than 12 characters long') if short_name && short_name.length > 12
  end
end

Dir[Rails.root.to_s + '/app/models/descriptor/**/*.rb'].each { |file| require_dependency file }
