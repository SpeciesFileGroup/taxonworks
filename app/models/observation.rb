class Observation < ActiveRecord::Base
  include Housekeeping
  include Shared::Citable             
  include Shared::DataAttributes
  include Shared::Identifiable
  include Shared::Notable
  include Shared::Taggable
  include Shared::IsData
  include Shared::Depictions
  include Shared::Confidence

  belongs_to :descriptor, inverse_of: :observations
  belongs_to :otu, inverse_of: :observations
  belongs_to :collection_object, inverse_of: :observations
 
  validates_presence_of :descriptor

  validate :otu_or_collection_object_set

  def self.human_name
  end

  protected

  def otu_or_collection_object_set
    if otu_id.blank? && collection_object_id.blank? && otu.blank? && collection_object.blank?
      errors.add(:base, 'observations must reference an Otu or collection object') 
    end
  end
  
end


Dir[Rails.root.to_s + '/app/models/observation/**/*.rb'].each { |file| require_dependency file }
