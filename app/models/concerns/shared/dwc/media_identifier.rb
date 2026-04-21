# Shared logic for media identifier generation in both Ruby and SQL contexts.
# Used by Image and Sound models to generate Darwin Core media identifiers.
module Shared::Dwc::MediaIdentifier
  extend ActiveSupport::Concern

  # Maps model class names to their namespace prefixes
  NAMESPACE_BY_CLASS = {
    'Image' => 'image',
    'Sound' => 'sound'
  }.freeze

  # Preferred identifier types in order of preference
  # uuid takes precedence over uri, which takes precedence over id
  PREFERRED_IDENTIFIER_TYPES = {
    uuid: 'Identifier::Global::Uuid',
    uri:  'Identifier::Global::Uri'
  }.freeze

  class_methods do
    # Ruby implementation: generates identifier for a record instance.
    # @param record [Image, Sound] the media record
    # @return [String] formatted identifier (e.g., "image:uuid123" or "sound:42")
    def dwc_media_identifier_for(record)
      ns = NAMESPACE_BY_CLASS.fetch(record.class.name)
      "#{ns}:#{record.uuid || record.uri || record.id}"
    end

    # SQL implementation: generates SQL CASE expression for identifier selection.
    # NOTE: This MUST produce the same result as dwc_media_identifier_for
    # (verified by spec).
    # @param table_alias [String] SQL table alias (e.g., 'img', 'snd')
    # @return [String] SQL CASE expression
    def dwc_media_identifier_sql(table_alias:)
      ns = NAMESPACE_BY_CLASS.fetch(name) # Image -> "image", Sound -> "sound"

      <<~SQL.squish
        CASE
          WHEN uuid_id.identifier IS NOT NULL THEN '#{ns}:' || uuid_id.identifier
          WHEN uri_id.identifier  IS NOT NULL THEN '#{ns}:' || uri_id.identifier
          ELSE '#{ns}:' || #{table_alias}.id::text
        END
      SQL
    end
  end

  # Instance method: delegates to class helper
  # Images and sounds are unlikely to have a uuid or uri, so namespace with
  # class name (this field is supposed to be unique).
  def dwc_media_identifier
    self.class.dwc_media_identifier_for(self)
  end
end
