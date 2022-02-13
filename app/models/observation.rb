# Observations are of various types, e.g. Qualitative, Quantitative, Statistical.  Made on an Otu or CollectionObject.
# They are where you store the data for concepts like traits, phenotypes, measurements, character matrices, descriptive matrices etc.
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
  include Shared::IsData

  ignore_whitespace_on(:description)

  # String, not GlobalId
  attr_accessor :observation_object_global_id

  belongs_to :character_state, inverse_of: :observations
  belongs_to :descriptor, inverse_of: :observations
  belongs_to :observation_object, polymorphic: true

  # before_validation :convert_observation_object_global_id
  before_validation :set_type_from_descriptor
  validates_presence_of :descriptor_id, :type
  validates_presence_of :observation_object
  validate :type_matches_descriptor

  def qualitative?
    type == 'Observation::Qualitative'
  end

  def presence_absence?
    type == 'Observation::PresenceAbsence'
  end

  def continuous?
    type == 'Observation::Continuous'
  end

  # TODO:  Shouldn't this have access to cached?
  # 
  def self.in_observation_matrix(observation_matrix_id)
    Observation.joins('JOIN observation_matrix_rows omr on (omr.observation_object_type = observations.observation_object_type AND omr.observation_object_id = observations.observation_object_id)')  
      .joins('JOIN observation_matrix_columns omc on omc.descriptor_id = observations.descriptor_id')
      .where('omr.observation_matrix_id = ? AND omc.observation_matrix_id = ?', observation_matrix_id, observation_matrix_id)
  end

  # @params rows is string 'Otu123'
  # TODO: migrate
  def self.by_descriptors_and_rows(descriptor_ids, rows)
    collection_object_ids = rows.collect{|i| i.split('|')[1]}.compact
    otu_ids = rows.collect{|i| i.split('|')[0]}.compact

    where(descriptor_id: descriptor_ids, otu_id: otu_ids).or(
      where(descriptor_id: descriptor_ids, collection_object_id: collection_object_ids))
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
    # Could select specifics here
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
          d.update!(observation_object_global_id: new_global_id) 
        end
      end
      true
    rescue
      return false
    end
    true
  end

  # TODO: Does this belong here? 
  # Remove all observations for the set of descriptors in a given row
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

  protected

  def set_type_from_descriptor
    if type.blank? && descriptor&.type
      write_attribute(:type, 'Observation::' + descriptor.type.split('::').last)
    end
  end

  def type_matches_descriptor
    a = type&.split('::')&.last
    b = descriptor&.type&.split('::')&.last
    errors.add(:type, 'type of Observation does not match type of Descriptor') if a && b && a != b
  end

end

Dir[Rails.root.to_s + '/app/models/observation/**/*.rb'].each { |file| require_dependency file }
