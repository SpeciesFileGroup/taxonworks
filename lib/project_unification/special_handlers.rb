# Special handlers for models that need custom migration logic
#
# These handlers provide optimized or specialized migration strategies
# for specific models that don't fit the standard validation-based approach.
#
module ProjectUnification
  module SpecialHandlers
    # Handler for cached_* tables - no validation needed, just SQL update
    class CachedTablesHandler
      attr_reader :source_project_id, :target_project_id, :table_name

      def initialize(source_project_id, target_project_id, table_name)
        @source_project_id = source_project_id
        @target_project_id = target_project_id
        @table_name = table_name
      end

      def migrate
        count = count_records

        if count > 0
          sql = ActiveRecord::Base.sanitize_sql_array([
            "UPDATE #{table_name} SET project_id = ? WHERE project_id = ?",
            target_project_id,
            source_project_id
          ])

          ActiveRecord::Base.connection.execute(sql)
        end

        {
          track: :cached,
          migrated: count,
          method: :direct_sql,
          errors: []
        }
      rescue => e
        {
          track: :cached,
          migrated: 0,
          method: :direct_sql,
          errors: [{
            error: e.message,
            backtrace: e.backtrace.first(3)
          }]
        }
      end

      private

      def count_records
        sql = ActiveRecord::Base.sanitize_sql_array([
          "SELECT COUNT(*) FROM #{table_name} WHERE project_id = ?",
          source_project_id
        ])

        ActiveRecord::Base.connection.select_value(sql).to_i
      end
    end

    # Handler for CollectingEvent with verbatim_label duplicate detection
    class CollectingEventHandler
      attr_reader :source_project_id, :target_project_id

      def initialize(source_project_id, target_project_id, options = {})
        @source_project_id = source_project_id
        @target_project_id = target_project_id
      end

      def migrate
        duplicates = detect_verbatim_label_duplicates

        result = {
          track: :special,
          model: 'CollectingEvent',
          migrated: 0,
          method: duplicates.any? ? :validation : :direct_sql,
          verbatim_label_duplicates: duplicates,
          errors: []
        }

        if duplicates.empty?
          # No duplicates - use fast SQL update
          result[:migrated] = migrate_with_sql
        else
          # Has duplicates - fall back to validation-based migration
          result[:migrated] = migrate_with_validation
          result[:note] = "#{duplicates.size} verbatim_label duplicates found, using validation"
        end

        result
      rescue => e
        {
          track: :special,
          model: 'CollectingEvent',
          migrated: 0,
          errors: [{
            error: e.message,
            backtrace: e.backtrace.first(3)
          }]
        }
      end

      private

      def detect_verbatim_label_duplicates
        # Find verbatim_labels that exist in both source and target projects
        sql = <<-SQL
          SELECT s.verbatim_label, COUNT(*) as count
          FROM collecting_events s
          INNER JOIN collecting_events t
            ON s.verbatim_label = t.verbatim_label
            AND s.verbatim_label IS NOT NULL
          WHERE s.project_id = #{source_project_id}
            AND t.project_id = #{target_project_id}
          GROUP BY s.verbatim_label
          HAVING COUNT(*) > 0
        SQL

        ActiveRecord::Base.connection.exec_query(sql).to_a
      end

      def migrate_with_sql
        count = CollectingEvent.where(project_id: source_project_id).count
        return 0 if count == 0

        sql = ActiveRecord::Base.sanitize_sql_array([
          "UPDATE collecting_events SET project_id = ? WHERE project_id = ?",
          target_project_id,
          source_project_id
        ])

        result = ActiveRecord::Base.connection.execute(sql)
        result.cmd_tuples || count
      end

      def migrate_with_validation
        count = 0
        errors = []

        CollectingEvent.where(project_id: source_project_id).find_each do |ce|
          ce.project_id = target_project_id
          if ce.save
            count += 1
          else
            errors << {
              id: ce.id,
              errors: ce.errors.full_messages
            }
          end
        end

        count
      end
    end

    # Handler for Image with fingerprint-based deduplication
    class ImageHandler
      attr_reader :source_project_id, :target_project_id

      def initialize(source_project_id, target_project_id, options = {})
        @source_project_id = source_project_id
        @target_project_id = target_project_id
      end

      def migrate
        result = {
          track: :special,
          model: 'Image',
          migrated: 0,
          destroyed: 0,
          duplicates_found: [],
          errors: []
        }

        # Find duplicates by fingerprint
        duplicates = find_duplicate_fingerprints

        # Destroy source images that have duplicates in target
        duplicates.each do |dup|
          source_image = Image.find_by(id: dup['source_id'])
          if source_image
            source_image.destroy
            result[:destroyed] += 1
            result[:duplicates_found] << {
              source_id: dup['source_id'],
              target_id: dup['target_id'],
              fingerprint: dup['image_file_fingerprint']
            }
          end
        end

        # Update remaining images with direct SQL (no validation)
        migrated_count = update_remaining_images
        result[:migrated] = migrated_count

        result
      rescue => e
        {
          track: :special,
          model: 'Image',
          migrated: 0,
          destroyed: 0,
          errors: [{
            error: e.message,
            backtrace: e.backtrace.first(3)
          }]
        }
      end

      private

      def find_duplicate_fingerprints
        # Find images in source that have same fingerprint as images in target
        sql = <<-SQL
          SELECT
            s.id as source_id,
            t.id as target_id,
            s.image_file_fingerprint
          FROM images s
          INNER JOIN images t
            ON s.image_file_fingerprint = t.image_file_fingerprint
            AND s.image_file_fingerprint IS NOT NULL
          WHERE s.project_id = #{source_project_id}
            AND t.project_id = #{target_project_id}
        SQL

        ActiveRecord::Base.connection.exec_query(sql).to_a
      end

      def update_remaining_images
        count = Image.where(project_id: source_project_id).count
        return 0 if count == 0

        sql = ActiveRecord::Base.sanitize_sql_array([
          "UPDATE images SET project_id = ? WHERE project_id = ?",
          target_project_id,
          source_project_id
        ])

        result = ActiveRecord::Base.connection.execute(sql)
        result.cmd_tuples || count
      end
    end
  end
end
