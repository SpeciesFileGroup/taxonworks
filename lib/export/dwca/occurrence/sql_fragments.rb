module Export::Dwca::Occurrence
  # SQL fragment builders for DwC-A export queries
  # These are stateless helpers that generate SQL snippets for complex queries
  module SqlFragments
    # SQL fragment: Media identifier with CSV sanitization
    # @param media_class [Class] Media class (Image or Sound)
    # @param media_table_alias [String] SQL table alias for the media table
    # @return [String] SQL expression for sanitized identifier
    def media_identifier_sql(media_class, media_table_alias)
      identifier_expr = media_class.dwc_media_identifier_sql(table_alias: media_table_alias)
      "pg_temp.sanitize_csv(#{identifier_expr})"
    end

    # SQL fragment: Media identifier JOINs for UUID and URI
    # Provides LEFT JOINs to the identifiers table for UUID and URI lookups
    # @param media_class [Class] Media class (Image or Sound)
    # @param table_alias [String] SQL table alias for the media table
    # @return [String] SQL JOIN clauses for UUID and URI identifiers
    def media_identifier_joins_sql(media_class, table_alias)
      media_type = media_class.name
      <<~SQL.squish
        LEFT JOIN identifiers uuid_id ON uuid_id.identifier_object_id = #{table_alias}.id
                                      AND uuid_id.identifier_object_type = '#{media_type}'
                                      AND uuid_id.type LIKE  'Identifier::Global::Uuid%'
        LEFT JOIN identifiers uri_id ON uri_id.identifier_object_id = #{table_alias}.id
                                      AND uri_id.identifier_object_type = '#{media_type}'
                                      AND uri_id.type LIKE 'Identifier::Global::Uri%'
      SQL
    end

    # SQL fragment: Image occurrence resolution JOINs.
    # Resolves images to dwc_occurrences via
    #   depictions -> collection_objects/field_occurrences.
    # Includes filtering to only scoped occurrences.
    # @param image_alias [String] SQL table alias for images table
    # @return [String] SQL JOIN clauses for resolving image to occurrence
    def image_occurrence_resolution_joins_sql(image_alias: 'img')
      <<~SQL
        -- Join to get coreid (occurrenceID) via depiction -> collection_object/field_occurrence -> dwc_occurrence
        -- IMPORTANT: Only include media for occurrences that are actually in the export scope
        LEFT JOIN depictions dep ON dep.image_id = #{image_alias}.id
        LEFT JOIN collection_objects co ON co.id = dep.depiction_object_id AND dep.depiction_object_type = 'CollectionObject'
        LEFT JOIN field_occurrences fo ON fo.id = dep.depiction_object_id AND dep.depiction_object_type = 'FieldOccurrence'
        LEFT JOIN observations obs ON obs.id = dep.depiction_object_id AND dep.depiction_object_type = 'Observation'
        LEFT JOIN collection_objects co_obs ON co_obs.id = obs.observation_object_id AND obs.observation_object_type = 'CollectionObject'
        LEFT JOIN field_occurrences fo_obs ON fo_obs.id = obs.observation_object_id AND obs.observation_object_type = 'FieldOccurrence'

        -- Filter to only scoped occurrences
        LEFT JOIN temp_scoped_occurrences scope_co ON scope_co.occurrence_id = co.id AND scope_co.occurrence_type = 'CollectionObject'
        LEFT JOIN temp_scoped_occurrences scope_fo ON scope_fo.occurrence_id = fo.id AND scope_fo.occurrence_type = 'FieldOccurrence'
        LEFT JOIN temp_scoped_occurrences scope_co_obs ON scope_co_obs.occurrence_id = co_obs.id AND scope_co_obs.occurrence_type = 'CollectionObject'
        LEFT JOIN temp_scoped_occurrences scope_fo_obs ON scope_fo_obs.occurrence_id = fo_obs.id AND scope_fo_obs.occurrence_type = 'FieldOccurrence'

        LEFT JOIN dwc_occurrences dwc ON (dwc.dwc_occurrence_object_id = co.id AND dwc.dwc_occurrence_object_type = 'CollectionObject' AND scope_co.occurrence_id IS NOT NULL)
                                      OR (dwc.dwc_occurrence_object_id = fo.id AND dwc.dwc_occurrence_object_type = 'FieldOccurrence' AND scope_fo.occurrence_id IS NOT NULL)
                                      OR (dwc.dwc_occurrence_object_id = co_obs.id AND dwc.dwc_occurrence_object_type = 'CollectionObject' AND scope_co_obs.occurrence_id IS NOT NULL)
                                      OR (dwc.dwc_occurrence_object_id = fo_obs.id AND dwc.dwc_occurrence_object_type = 'FieldOccurrence' AND scope_fo_obs.occurrence_id IS NOT NULL)
      SQL
    end

    # SQL fragment: Sound occurrence resolution JOINs
    # Resolves sounds to dwc_occurrences via conveyances -> collection_objects/field_occurrences
    # Includes filtering to only scoped occurrences
    # @param sound_alias [String] SQL table alias for sounds table
    # @return [String] SQL JOIN clauses for resolving sound to occurrence
    def sound_occurrence_resolution_joins_sql(sound_alias: 'snd')
      <<~SQL
        -- Join to get coreid (occurrenceID) via conveyance -> collection_object/field_occurrence -> dwc_occurrence
        -- IMPORTANT: Only include media for occurrences that are actually in the export scope
        LEFT JOIN conveyances conv ON conv.sound_id = #{sound_alias}.id
        LEFT JOIN collection_objects co ON co.id = conv.conveyance_object_id AND conv.conveyance_object_type = 'CollectionObject'
        LEFT JOIN field_occurrences fo ON fo.id = conv.conveyance_object_id AND conv.conveyance_object_type = 'FieldOccurrence'

        -- Filter to only scoped occurrences
        LEFT JOIN temp_scoped_occurrences scope_co ON scope_co.occurrence_id = co.id AND scope_co.occurrence_type = 'CollectionObject'
        LEFT JOIN temp_scoped_occurrences scope_fo ON scope_fo.occurrence_id = fo.id AND scope_fo.occurrence_type = 'FieldOccurrence'

        LEFT JOIN dwc_occurrences dwc ON (dwc.dwc_occurrence_object_id = co.id AND dwc.dwc_occurrence_object_type = 'CollectionObject' AND scope_co.occurrence_id IS NOT NULL)
                                      OR (dwc.dwc_occurrence_object_id = fo.id AND dwc.dwc_occurrence_object_type = 'FieldOccurrence' AND scope_fo.occurrence_id IS NOT NULL)
      SQL
    end

    # SQL fragment: Associated specimen reference URL
    # Handles collection objects, field occurrences, and their observations
    # @param include_observations [Boolean] whether to include observation table aliases (co_obs, fo_obs)
    # @return [String] SQL CASE statement for building specimen reference URLs
    def associated_specimen_reference_sql(include_observations: true)
      co_base = Shared::Api.api_base_path(CollectionObject)
      fo_base = Shared::Api.api_base_path(FieldOccurrence)

      base_cases = <<~SQL.strip
        CASE
          WHEN co.id IS NOT NULL THEN '#{co_base}/' || co.id
          WHEN fo.id IS NOT NULL THEN '#{fo_base}/' || fo.id
      SQL

      observation_cases = if include_observations
        <<~SQL

          WHEN co_obs.id IS NOT NULL THEN '#{co_base}/' || co_obs.id
          WHEN fo_obs.id IS NOT NULL THEN '#{fo_base}/' || fo_obs.id
        SQL
      else
        "\n"
      end

      <<~SQL.strip
        #{base_cases}#{observation_cases}          ELSE NULL
        END
      SQL
    end

    # SQL fragment: Copyright label from temp attribution table.
    # Generates copyright string from year and holder names.
    # @param attr_table_alias [String] SQL table alias for attribution temp table
    # @return [String] SQL CASE statement for building copyright label
    def copyright_label_sql_from_temp(attr_table_alias = 'attr')
      <<-SQL
        CASE
          WHEN #{attr_table_alias}.copyright_year IS NOT NULL OR #{attr_table_alias}.copyright_holder_names_array IS NOT NULL THEN
            '©' ||
            CASE
              WHEN #{attr_table_alias}.copyright_year IS NOT NULL AND #{attr_table_alias}.copyright_holder_names_array IS NOT NULL
                THEN #{attr_table_alias}.copyright_year::text || ' ' || pg_temp.authorship_sentence(#{attr_table_alias}.copyright_holder_names_array)
              WHEN #{attr_table_alias}.copyright_year IS NOT NULL
                THEN #{attr_table_alias}.copyright_year::text
              ELSE pg_temp.authorship_sentence(#{attr_table_alias}.copyright_holder_names_array)
            END
          ELSE NULL
        END
      SQL
    end
  end
end
