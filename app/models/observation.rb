# Records Qualitative, Quantitative, Statistical, free-text (Working), Media and other types of "measurements" gathered from our observations.
# Where we record the data behind concepts like traits, phenotypes, measurements, character matrices, and descriptive matrices.
#
# Subclasses of Observation define the applicable attributes for its type. Type is echoed 1:1 in each
# corresponding Descriptor, for convenience and validation purposes.
#
# @!attribute cached
#   @return [string]
#     !! Not used. Perhaps records a human readable short description ultimately.
#
# @!attribute cached_column_label
#   @return [string]
#     !! Not used. Candidate for removal.
#
# @!attribute cached_row_label
#   @return [string]
#     !! Not used. Candidate for removal.
#
# @!attribute descriptor_id
#   @return [Descriptor#id]
#     The type of observation according to it's Descriptor. See also `type`.
#
# @!attribute observation_object_id
#   @return [Object#id]
#     The id of the observed object
#
# @!attribute observation_object_type
#   @return [Object#class.name]
#     The type of the observed object
#
# @!attribute type
#   @return [String]
#     The type of observation.  Defines the attribute set that is applicable to it.
#
# @!attribute year_made
#  @return [Integer]
#    4 digit year the observation originated (not when it was recorded in TaxonWorks, though these might be the close to the same)
#
# @!attribute month_made
#  @return [Integer]
#    2 digit month the observation originated
#
# @!attribute day_made
#  @return [Integer]
#    2 digit day the observation originated
#
# @!attribute time_made
#  @return [Integer]
#    time without time zone
#
# Subclass specific attributes
#
# Observation::Qualitative attributes
#
## @!attribute character_state_id
#   @return [Integer]
#     The corresponding CharacterState id for "traditional" Qualitative "characters"
#
# Observation::Quantiative attributes
#
# @!attribute continuous_unit
#   @return [String]
#     A controlled vocabulary from Ruby::Units, like 'm".  The unit of the quantitative measurement
#
# @!attribute continuous_value
#   @return [String]
#     The value of a quantitative measurement
#
# Observation::Working
#
# @!attribute descriptions
#   @return [String]
#     Free text description of an Observation
#
# Observation::??
#
# @!attribute frequency
#   @return [Descriptor#id]
#     ?! Candidate or removal ?!
#
# Observation::PresenceAbsence
#
# @!attribute presence
#   @return [Boolean]
#
# Observation::Sample
# !! Should only apply to OTUs technically, as this
# is an aggregation of measurements seen in a typical
# statistical summary
#
# @!attribute sample_max
#   @return [Boolean]
#     statistical max
#
# @!attribute sample_mean
#   @return [Boolean]
#    statistical mean
#
# @!attribute sample_median
#   @return [Boolean]
#     statistical median
#
# @!attribute sample_min
#   @return [Boolean]
#     statistical median
#
# @!attribute sample_n
#   @return [Boolean]
#     statistical n
#
# @!attribute sample_standard_deviation
#   @return [Boolean]
#     statistical standard deviation
#
# @!attribute sample_standard_error
#   @return [Boolean]
#     statistical standard error
#
# @!attribute sample_standard_units
#   @return [Boolean]
#     A controlled vocabulary from Ruby::Units, like 'm".  The unit of the sample observations
#
class Observation < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include Shared::DataAttributes
  include Shared::Identifiers
  include Shared::Depictions
  include Shared::Notes
  include Shared::Tags
  include Shared::Depictions
  include Shared::Confidences
  include Shared::ProtocolRelationships
  include Shared::IsData
  include Shared::ObservationIndex

  ignore_whitespace_on(:description)

  self.skip_time_zone_conversion_for_attributes = [:time_made]

  # String, not GlobalId
  attr_accessor :observation_object_global_id

  belongs_to :character_state, inverse_of: :observations
  belongs_to :descriptor, inverse_of: :observations
  belongs_to :observation_object, polymorphic: true

  # before_validation :convert_observation_object_global_id

  validates_presence_of :descriptor_id, :type
  validates_presence_of :observation_object
  validate :type_matches_descriptor

  validates :year_made, date_year: { min_year: 1757, max_year: -> {Time.now.year} }
  validates :month_made, date_month: true
  validates :day_made, date_day: {year_sym: :year_made, month_sym: :month_made}, unless: -> {year_made.nil? || month_made.nil?}

  # depends on timeliness 6.0, which is breaking something
  # validates_time :time_made, allow_nil: true

  def qualitative?
    type == 'Observation::Qualitative'
  end

  def presence_absence?
    type == 'Observation::PresenceAbsence'
  end

  def continuous?
    type == 'Observation::Continuous'
  end

  def self.in_observation_matrix(observation_matrix_id)
    Observation.joins('JOIN observation_matrix_rows omr on (omr.observation_object_type = observations.observation_object_type AND omr.observation_object_id = observations.observation_object_id)')
      .joins('JOIN observation_matrix_columns omc on omc.descriptor_id = observations.descriptor_id')
      .where('omr.observation_matrix_id = ? AND omc.observation_matrix_id = ?', observation_matrix_id, observation_matrix_id)
  end

  def self.by_matrix_and_position(observation_matrix_id, options = {})
    opts = {
      row_start:  1,
      row_end: 'all',
      col_start: 1,
      col_end: 'all'
    }.merge!(options.symbolize_keys)

    return in_observation_matrix(observation_matrix_id).order('omc.position, omr.position') if opts[:row_start] == 1 && opts[:row_end] == 'all' && opts[:col_start] == 1 && opts[:col_end] == 'all'

    base = Observation.joins('JOIN observation_matrix_rows omr on (omr.observation_object_type = observations.observation_object_type AND omr.observation_object_id = observations.observation_object_id)')
      .joins('JOIN observation_matrix_columns omc on omc.descriptor_id = observations.descriptor_id')
      .where('omr.observation_matrix_id = ? AND omc.observation_matrix_id = ?', observation_matrix_id, observation_matrix_id)

    # row scope
    base = base.where('omr.position >= ?', opts[:row_start])
    base = base.where('omr.position <= ?', opts[:row_end]) if !(opts[:row_end] == 'all')

    # col scope
    base = base.where('omc.position >= ?', opts[:col_start])
    base = base.where('omc.position <= ?', opts[:col_end]) if !(opts[:col_end] == 'all')

    base
  end

  def self.by_observation_matrix_row(observation_matrix_row_id)
    Observation.joins('JOIN observation_matrix_rows omr on (omr.observation_object_type = observations.observation_object_type AND omr.observation_object_id = observations.observation_object_id)')
      .joins('JOIN observation_matrix_columns omc on omc.descriptor_id = observations.descriptor_id')
      .where('omr.id = ?', observation_matrix_row_id)
      .order('omc.position')
  end

  # TODO: deprecate or remove
  def self.object_scope(object)
    return Observation.none if object.nil?
    Observation.where(observation_object: object)
  end

  def self.human_name
    'YAY'
  end

  def observation_object_global_id=(value)
    self.observation_object = GlobalID::Locator.locate(value)
    @observation_object_global_id = value
  end

  # @return [String]
  # TODO: this is not memoized correctly ?!
  def observation_object_global_id
    if observation_object
      observation_object.to_global_id.to_s
    else
      @observation_object_global_id
    end
  end

  # @return [Boolean]
  # @params old_global_id [String]
  #    global_id of collection object or Otu
  #
  # @params new_global_id [String]
  #    global_id of collection object or Otu
  #
  def self.copy(old_global_id, new_global_id)
    begin
      old = GlobalID::Locator.locate(old_global_id)

      Observation.transaction do
        old.observations.each do |o|
          d = o.dup
          d.update(observation_object_global_id: new_global_id)

          # Copy depictions
          o.depictions.each do |i|
            j = i.dup
            j.update(depiction_object: d)
          end
        end
      end
      true
    rescue
      return false
    end
    true
  end

  # Destroy all observations for the set of descriptors in a given row
  def self.destroy_row(observation_matrix_row_id)
    r = ObservationMatrixRow.find(observation_matrix_row_id)
    begin
      Observation.transaction do
        r.observations.destroy_all
      end
    rescue
      raise
    end
    true
  end

  # Destroy observations for the set of descriptors in a given column
  def self.destroy_column(observation_matrix_column_id)
    c = ObservationMatrixColumn.find(observation_matrix_column_id)
    byebug
    begin
      Observation.transaction do
        c.observations.destroy_all
      end
    rescue
      raise
    end
    true
  end

  # @return [Hash]
  #  { created: 1, failed: 2 }
  def self.code_column(observation_matrix_column_id, observation_params)
    c = ObservationMatrixColumn.find(observation_matrix_column_id)
    o = ObservationMatrix.find(c.observation_matrix_id)

    descriptor = c.descriptor

    # Type is required on the onset
    p = observation_params.merge(
      type: descriptor.observation_type
    )

    h = Hash.new(0)

    Observation.transaction do
      o.observation_matrix_rows.each do |r|
        begin
          Observation.create!(
            p.merge(
              observation_object: r.observation_object,
              descriptor: descriptor,
            )
          )
          h[:passed] += 1
        rescue ActiveRecord::RecordInvalid
          h[:failed] += 1
        end
      end
    end
    h
  end

  protected

  def type_matches_descriptor
    a = type&.split('::')&.last
    b = descriptor&.type&.split('::')&.last
    errors.add(:type, 'type of Observation does not match type of Descriptor') if a && b && a != b
  end

end

Dir[Rails.root.to_s + '/app/models/observation/**/*.rb'].each { |file| require_dependency file }
