module Export::Dwca::Occurrence
  # Service object for exporting media (images and sounds) in DwC-A format.
  class MediaExporter
    include Export::Dwca::Occurrence::SqlFragments
    include Export::Dwca::Occurrence::PostgresqlFunctions

    # @param media_extension [Hash] config with :collection_objects and
    # :field_occurrences SQL
    def initialize(media_extension:)
      @media_extension = media_extension
    end

    # Main export method - writes media records to output file.
    # @param output_file [Tempfile, File] output file for media TSV data
    def export_to(output_file)
      media_extension_to_file(output_file)
    end

    private

    # Bulk creates short URLs for many long URLs at once.
    # Uses Shared::Api.shorten_url within a transaction for safety and speed.
    # @param urls_data [Array<Hash>] array of {long_url:, context:}
    # @return [Hash] map of long_url => short_url
    def bulk_create_short_urls(urls_data)
      return {} if urls_data.empty?

      Rails.logger.debug "dwca_export: bulk creating #{urls_data.size} short URLs"

      result_map = {}

      # Use transaction for speed (single commit at end)
      ActiveRecord::Base.transaction do
        urls_data.each do |item|
          long_url = item[:long_url]
          result_map[long_url] = Shared::Api.shorten_url(long_url)
        end
      end

      Rails.logger.debug "dwca_export: bulk created #{urls_data.size} short URLs successfully"

      result_map
    end

    def create_scoped_occurrence_temp_table
      conn = ActiveRecord::Base.connection

      conn.execute("DROP TABLE IF EXISTS temp_scoped_occurrences")

      sql = <<-SQL
        CREATE TEMP TABLE temp_scoped_occurrences (
          occurrence_type text,
          occurrence_id integer,
          PRIMARY KEY (occurrence_type, occurrence_id)
        )
      SQL
      conn.execute(sql)

      # Insert scoped collection objects
      if @media_extension[:collection_objects]
        conn.execute(<<-SQL)
          INSERT INTO temp_scoped_occurrences (occurrence_type, occurrence_id)
          SELECT 'CollectionObject', id
          FROM (#{@media_extension[:collection_objects]}) AS co
        SQL
      end

      # Insert scoped field occurrences
      if @media_extension[:field_occurrences]
        conn.execute(<<-SQL)
          INSERT INTO temp_scoped_occurrences (occurrence_type, occurrence_id)
          SELECT 'FieldOccurrence', id
          FROM (#{@media_extension[:field_occurrences]}) AS fo
        SQL
      end

      Rails.logger.debug 'dwca_export: scoped occurrence temp table created'
    end

    # Creates temp tables mapping media to occurrences.
    # Pre-computes the complex join logic once instead of executing it in the
    # streaming COPY query.
    # @param image_ids [Array<Integer>]
    # @param sound_ids [Array<Integer>]
    def create_media_occurrence_mapping_tables(image_ids, sound_ids)
      create_image_occurrence_mapping_table(image_ids) unless image_ids.empty?
      create_sound_occurrence_mapping_table(sound_ids) unless sound_ids.empty?
    end

    # Creates temp table mapping images to their occurrences.
    # Handles multiple paths: direct depictions and observation-based depictions.
    # @param image_ids [Array<Integer>]
    def create_image_occurrence_mapping_table(image_ids)
      conn = ActiveRecord::Base.connection

      conn.execute("DROP TABLE IF EXISTS temp_image_occurrence_map")
      conn.execute(<<~SQL)
        CREATE TEMP TABLE temp_image_occurrence_map (
          image_id integer,
          occurrence_id text,
          occurrence_object_type text,
          occurrence_object_id integer,
          depiction_id integer,
          figure_label text,
          caption text,
          sled_image_id integer,
          svg_view_box text,
          access_uri text,
          PRIMARY KEY (image_id, occurrence_id, depiction_id)
        )
      SQL

      conn.execute(<<~SQL)
        INSERT INTO temp_image_occurrence_map (image_id, occurrence_id, occurrence_object_type, occurrence_object_id, depiction_id, figure_label, caption, sled_image_id, svg_view_box)
        SELECT DISTINCT
          img.id AS image_id,
          dwc."occurrenceID" AS occurrence_id,
          dwc.dwc_occurrence_object_type AS occurrence_object_type,
          dwc.dwc_occurrence_object_id AS occurrence_object_id,
          dep.id AS depiction_id,
          dep.figure_label,
          dep.caption,
          dep.sled_image_id,
          dep.svg_view_box
        FROM images img
        INNER JOIN temp_media_image_links links ON links.image_id = img.id
        #{image_occurrence_resolution_joins_sql(image_alias: 'img')}
        WHERE dwc."occurrenceID" IS NOT NULL
      SQL

      conn.execute("CREATE INDEX idx_temp_img_occ_map ON temp_image_occurrence_map(image_id)")
      Rails.logger.debug 'dwca_export: image occurrence mapping table created'
    end

    # Creates temp table mapping sounds to their occurrences.
    # @param sound_ids [Array<Integer>]
    def create_sound_occurrence_mapping_table(sound_ids)
      conn = ActiveRecord::Base.connection

      conn.execute("DROP TABLE IF EXISTS temp_sound_occurrence_map")
      conn.execute(<<~SQL)
        CREATE TEMP TABLE temp_sound_occurrence_map (
          sound_id integer,
          occurrence_id text,
          occurrence_object_type text,
          occurrence_object_id integer,
          conveyance_id integer,
          sound_name text,
          PRIMARY KEY (sound_id, occurrence_id, conveyance_id)
        )
      SQL

      conn.execute(<<~SQL)
        INSERT INTO temp_sound_occurrence_map (sound_id, occurrence_id, occurrence_object_type, occurrence_object_id, conveyance_id, sound_name)
        SELECT DISTINCT
          snd.id AS sound_id,
          dwc."occurrenceID" AS occurrence_id,
          dwc.dwc_occurrence_object_type AS occurrence_object_type,
          dwc.dwc_occurrence_object_id AS occurrence_object_id,
          conv.id AS conveyance_id,
          snd.name AS sound_name
        FROM sounds snd
        INNER JOIN temp_media_sound_links links ON links.sound_id = snd.id
        #{sound_occurrence_resolution_joins_sql(sound_alias: 'snd')}
        WHERE dwc."occurrenceID" IS NOT NULL
      SQL

      conn.execute("CREATE INDEX idx_temp_snd_occ_map ON temp_sound_occurrence_map(sound_id)")
      Rails.logger.debug 'dwca_export: sound occurrence mapping table created'
    end

    # @return [Hash] { image_ids: Array<Integer>, sound_ids: Array<Integer> }
    def collect_media_ids
      image_ids = collect_media_image_ids
      sound_ids = collect_media_sound_ids

      Rails.logger.debug "dwca_export: found #{image_ids.count} images and #{sound_ids.count} sounds to export"

      { image_ids:, sound_ids: }
    end

    def collect_media_image_ids
      collect_media_ids_for_class(
        media_class: Image,
        join_table: 'depictions',
        media_id_column: 'image_id',
        include_observations: true
      )
    end

    def collect_media_sound_ids
      collect_media_ids_for_class(
        media_class: Sound,
        join_table: 'conveyances',
        media_id_column: 'sound_id',
        include_observations: false
      )
    end

    # Unified method to collect media IDs for any media class (Image or Sound).
    # @param media_class [Class] Image or Sound
    # @param join_table [String] 'depictions' or 'conveyances'
    # @param media_id_column [String] 'image_id' or 'sound_id'
    # @param include_observations [Boolean] whether to include observation-linked media
    # @return [Array<Integer>] unique media IDs
    def collect_media_ids_for_class(media_class:, join_table:, media_id_column:, include_observations: false)
      conn = ActiveRecord::Base.connection
      media_ids = []
      media_table = media_class.table_name

      if @media_extension[:collection_objects]
        co_sql = @media_extension[:collection_objects]

        media_ids += conn.execute(<<-SQL).values.flatten
          SELECT DISTINCT #{media_table}.id
          FROM (#{co_sql}) AS co
          INNER JOIN #{join_table} ON #{join_table}.#{join_table.singularize}_object_id = co.id
            AND #{join_table}.#{join_table.singularize}_object_type = 'CollectionObject'
          INNER JOIN #{media_table} ON #{media_table}.id = #{join_table}.#{media_id_column}
        SQL

        # Get media via observations (only for depictions/images).
        # TODO: Sounds not included because there's an association conflict
        # currently preventing it.
        if include_observations
          media_ids += conn.execute(<<-SQL).values.flatten
            SELECT DISTINCT #{media_table}.id
            FROM (#{co_sql}) AS co
            INNER JOIN observations obs ON obs.observation_object_id = co.id
              AND obs.observation_object_type = 'CollectionObject'
            INNER JOIN #{join_table} ON #{join_table}.#{join_table.singularize}_object_id = obs.id
              AND #{join_table}.#{join_table.singularize}_object_type = 'Observation'
            INNER JOIN #{media_table} ON #{media_table}.id = #{join_table}.#{media_id_column}
          SQL
        end
      end

      if @media_extension[:field_occurrences]
        fo_sql = @media_extension[:field_occurrences]

        media_ids += conn.execute(<<-SQL).values.flatten
          SELECT DISTINCT #{media_table}.id
          FROM (#{fo_sql}) AS fo
          INNER JOIN #{join_table} ON #{join_table}.#{join_table.singularize}_object_id = fo.id
            AND #{join_table}.#{join_table.singularize}_object_type = 'FieldOccurrence'
          INNER JOIN #{media_table} ON #{media_table}.id = #{join_table}.#{media_id_column}
        SQL

        # Get media via observations (only for depictions/images).
        # TODO: Sounds not included because there's an association conflict
        # currently preventing it.
        if include_observations
          media_ids += conn.execute(<<-SQL).values.flatten
            SELECT DISTINCT #{media_table}.id
            FROM (#{fo_sql}) AS fo
            INNER JOIN observations obs ON obs.observation_object_id = fo.id
              AND obs.observation_object_type = 'FieldOccurrence'
            INNER JOIN #{join_table} ON #{join_table}.#{join_table.singularize}_object_id = obs.id
              AND #{join_table}.#{join_table.singularize}_object_type = 'Observation'
            INNER JOIN #{media_table} ON #{media_table}.id = #{join_table}.#{media_id_column}
          SQL
        end
      end

      media_ids.uniq
    end

    def create_image_temp_tables
      # Create temp table with image IDs to avoid massive IN clauses (128k+ IDs).
      Rails.logger.debug 'dwca_export: creating temp tables for API image links'

      conn = ActiveRecord::Base.connection

      conn.execute("DROP TABLE IF EXISTS temp_media_image_links")
      conn.execute(<<-SQL)
        CREATE TEMP TABLE temp_media_image_links (
          image_id integer PRIMARY KEY,
          access_uri text,
          further_information_url text
        )
      SQL

      # Only needed to create temp_media_image_links:
      conn.execute("DROP TABLE IF EXISTS temp_media_image_ids")
      conn.execute("CREATE TEMP TABLE temp_media_image_ids (image_id integer PRIMARY KEY)")
    end

    def create_sound_temp_tables
      Rails.logger.debug 'dwca_export: creating temp table for API sound IDs'

      conn = ActiveRecord::Base.connection

      conn.execute("DROP TABLE IF EXISTS temp_media_sound_links")
      conn.execute(<<~SQL)
        CREATE TEMP TABLE temp_media_sound_links (
          sound_id integer PRIMARY KEY,
          access_uri text,
          further_information_url text
        )
      SQL

      conn.execute("DROP TABLE IF EXISTS temp_media_sound_ids")
      conn.execute("CREATE TEMP TABLE temp_media_sound_ids (sound_id integer PRIMARY KEY)")
    end

    # Create temporary tables with pre-computed API links for images and sounds.
    # This must use Ruby because API link generation uses the URL shortener.
    # @param image_ids [Array<Integer>]
    # @param sound_ids [Array<Integer>]
    def create_media_api_link_tables(image_ids, sound_ids)
      populate_temp_image_api_links_table(image_ids)
      populate_temp_sound_api_links_table(sound_ids)
    end

    def populate_temp_image_api_links_table(image_ids)
      return if image_ids.empty?

      create_image_temp_tables
      create_image_url_functions # (needed for specs)

      # Populate temp_media_image_ids.
      raw = ActiveRecord::Base.connection.raw_connection
      raw.copy_data("COPY temp_media_image_ids (image_id) FROM STDIN") do
        image_ids.each do |id|
          raw.put_copy_data("#{id}\n")
        end
      end

      populate_temp_image_links_table
    end

    def populate_temp_image_links_table
      conn = ActiveRecord::Base.connection

      regular_url_sql = "pg_temp.image_file_url(images.image_file_fingerprint, projects.api_access_token)"
      sled_url_sql = "pg_temp.sled_image_file_url(images.image_file_fingerprint, dep.svg_view_box, projects.api_access_token)"
      metadata_url_sql = "pg_temp.image_metadata_url(images.id, projects.api_access_token)"

      # Relation includes short urls when they exist.
      # !! Note this joins directly to the shortener gem's shortened_urls table
      # so that we can collect this data in sql instead of having to do it one
      # at a time via the gem in ruby.
      image_relation = Image
        .joins("JOIN temp_media_image_ids tmp ON tmp.image_id = images.id")
        .joins(:project)
        .joins("LEFT JOIN depictions dep ON dep.image_id = images.id")
        .joins(<<~SQL)
          LEFT JOIN shortened_urls su_access
            ON su_access.url = CASE
              WHEN dep.sled_image_id IS NOT NULL THEN #{sled_url_sql}
              ELSE #{regular_url_sql}
            END
        SQL
        .joins(<<~SQL)
          LEFT JOIN shortened_urls su_metadata
            ON su_metadata.url = #{metadata_url_sql}
        SQL
        .where.not(projects: { api_access_token: nil })
        .select(
          'images.id AS image_id',
          'images.image_file_fingerprint',
          'projects.api_access_token AS token',
          'su_access.unique_key AS access_short_key',
          'su_metadata.unique_key AS metadata_short_key',
          'dep.id AS depiction_id',
          'dep.sled_image_id',
          'dep.svg_view_box'
        )

      image_relation.in_batches(of: 50_000) do |batch_scope|
        rows = conn.select_all(batch_scope.to_sql)

        # Collect all URLs that need shortening.
        urls_to_shorten = []
        rows.each do |row|
          fingerprint = row['image_file_fingerprint']
          token = row['token']
          image_id = row['image_id'].to_i
          is_sled = row['sled_image_id'].present?
          svg_view_box = row['svg_view_box']

          unless row['access_short_key']
            long_url = if is_sled
              Shared::Api.sled_image_file_long_url(fingerprint, svg_view_box, token)
            else
              Shared::Api.image_file_long_url(fingerprint, token)
            end

            urls_to_shorten << {
              long_url: long_url,
              context: {
                image_id: image_id,
                depiction_id: row['depiction_id']&.to_i,
                type: :access,
                is_sled: is_sled
              }
            }
          end

          unless row['metadata_short_key']
            urls_to_shorten << {
              long_url: Shared::Api.image_metadata_long_url(image_id, token),
              context: { image_id: image_id, type: :metadata }
            }
          end
        end

        short_url_map = bulk_create_short_urls(urls_to_shorten)

        image_links_data = []
        sled_access_updates = []

        rows.each do |row|
          begin
            image_id = row['image_id'].to_i
            fingerprint = row['image_file_fingerprint']
            token = row['token']
            is_sled = row['sled_image_id'].present?
            depiction_id = row['depiction_id']&.to_i
            svg_view_box = row['svg_view_box']

            metadata_long_url = Shared::Api.image_metadata_long_url(image_id, token)
            further_info_url =
              if row['metadata_short_key']
                Shared::Api.short_url_from_key(row['metadata_short_key'])
              else
                short_url_map[metadata_long_url]
              end

            if is_sled
              sled_long_url = Shared::Api.sled_image_file_long_url(fingerprint, svg_view_box, token)
              access_uri =
                if row['access_short_key']
                  Shared::Api.short_url_from_key(row['access_short_key'])
                else
                  short_url_map[sled_long_url]
                end

              sled_access_updates << {
                depiction_id: depiction_id,
                access_uri: access_uri
              }

              image_links_data << {
                image_id: image_id,
                access_uri: nil, # Sled images get access_uri from temp_image_occurrence_map
                further_information_url: further_info_url
              }
            else
              access_long_url = Shared::Api.image_file_long_url(fingerprint, token)
              access_uri =
                if row['access_short_key']
                  Shared::Api.short_url_from_key(row['access_short_key'])
                else
                  short_url_map[access_long_url]
                end

              image_links_data << {
                image_id: image_id,
                access_uri: access_uri,
                further_information_url: further_info_url
              }
            end
          rescue => e
            Rails.logger.warn "dwca_export: skipping image #{row['image_id']} - #{e.message}"
          end
        end

        # Write to temp_media_image_links (deduplicate by image_id for regular
        # images).
        unless image_links_data.empty?
          unique_links = image_links_data.reverse.uniq { |l| l[:image_id] }.reverse

          raw = conn.raw_connection
          raw.copy_data("COPY temp_media_image_links (image_id, access_uri, further_information_url) FROM STDIN") do
            unique_links.each do |ldata|
              access = ldata[:access_uri] || ''
              raw.put_copy_data("#{ldata[:image_id]}\t#{access}\t#{ldata[:further_information_url]}\n")
            end
          end
        end

        # Store sled access URIs for later (after temp_image_occurrence_map is
        # created).
        unless sled_access_updates.empty?
          @sled_access_updates ||= []
          @sled_access_updates.concat(sled_access_updates)
        end
      end

      Rails.logger.debug 'dwca_export: temp table created with API image links'
    end

    # Populates access_uri column in temp_image_occurrence_map for sled images.
    # This runs AFTER temp_image_occurrence_map is created.
    def populate_sled_image_access_uris
      return if @sled_access_updates.nil? || @sled_access_updates.empty?

      conn = ActiveRecord::Base.connection

      Rails.logger.debug "dwca_export: populating #{@sled_access_updates.size} sled image access URIs"

      # Batch update using temp table
      conn.execute("DROP TABLE IF EXISTS temp_sled_uri_updates")
      conn.execute("CREATE TEMP TABLE temp_sled_uri_updates (depiction_id integer, access_uri text)")

      raw = conn.raw_connection
      raw.copy_data("COPY temp_sled_uri_updates (depiction_id, access_uri) FROM STDIN") do
        @sled_access_updates.each do |upd|
          raw.put_copy_data("#{upd[:depiction_id]}\t#{upd[:access_uri]}\n")
        end
      end

      conn.execute(<<~SQL)
        UPDATE temp_image_occurrence_map
        SET access_uri = upd.access_uri
        FROM temp_sled_uri_updates upd
        WHERE temp_image_occurrence_map.depiction_id = upd.depiction_id
      SQL

      conn.execute("DROP TABLE temp_sled_uri_updates")

      Rails.logger.debug "dwca_export: populated #{@sled_access_updates.size} sled image access URIs"

      @sled_access_updates = nil
    end

    def populate_temp_sound_api_links_table(sound_ids)
      return if sound_ids.empty?

      create_sound_temp_tables

      conn = ActiveRecord::Base.connection

      raw = conn.raw_connection
      raw.copy_data("COPY temp_media_sound_ids (sound_id) FROM STDIN") do
        sound_ids.each do |id|
          raw.put_copy_data("#{id}\n")
        end
      end

      # Build a relation using the temp IDs, so we don't end up with a massive
      # IN ().
      Sound
          .joins("JOIN temp_media_sound_ids tmp ON tmp.sound_id = sounds.id")
          .includes(:sound_file_attachment, :project)
          .in_batches(of: 10_000) do |batch_scope|
        batch_sounds = batch_scope.to_a
        links_data   = []

        batch_sounds.each do |snd|
          begin
            token = snd.project&.api_access_token
            if token.nil?
              Rails.logger.warn "dwca_export: skipping sound #{snd.id} - no project token"
              next
            end

            # Must use full AR objects for these helpers.
            access_uri = Shared::Api.sound_link(snd)
            further_info_url = Shared::Api.sound_metadata_link(
              snd,
              raise_on_no_token: true,
              token:
            )

            links_data << {
              sound_id: snd.id,
              access_uri: access_uri,
              further_information_url: further_info_url
            }
          rescue => e
            Rails.logger.warn "dwca_export: skipping sound #{snd.id} - #{e.message}"
          end
        end

        next if links_data.empty?

        raw = conn.raw_connection
        raw.copy_data("COPY temp_media_sound_links (sound_id, access_uri, further_information_url) FROM STDIN") do
          links_data.each do |row|
            raw.put_copy_data("#{row[:sound_id]}\t#{row[:access_uri]}\t#{row[:further_information_url]}\n")
          end
        end
      end

      Rails.logger.debug 'dwca_export: temp table created with API sound links'
    end

    # Exports image media records to the output file using COPY TO.
    def export_images_to_file(image_ids, output_file)
      return if image_ids.empty?

      conn = ActiveRecord::Base.connection
      copyright_label = copyright_label_from_temp_sql('attr')

      image_copy_sql = <<-SQL
        COPY (
          SELECT
            pg_temp.sanitize_csv(occ_map.occurrence_id) AS coreid,
            #{media_identifier_sql(Image, 'img')} AS identifier,
            'Image' AS \"dc:type\",
            img.id AS \"providerManagedID\",
            pg_temp.sanitize_csv(attr.license_url) AS \"dc:rights\",
            pg_temp.sanitize_csv(attr.license_url) AS \"dcterms:rights\",
            pg_temp.sanitize_csv(attr.owner_names) AS \"Owner\",
            pg_temp.sanitize_csv(#{copyright_label}) AS \"Credit\",
            pg_temp.sanitize_csv(attr.creator_names) AS \"dc:creator\",
            pg_temp.sanitize_csv(attr.creator_identifiers) AS \"dcterms:creator\",
            pg_temp.sanitize_csv(occ_map.figure_label) AS description,
            pg_temp.sanitize_csv(occ_map.caption) AS caption,
            -- Compute associatedSpecimenReference as API URL
            pg_temp.api_link_for_model_id(occ_map.occurrence_object_type, occ_map.occurrence_object_id) AS \"associatedSpecimenReference\",
            -- For sled images, use cropped access_uri from occ_map; otherwise use full image from links
            COALESCE(occ_map.access_uri, links.access_uri) AS \"accessURI\",
            img.image_file_content_type AS \"dc:format\",
            links.further_information_url AS \"furtherInformationURL\",
            img.width AS \"PixelXDimension\",
            img.height AS \"PixelYDimension\"
          FROM images img

          -- Join pre-computed occurrence mapping (replaces complex 14-join logic)
          INNER JOIN temp_image_occurrence_map occ_map ON occ_map.image_id = img.id

          -- Join temp table for API links
          INNER JOIN temp_media_image_links links ON links.image_id = img.id

          -- Join pre-computed attribution data from temp table
          LEFT JOIN temp_image_attributions attr ON attr.image_id = img.id

          -- Join identifiers for UUID and URI
          #{media_identifier_joins_sql(Image, 'img')}

          ORDER BY img.id, occ_map.occurrence_id
        ) TO STDOUT WITH (FORMAT CSV, DELIMITER E'\\t', NULL '')
      SQL

      conn.raw_connection.copy_data(image_copy_sql) do
        while row = conn.raw_connection.get_copy_data
          output_file.write(row.force_encoding(Encoding::UTF_8))
        end
      end
    end

    # Exports sound media records to the output file using PostgreSQL COPY TO
    # Streams data directly to avoid loading entire dataset into memory
    def export_sounds_to_file(sound_ids, output_file)
      return if sound_ids.empty?

      conn = ActiveRecord::Base.connection
      copyright_label = copyright_label_from_temp_sql('attr')

      sound_copy_sql = <<-SQL
        COPY (
          SELECT
            pg_temp.sanitize_csv(occ_map.occurrence_id) AS coreid,
            #{media_identifier_sql(Sound, 'snd')} AS identifier,
            'Sound' AS \"dc:type\",
            snd.id AS \"providerManagedID\",
            pg_temp.sanitize_csv(attr.license_url) AS \"dc:rights\",
            pg_temp.sanitize_csv(attr.license_url) AS \"dcterms:rights\",
            pg_temp.sanitize_csv(attr.owner_names) AS \"Owner\",
            pg_temp.sanitize_csv(#{copyright_label}) AS \"Credit\",
            pg_temp.sanitize_csv(attr.creator_names) AS \"dc:creator\",
            pg_temp.sanitize_csv(attr.creator_identifiers) AS \"dcterms:creator\",
            pg_temp.sanitize_csv(occ_map.sound_name) AS description,
            NULL AS caption,
            -- Compute associatedSpecimenReference from occurrence_id
            pg_temp.sanitize_csv(occ_map.occurrence_id) AS \"associatedSpecimenReference\",
            links.access_uri AS \"accessURI\",
            asb.content_type AS \"dc:format\",
            links.further_information_url AS \"furtherInformationURL\",
            NULL AS \"PixelXDimension\",
            NULL AS \"PixelYDimension\"
          FROM sounds snd
          LEFT JOIN active_storage_attachments asa ON asa.record_id = snd.id
                                                    AND asa.record_type = 'Sound'
                                                    AND asa.name = 'sound_file'
          LEFT JOIN active_storage_blobs asb ON asb.id = asa.blob_id

          -- Join pre-computed occurrence mapping (replaces complex 6-join logic)
          INNER JOIN temp_sound_occurrence_map occ_map ON occ_map.sound_id = snd.id

          -- Join temp table for API links
          INNER JOIN temp_media_sound_links links ON links.sound_id = snd.id

          -- Join pre-computed attribution data from temp table
          LEFT JOIN temp_sound_attributions attr ON attr.sound_id = snd.id

          -- Join identifiers for UUID and URI
          #{media_identifier_joins_sql(Sound, 'snd')}

          ORDER BY snd.id, occ_map.occurrence_id
        ) TO STDOUT WITH (FORMAT CSV, DELIMITER E'\\t', NULL '')
      SQL

      conn.raw_connection.copy_data(sound_copy_sql) do
        while row = conn.raw_connection.get_copy_data
          output_file.write(row.force_encoding(Encoding::UTF_8))
        end
      end
    end

    # Creates temporary tables with pre-aggregated attribution data for images
    # and sounds.
    # Pre-computes attribution data using LATERAL joins once per media record.
    # Without this, the main export query would execute these expensive LATERAL
    # joins for every row; with it, the export query only needs a simple JOIN
    # to retrieve pre-computed values.
    def create_media_attribution_temp_tables(image_ids, sound_ids)
      create_media_attribution_temp_table_for_class(
        media_class: Image,
        media_ids: image_ids,
        table_alias: 'img',
        temp_table_name: 'temp_image_attributions',
        id_column_name: 'image_id',
        temp_ids_table: 'temp_media_image_ids',
        index_name: 'idx_temp_image_attr'
      )

      create_media_attribution_temp_table_for_class(
        media_class: Sound,
        media_ids: sound_ids,
        table_alias: 'snd',
        temp_table_name: 'temp_sound_attributions',
        id_column_name: 'sound_id',
        temp_ids_table: 'temp_media_sound_ids',
        index_name: 'idx_temp_sound_attr'
      )
    end

    # Helper to create attribution temp table for a specific media class.
    # @param media_class [Class] Image or Sound
    # @param media_ids [Array<Integer>] IDs of media to process
    # @param table_alias [String] SQL alias for the media table
    # @param temp_table_name [String] Name of the temp table to create
    # @param id_column_name [String] Name of the ID column (e.g., 'image_id')
    # @param temp_ids_table [String] Name of the temp IDs table to join against
    # @param index_name [String] Name of the index to create
    def create_media_attribution_temp_table_for_class(media_class:, media_ids:, table_alias:, temp_table_name:, id_column_name:, temp_ids_table:, index_name:)
      return if media_ids.empty?

      conn = ActiveRecord::Base.connection
      media_table = media_class.table_name

      # Get the license SQL that converts license keys to URLs.
      license_sql = media_class.dwc_media_license_sql

      conn.execute("DROP TABLE IF EXISTS #{temp_table_name}")
      conn.execute(<<~SQL)
        CREATE TEMP TABLE #{temp_table_name} AS
        SELECT
          #{table_alias}.id AS #{id_column_name},
          #{license_sql} AS license_url,
          attributions.copyright_year,
          owners.names AS owner_names,
          creators.names AS creator_names,
          creator_ids.ids AS creator_identifiers,
          copyright_holders.names_array AS copyright_holder_names_array
        FROM #{media_table} #{table_alias}
        LEFT JOIN attributions ON attributions.attribution_object_id = #{table_alias}.id
          AND attributions.attribution_object_type = '#{media_class.name}'
        #{media_class.dwc_media_owner_sql}
        #{media_class.dwc_media_creator_sql}
        #{media_class.dwc_media_creator_identifiers_sql}
        #{media_class.dwc_media_copyright_holders_sql}
        JOIN #{temp_ids_table} ids ON ids.#{id_column_name} = #{table_alias}.id
      SQL
      conn.execute("CREATE INDEX #{index_name} ON #{temp_table_name}(#{id_column_name})")
    end

    # Cleans up remaining temporary tables after media export completes.
    # Note: temp_scoped_occurrences, temp_media_image_ids, and
    # temp_media_sound_ids are dropped earlier as soon as they're no longer
    # needed to reduce memory usage.
    def cleanup_media_temp_tables
      conn = ActiveRecord::Base.connection
      conn.execute("DROP TABLE IF EXISTS temp_image_occurrence_map")
      conn.execute("DROP TABLE IF EXISTS temp_sound_occurrence_map")
      conn.execute("DROP TABLE IF EXISTS temp_media_image_links")
      conn.execute("DROP TABLE IF EXISTS temp_media_sound_links")
      conn.execute("DROP TABLE IF EXISTS temp_image_attributions")
      conn.execute("DROP TABLE IF EXISTS temp_sound_attributions")
    end

    # Media extension export using PostgreSQL COPY TO. Streams directly to
    # output_file to avoid loading entire dataset into memory, ~10x faster than
    # the original Ruby iteration approach.
    def media_extension_to_file(output_file)
      Rails.logger.debug 'dwca_export: media_extension_optimized start'

      create_csv_sanitize_function
      create_authorship_sentence_function
      create_api_link_for_model_id_function
      create_image_url_functions

      # Step 1: Collect all media IDs from collection objects and field
      # occurrences.
      media_ids = collect_media_ids
      image_ids = media_ids[:image_ids]
      sound_ids = media_ids[:sound_ids]

      # Early return if no media to export
      if image_ids.empty? && sound_ids.empty?
        output_file.write(Export::CSV::Dwc::Extension::Occurrence::Media::HEADERS.join("\t") + "\n")
        return
      end

      # Step 2: Create temp tables with media IDs and pre-compute API links
      # using Ruby (required for URL shortener).
      create_media_api_link_tables(image_ids, sound_ids)

      # Step 3: Create temp table with scoped occurrence IDs. Used in step 4 to
      # filter media records - only includes media linked to collection
      # objects/field occurrences that are in the core export scope.
      create_scoped_occurrence_temp_table

      # Step 4: Pre-compute media-to-occurrence mappings. This runs the complex
      # 14-join logic once instead of executing it in the streaming COPY query.
      # Depends on temp_media_image_links (step 2) and temp_scoped_occurrences
      # (step 3).
      create_media_occurrence_mapping_tables(image_ids, sound_ids)

      # Step 4a: Populate sled image access URIs. This must run AFTER
      # temp_image_occurrence_map is created.
      populate_sled_image_access_uris

      # Drop temp_scoped_occurrences - no longer needed after occurrence mapping.
      conn = ActiveRecord::Base.connection
      conn.execute("DROP TABLE IF EXISTS temp_scoped_occurrences")

      # Step 5: Pre-compute attribution data to avoid expensive LATERAL joins.
      # Uses temp_media_image_ids and temp_media_sound_ids tables created in
      # step 3.
      create_media_attribution_temp_tables(image_ids, sound_ids)

      # Drop temp_media_*_ids tables - no longer needed after attribution.
      conn.execute("DROP TABLE IF EXISTS temp_media_image_ids")
      conn.execute("DROP TABLE IF EXISTS temp_media_sound_ids")

      # Step 6: Write header and stream media data to output file.
      Rails.logger.debug 'dwca_export: executing COPY TO for media data'
      output_file.write(Export::CSV::Dwc::Extension::Occurrence::Media::HEADERS.join("\t") + "\n")

      export_images_to_file(image_ids, output_file)
      export_sounds_to_file(sound_ids, output_file)

      # Step 7: Cleanup temp tables. PostgreSQL temp tables persist for the
      # lifetime of the database connection/session. Rails connection pooling
      # reuses connections across requests/jobs without calling DISCARD ALL, so
      # temp tables created in one export would still exist when the same
      # connection runs another export, causing "relation already exists"
      # errors.
      cleanup_media_temp_tables

      Rails.logger.debug 'dwca_export: media data generated'
    ensure
      output_file.flush
      output_file.rewind
    end

  end
end
