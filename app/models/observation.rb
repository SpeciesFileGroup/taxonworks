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
  belongs_to :otu, inverse_of: :observations
  belongs_to :collection_object, inverse_of: :observations

  before_validation :convert_observation_object_global_id
  before_validation :set_type_from_descriptor

  validates_presence_of :descriptor_id, :type
  validate :otu_or_collection_object_set
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

  def self.in_observation_matrix(observation_matrix_id)
    om = ObservationMatrix.find(observation_matrix_id)

    # where(descriptor: om.descriptors, otu: om.otus).or(
    # where(descriptor: om.descriptors, collection_object: om.collection_objects))

    a = Observation.where(descriptor: om.descriptors, otu: om.otus)
    b = Observation.where(descriptor: om.descriptors, collection_object: om.collection_objects)

    Observation.from("((#{a.to_sql}) UNION (#{b.to_sql})) as observations").distinct
  end

  # @params rows is string ("otu_id|collection_object_id")
  def self.by_descriptors_and_rows(descriptor_ids, rows)
    collection_object_ids = rows.collect{|i| i.split('|')[1]}.compact
    otu_ids = rows.collect{|i| i.split('|')[0]}.compact
    # collection_object_ids = ::GlobalIdHelper.ids_by_class_name(row_object_global_ids, 'CollectionObject')
    # otu_ids = ::GlobalIdHelper.ids_by_class_name(row_object_global_ids, 'Otu')

    where(descriptor_id: descriptor_ids, otu_id: otu_ids).or(
      where(descriptor_id: descriptor_ids, collection_object_id: collection_object_ids))
  end

  def self.object_scope(object)
    return Observation.none if object.nil?
    return Observation.where(otu_id: object.id) if object.class.name == 'Otu'
    return Observation.where(collection_object_id: object.id) if object.metamorphosize.class.name == 'CollectionObject'
    Observation.none 
  end

  def self.human_name
    'YAY'
  end

  def observation_object
    [otu, collection_object].compact.first
  end

  def observation_object_global_id=(value)
    set_observation_object_id(GlobalID::Locator.locate(value))
    @observation_object_global_id = value
  end

  def set_observation_object_id(object)
    case object.metamorphosize.class.name
    when 'Otu'
      write_attribute(:otu_id, object.id)
    when 'CollectionObject'
      write_attribute(:collection_object_id, object.id)
    else
      return false
    end 
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

  def convert_observation_object_global_id
    set_observation_object_id(GlobalID::Locator.locate(observation_object_global_id)) if observation_object_global_id 
  end

  def otu_or_collection_object_set
    if otu_id.blank? && collection_object_id.blank? && otu.blank? && collection_object.blank?
      errors.add(:base, 'observations must reference an Otu or collection object')
    end
  end
end

Dir[Rails.root.to_s + '/app/models/observation/**/*.rb'].each { |file| require_dependency file }
