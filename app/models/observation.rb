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
  include Shared::IsData
  include Shared::Depictions
  include Shared::Confidences

  attr_accessor :observation_object_global_id

  belongs_to :descriptor, inverse_of: :observations
  belongs_to :otu, inverse_of: :observations
  belongs_to :collection_object, inverse_of: :observations

  after_initialize :convert_observation_object_global_id

  validates_presence_of :descriptor, :type
  validate :otu_or_collection_object_set

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

  def observation_object_global_id
    if observation_object
      observation_object.to_global_id.to_s
    else
      @observation_object_global_id
    end
  end

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
        end
      end
      true
    rescue
      raise
    end
  end

  protected

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
