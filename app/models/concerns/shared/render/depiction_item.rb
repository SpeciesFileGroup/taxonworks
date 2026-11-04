# Lets a LayoutItem class place Depictions, i.e. Images as they depict
# something (an Otu, a CollectionObject, etc.). See LayoutItem for how
# these concerns combine.
#
# svg_view_box / svg_clip: crop for this Layout only; when present it
#   replaces the Depiction's own crop, when nil the Depiction's is used
#
module Shared::Render::DepictionItem
  extend ActiveSupport::Concern

  class_methods do
    def composition_item_object_permitted?(klass)
      klass <= Depiction || super
    end
  end

end
