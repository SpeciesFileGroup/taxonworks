class CollectionProfile < ActiveRecord::Base
  belongs_to :container
  belongs_to :otu
end
