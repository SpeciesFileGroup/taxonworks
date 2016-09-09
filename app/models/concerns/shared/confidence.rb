# Shared code for apply user assertions of "Confidence" to data.
#
module Shared::Confidence

  extend ActiveSupport::Concern

  included do
    has_many :confidences, as: :confidence_object, validate: true, dependent: :destroy
    has_many :confidence_levels, through: :confidences

    scope :with_confidences, -> { joins(:confidences) }
    scope :without_confidences, -> { includes(:confidences).where(confidences: {id: nil}) }

    accepts_nested_attributes_for :confidences, reject_if: :reject_confidences, allow_destroy: true
  end

  def has_confidences?
    self.confidences.any?
  end

  module ClassMethods
    def with_confidence_level(confidence_level)
      joins(:confidence_levels).where(confidences: {confidence_level: confidence_level})
    end
  end

  protected 

  def reject_confidences(attributed)
    attributed['confidence_level_id'].blank?
  end

end
