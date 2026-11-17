# Lets a LayoutItem class place Images, e.g. ones that depict nothing yet.
# See LayoutItem for how these concerns combine.
#
# svg_view_box / svg_clip: crop, sensu Depiction
#
module Shared::Render::ImageItem
  extend ActiveSupport::Concern

  class_methods do
    def composition_item_object_permitted?(klass)
      klass <= Image || super
    end
  end

end
