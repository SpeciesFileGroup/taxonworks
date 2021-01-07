# Shared code for objects that have (physical) labels.
#
module Shared::Labels

  extend ActiveSupport::Concern
  included do

    ::Label.related_foreign_keys.push self.name.foreign_key

    # Validation happens on the parent side!
    has_many :labels, as: :label_object, validate: true, dependent: :destroy
    accepts_nested_attributes_for :labels, reject_if: :reject_labels, allow_destroy: true

    protected

    def reject_labels(attributed)
      attributed['text'].blank? && attributed[:text_method].blank?
    end

  end

  def labeled?
    labels.any?
  end

end
