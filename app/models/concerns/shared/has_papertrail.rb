# Shared code for models using PaperTrail
#
module Shared::HasPapertrail
  extend ActiveSupport::Concern
  included do
    has_paper_trail on: [:update], ignore: [:created_at, :updated_at]

    before_update do
      PaperTrail.request.whodunnit = Current.user_id
    end
  end

  # Returns the updater's ID of the object's attribute
  #
  # @param attribute [Symbol, String] the name of the attribute to check
  # @return [Integer]
  def attribute_updater(attribute)
    if version = detect_version(attribute)
      return version.whodunnit.to_i
    end
    versions.first&.reify&.updated_by_id || updated_by_id
  end

  # Returns the update time of the object's attribute
  #
  # @param attribute [Symbol, String] the name of the attribute to check
  # @return [DateTime]
  def attribute_updated(attribute)
    if version = detect_version(attribute)
      return version.created_at
    end
    versions.first&.reify&.updated_at || updated_at
  end

  private

  def detect_version(attribute)
    versions.reverse.detect do |version|
      version.reify&.send(attribute) != send(attribute)
    end
  end

end
