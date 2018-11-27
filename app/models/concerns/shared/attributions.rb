# Shared code for Attribution.
#
#  The default behaviour with order by youngest source and oldest source is to place records with NIL *last*
# in the list.
#  When multiple attributions exist the earliest or latest is used in the sort order.
#
module Shared::Attributions
  extend ActiveSupport::Concern

  included do
    ::Attribution.related_foreign_keys.push self.name.foreign_key

    has_one :attribution, as: :attribution_object, validate: false, dependent: :destroy

    scope :without_attribution, -> {includes(:attribution).where(attributions: {id: nil})}
    scope :with_attribution, -> { joins(:attribution) }

    accepts_nested_attributes_for :attribution, reject_if: :reject_attribution, allow_destroy: true

    # Required to trigger validate callbacks, which in turn set user_id related housekeeping
    validates_associated :attribution
  end

  class_methods do
  end

  def attributed? 
    self.attribution.present?
  end

  protected

  def reject_attribution(attributed)
    false
  end

end
