class Observation < ActiveRecord::Base
  include Housekeeping
  include Shared::Citable             
  include Shared::DataAttributes
  include Shared::Identifiable
  include Shared::Notable
  include Shared::Taggable
  include Shared::IsData
  include Shared::Depictions

  belongs_to :descriptor
  belongs_to :otu
  belongs_to :collection_object
 
  validates_presence_of :descriptor_id

  validate :otu_or_collection_object_set

  def self.human_name
      'YAY'
  end


  protected

  def otu_or_collection_object_set
    if otu_id.blank? && collection_object_id.blank?
      errors.add(:base, 'observations must reference an Otu or collection object') 
    end
  end
  
end


Dir[Rails.root.to_s + '/app/models/observation/**/*.rb'].each { |file| require_dependency file }
