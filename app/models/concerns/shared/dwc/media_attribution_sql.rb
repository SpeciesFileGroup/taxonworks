# A concern providing SQL fragments and Ruby methods for media attribution data
# in Darwin Core Archive exports. Each method has both a Ruby implementation
# (for single record access) and a SQL fragment (for bulk export queries).
module Shared::Dwc::MediaAttributionSql
  extend ActiveSupport::Concern

  included do
    # License/Rights SQL fragment
    # Matches dwc_media_dcterms_rights Ruby method
    def self.dwc_media_license_sql(table_alias:)
      # Build CASE statement for all licenses
      cases = CREATIVE_COMMONS_LICENSES.map do |key, value|
        "WHEN attributions.license = '#{key}' THEN '#{value[:link]}'"
      end.join(' ')

      <<~SQL.squish
        CASE #{cases} END
      SQL
    end

    # Owner aggregation SQL fragment
    # Matches dwc_media_owner Ruby method
    def self.dwc_media_owner_sql(table_alias:)
      delimiter = Shared::IsDwcOccurrence::DWC_DELIMITER
      <<~SQL.squish
        LEFT JOIN LATERAL (
          SELECT STRING_AGG(COALESCE(people.cached, organizations.name), '#{delimiter}' ORDER BY roles.position) AS names
          FROM roles
          LEFT JOIN people ON people.id = roles.person_id
          LEFT JOIN organizations ON organizations.id = roles.organization_id
          WHERE roles.role_object_id = attributions.id
            AND roles.role_object_type = 'Attribution'
            AND roles.type = 'AttributionOwner'
        ) owners ON true
      SQL
    end

    # Creator aggregation SQL fragment
    # Matches dwc_media_dc_creator Ruby method
    def self.dwc_media_creator_sql(table_alias:)
      delimiter = Shared::IsDwcOccurrence::DWC_DELIMITER
      <<~SQL.squish
        LEFT JOIN LATERAL (
          SELECT STRING_AGG(people.cached, '#{delimiter}' ORDER BY roles.position) AS names
          FROM roles
          JOIN people ON people.id = roles.person_id
          WHERE roles.role_object_id = attributions.id
            AND roles.role_object_type = 'Attribution'
            AND roles.type = 'AttributionCreator'
        ) creators ON true
      SQL
    end

    # Creator identifiers SQL fragment
    # Matches dwc_media_dcterms_creator Ruby method
    def self.dwc_media_creator_identifiers_sql(table_alias:)
      delimiter = Shared::IsDwcOccurrence::DWC_DELIMITER
      <<~SQL.squish
        LEFT JOIN LATERAL (
          SELECT STRING_AGG(identifiers.cached, '#{delimiter}' ORDER BY roles.position) AS ids
          FROM roles
          JOIN people ON people.id = roles.person_id
          JOIN identifiers ON identifiers.identifier_object_id = people.id
            AND identifiers.identifier_object_type = 'Person'
            AND (identifiers.type = 'Identifier::Global::Orcid' OR identifiers.type = 'Identifier::Global::Wikidata')
          WHERE roles.role_object_id = attributions.id
            AND roles.role_object_type = 'Attribution'
            AND roles.type = 'AttributionCreator'
        ) creator_ids ON true
      SQL
    end

    # Copyright holders SQL fragment
    # Matches dwc_media_credit Ruby method (via attribution_copyright_label helper)
    # Returns both comma-separated names (for non-copyright use) and an array (for grammatical sentences)
    def self.dwc_media_copyright_holders_sql(table_alias:)
      delimiter = Shared::IsDwcOccurrence::DWC_DELIMITER
      <<~SQL.squish
        LEFT JOIN LATERAL (
          SELECT
            STRING_AGG(COALESCE(people.cached, organizations.name), '#{delimiter}' ORDER BY roles.position) AS names,
            ARRAY_AGG(COALESCE(people.cached, organizations.name) ORDER BY roles.position) AS names_array
          FROM roles
          LEFT JOIN people ON people.id = roles.person_id
          LEFT JOIN organizations ON organizations.id = roles.organization_id
          WHERE roles.role_object_id = attributions.id
            AND roles.role_object_type = 'Attribution'
            AND roles.type = 'AttributionCopyrightHolder'
        ) copyright_holders ON true
      SQL
    end
  end

  # Ruby implementation methods
  # (These already exist in Shared::Dwc::MediaExtensions but listed here for reference)

  # def dwc_media_dcterms_rights
  #   CREATIVE_COMMONS_LICENSES[
  #     self.class
  #       .joins(:attribution)
  #       .where(id: id)
  #       .pluck('attributions.license')
  #       .first
  #   ]&.[](:link)
  # end

  # def dwc_media_owner
  #   roles = Role
  #     .joins('INNER JOIN attributions ON attributions.id = roles.role_object_id AND roles.role_object_type = \'Attribution\'')
  #     .where('attributions.attribution_object_id = ? AND attributions.attribution_object_type = ?', id, self.class.name)
  #     .where(type: 'AttributionOwner')
  #     .order(:position)
  #
  #   roles.map do |role|
  #     if role.person_id
  #       Person.find(role.person_id).cached
  #     elsif role.organization_id
  #       Organization.find(role.organization_id).name
  #     end
  #   end.compact.join(Shared::IsDwcOccurrence::DWC_DELIMITER)
  # end

  # def dwc_media_dc_creator
  #   self.class
  #     .joins(attribution: {roles: :person})
  #     .where(roles: {type: 'AttributionCreator'})
  #     .where(id: id)
  #     .order('roles.position')
  #     .pluck('people.cached')
  #     .join(Shared::IsDwcOccurrence::DWC_DELIMITER)
  # end

  # def dwc_media_dcterms_creator
  #   self.class
  #     .joins(attribution: {roles: {person: :identifiers}})
  #     .where(roles: {type: 'AttributionCreator'})
  #     .where(id: id)
  #     .where("identifiers.type = 'Identifier::Global::Orcid' OR identifiers.type = 'Identifier::Global::Wikidata'")
  #     .pluck('identifiers.cached')
  #     .join(CollectionObject::DWC_DELIMITER)
  # end

  # def dwc_media_credit
  #   media = self.class
  #     .joins(attribution: :roles)
  #     .where(roles: {type: 'AttributionCopyrightHolder'})
  #     .where(id: id)
  #     .includes(:attribution)
  #     .first
  #
  #   return nil if media.nil?
  #
  #   ApplicationController.helpers.attribution_copyright_label(media.attribution)
  # end
end
