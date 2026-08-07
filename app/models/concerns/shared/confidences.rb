# Shared code for apply user assertions of Confidence to data.
#
module Shared::Confidences

  extend ActiveSupport::Concern

  included do
    ::Confidence.related_foreign_keys.push self.name.foreign_key

    has_many :confidences, as: :confidence_object, validate: true, dependent: :destroy, inverse_of: :confidence_object
    has_many :confidence_levels, through: :confidences

    scope :with_confidences, -> { joins(:confidences) }
    scope :without_confidences, -> { where.missing(:confidences) }

    accepts_nested_attributes_for :confidences, reject_if: :reject_confidences, allow_destroy: true

    validate :identical_new_confidences_are_prevented

    protected

    def identical_new_confidences_are_prevented
      a = []
      confidences.each do |c|
        errors.add(:base, 'identical confidence level') if a.include?(c.confidence_level.attributes)
        a.push c.confidence_level.attributes
      end
    end

  end

  module ClassMethods
    def with_confidence_level(confidence_level)
      joins(:confidence_levels).where(confidences: {confidence_level:})
    end
  end

  def reject_confidences(attributed)
    attributed['confidence_level_id'].blank?
  end

end
