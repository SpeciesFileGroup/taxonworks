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
          result[:migrated] = migrate_with_sql
        else
          result[:note] = "#{duplicates.size} verbatim_label duplicates found, using validation"
          migrate_with_validation(result)
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

      def migrate_with_validation(result)
        CollectingEvent.where(project_id: source_project_id).find_each do |ce|
          ce.project_id = target_project_id
          if ce.save
            result[:migrated] += 1
          else
            result[:errors] << {
              id: ce.id,
              model: 'CollectingEvent',
              error: ce.errors.full_messages.join('; ')
            }
          end
        end
      end
    end

    # Handler for Image with fingerprint-based deduplication
    class ImageHandler
      include ProjectUnification::AnnotationRerouter

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

        # Re-route Depictions off source images before destroying them.
        # Image has dependent: :restrict_with_error, so destroy silently
        # fails if any Depictions remain — leaving a duplicate fingerprint
        # in the target project after the bulk SQL update that follows.
        duplicates.each do |dup|
          source_image = Image.find_by(id: dup['source_id'])
          next unless source_image

          reroute_depictions(source_image.id, dup['target_id'])
          reroute_annotations(source_image, dup['target_id'])

          if source_image.destroy
            result[:destroyed] += 1
            result[:duplicates_found] << {
              source_id: dup['source_id'],
              target_id: dup['target_id'],
              fingerprint: dup['image_file_fingerprint']
            }
          else
            result[:errors] << {
              model: 'Image',
              id: source_image.id,
              error: source_image.errors.full_messages.join('; ')
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

      # Re-point Depictions from source_image to target_image.
      # Depictions that would duplicate an existing (target_image, depiction_object)
      # pair are destroyed rather than re-pointed.
      def reroute_depictions(source_image_id, target_image_id)
        Depiction.where(image_id: source_image_id).find_each do |depiction|
          if Depiction.exists?(
            image_id: target_image_id,
            depiction_object_type: depiction.depiction_object_type,
            depiction_object_id: depiction.depiction_object_id
          )
            depiction.destroy
          else
            depiction.update_column(:image_id, target_image_id)
          end
        end
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

    # Handler for Document with fingerprint-based deduplication.
    # Mirrors ImageHandler: re-routes Documentation records off duplicate
    # source Documents before destroying them, preventing cross-project
    # document_id references after the fast-track Documentation bulk update.
    class DocumentHandler
      include ProjectUnification::AnnotationRerouter

      attr_reader :source_project_id, :target_project_id

      def initialize(source_project_id, target_project_id, options = {})
        @source_project_id = source_project_id
        @target_project_id = target_project_id
      end

      def migrate
        result = {
          track: :special,
          model: 'Document',
          migrated: 0,
          destroyed: 0,
          duplicates_found: [],
          errors: []
        }

        duplicate_pairs.each do |source_document, target_id|
          reroute_documentation(source_document.id, target_id)
          reroute_annotations(source_document, target_id)

          if source_document.destroy
            result[:destroyed] += 1
            result[:duplicates_found] << {
              source_id: source_document.id,
              target_id: target_id,
              fingerprint: source_document.document_file_fingerprint
            }
          else
            result[:errors] << {
              model: 'Document',
              id: source_document.id,
              error: source_document.errors.full_messages.join('; ')
            }
          end
        end

        result[:migrated] = Document.where(project_id: source_project_id)
                                    .update_all(project_id: target_project_id)
        result
      rescue => e
        {
          track: :special,
          model: 'Document',
          migrated: 0,
          destroyed: 0,
          errors: [{ error: e.message, backtrace: e.backtrace.first(3) }]
        }
      end

      private

      # Re-point all Documentation from source_document to target_document.
      # Documentation has no uniqueness constraint on (document_id, object),
      # so update_all is sufficient.
      def reroute_documentation(source_document_id, target_document_id)
        Documentation.where(document_id: source_document_id)
                     .update_all(document_id: target_document_id)
      end

      # Returns [[source_document, target_id], ...] for documents whose
      # fingerprint matches one in the target project. Excludes .prj/.cpg
      # files since fingerprint uniqueness is not enforced for those.
      def duplicate_pairs
        target_by_fingerprint = non_shapefile_documents(target_project_id)
                                  .pluck(:document_file_fingerprint, :id)
                                  .to_h

        non_shapefile_documents(source_project_id)
          .where(document_file_fingerprint: target_by_fingerprint.keys)
          .map { |doc| [doc, target_by_fingerprint[doc.document_file_fingerprint]] }
      end

      def non_shapefile_documents(project_id)
        Document.where(project_id: project_id)
                .where.not(document_file_fingerprint: nil)
                .where.not("document_file_file_name ILIKE '%.prj' OR document_file_file_name ILIKE '%.cpg'")
      end
    end
  end
end
