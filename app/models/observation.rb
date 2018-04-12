class Observation < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include Shared::DataAttributes
  include Shared::Identifiers
  include Shared::Notes
  include Shared::Tags
  include Shared::IsData
  include Shared::Depictions
  include Shared::Confidences

  attr_accessor :observation_object_global_id

  belongs_to :descriptor, inverse_of: :observations
  belongs_to :otu, inverse_of: :observations
  belongs_to :collection_object, inverse_of: :observations

  validates_presence_of :descriptor

  validate :otu_or_collection_object_set

  def self.human_name
    'YAY'
  end

  def observation_object
    [otu, collection_object].compact.first
  end

  def observation_object_global_id=(value)
    object = GlobalID::Locator.locate(value)
    case object.metamorphosize.class.name
    when 'Otu'
      write_attribute(:otu_id, object.id)
    when 'CollectionObject'
      write_attribute(:collection_object_id, object.id)
    else
      return false
    end 
    @row_object_global_id = value
  end

  def observation_object_global_id
    observation_object.to_global_id.to_s
  end

  protected

  def otu_or_collection_object_set
    if otu_id.blank? && collection_object_id.blank? && otu.blank? && collection_object.blank?
      errors.add(:base, 'observations must reference an Otu or collection object')
    end
  end

end


Dir[Rails.root.to_s + '/app/models/observation/**/*.rb'].each { |file| require_dependency file }
