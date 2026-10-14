# Shared code for objects that can be placed in a Layout. Which
# LayoutItem subclasses may reference which classes is decided by the
# LayoutItem subclass, see CompositionItem.composition_item_object_permitted?
#
module Shared::LayoutItems

  extend ActiveSupport::Concern

  included do
    # No class_name: (inferred), so that Shared::Unify moves these to the
    # surviving object, see Shared::Unify#inferred_relations
    has_many :layout_items, as: :composition_item_object,
      inverse_of: :composition_item_object, dependent: :destroy
  end

end
