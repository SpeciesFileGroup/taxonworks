class MatrixRow < ActiveRecord::Base
  include Housekeeping
  include Shared::Citable
  include Shared::Identifiable
  include Shared::IsData
  include Shared::Taggable
  include Shared::Notable
  
  acts_as_list
  
  belongs_to :matrix
  belongs_to :otu
  belongs_to :collection_object

  after_initialize :set_reference_count

  validates_presence_of :matrix
  validate :otu_and_collection_object_blank
  validate :otu_and_collection_object_given
  validates_uniqueness_of :otu_id, scope: [:matrix_id], if: '!otu_id.nil?'
  validates_uniqueness_of :collection_object_id, scope: [:matrix_id], if: '!collection_object_id.nil?'


  def set_reference_count
    self.reference_count ||= 0
  end

  private

  def otu_and_collection_object_blank
    if otu_id.nil? && collection_object_id.nil?
      errors.add(:base, "Specify otu OR collection object!")
    end
  end

  def otu_and_collection_object_given
    if !otu_id.nil? && !collection_object_id.nil?
      errors.add(:base, "Specify otu OR collection object, not both!")
    end
  end
end
