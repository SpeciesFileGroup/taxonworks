# Lets a LayoutItem class place CollectionObjects. See LayoutItem for how
# these concerns combine.
#
module Shared::Render::CollectionObjectItem
  extend ActiveSupport::Concern

  class_methods do
    def composition_item_object_permitted?(klass)
      klass <= CollectionObject || super
    end
  end

end
