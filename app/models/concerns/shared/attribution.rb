# Shared code for Attribution.
#
#  The default behaviour with order by youngest source and oldest source is to place records with NIL *last*
# in the list.
#  When multiple attributions exist the earliest or latest is used in the sort order.
#
module Shared::Attribution
  extend ActiveSupport::Concern

  included do
    Attribution.related_foreign_keys.push self.name.foreign_key

    has_many :attributions, as: :attribution_object, validate: false, dependent: :destroy, table_name: 'attribution'

    scope :without_attributions, -> {includes(:attributions).where(attributions: {id: nil})}

    accepts_nested_attributes_for :attributions, reject_if: :reject_attributions, allow_destroy: true

    # Required to drigger validate callbacks, which in turn set user_id related housekeeping
    validates_associated :attributions
  end

  class_methods do
  end

  def attributed?
    self.attributions.any?
  end

  protected

  def reject_attributions(attributed)
    false
  end

end
