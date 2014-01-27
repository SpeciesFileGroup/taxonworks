class CollectionObject < ActiveRecord::Base

  include Housekeeping
  include Shared::Identifiable
  include Shared::Containable
  include Shared::Citable

  # before_save :classify_based_on_total

  belongs_to :preparation_type
  belongs_to :repository, inverse_of: :collection_objects

  protected
  # def classify_based_on_total
  #   if total > 0
  #     self.type = 'Lot'
  #   end
  # end
  

end
