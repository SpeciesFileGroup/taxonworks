class Depiction < ActiveRecord::Base
  include Housekeeping
  include Shared::Taggable
  include Shared::IsData

  belongs_to :image, inverse_of: :depictions
  belongs_to :depiction_object, polymorphic: true

  validates_presence_of :depiction_object

  accepts_nested_attributes_for :image

  # @return [DepictionObject]
  #   alias to simplify reference across classes 
  def annotated_object
    depiction_object
  end


end
