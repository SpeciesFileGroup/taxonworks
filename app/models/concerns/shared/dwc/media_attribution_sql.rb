# A concern providing SQL fragments to match Ruby methods for media attribution data
# in Darwin Core Archive exports.

# The ruby implementation methods can be found in Shared::Dwc::MediaExtensions,
# and the specs that keep the sql and ruby versions matched are in
# media_attribution_sql_spec.rb.

# !! If you add a new sql method here you probably need to add specs to make
# sure it's maintained with its ruby counterpart. !!

module Shared::Dwc::MediaAttributionSql
  extend ActiveSupport::Concern

  included do
    # License/Rights SQL fragment.
    # Matches dwc_media_dcterms_rights Ruby method.
    def self.dwc_media_license_sql
      # Build CASE statement for all licenses.
      cases = CREATIVE_COMMONS_LICENSES.map do |key, value|
        "WHEN attributions.license = '#{key}' THEN '#{value[:link]}'"
      end.join(' ')

      <<~SQL.squish
        CASE #{cases} END
      SQL
    end

    # Owner aggregation SQL fragment.
    # Matches dwc_media_owner Ruby method.
    def self.dwc_media_owner_sql
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

    # Creator aggregation SQL fragment.
    # Matches dwc_media_dc_creator Ruby method.
    def self.dwc_media_creator_sql
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

    # Creator identifiers SQL fragment.
    # Matches dwc_media_dcterms_creator Ruby method.
    def self.dwc_media_creator_identifiers_sql
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

    # Copyright holders SQL fragment.
    # Matches dwc_media_credit Ruby method (via attribution_copyright_label helper).
    # Returns both comma-separated names (for non-copyright use) and an array (for grammatical sentences).
    def self.dwc_media_copyright_holders_sql
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

end
