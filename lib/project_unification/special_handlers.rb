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

    # Handler for ControlledVocabularyTerm with rename-on-conflict and merge registry.
    #
    # When a source CVT conflicts on name/definition/uri with a target CVT, and the
    # two are semantically equivalent, the source is renamed with a sentinel suffix
    # so it can be saved, then registered for Phase 2 collapse via Shared::Unify.
    # The sentinel is deliberately conspicuous — if Phase 2 cleanup ever fails the
    # user can find orphaned records by searching "UNIFICATION TO PROJECT".
    class ControlledVocabularyTermHandler
      attr_reader :source_project_id, :target_project_id

      SENTINEL_PREFIX = 'UNIFICATION TO PROJECT'

      def initialize(source_project_id, target_project_id, options = {})
        @source_project_id = source_project_id
        @target_project_id = target_project_id
      end

      def migrate
        stats = { track: :special, model: 'ControlledVocabularyTerm', migrated: 0,
                  conflicts: [], errors: [], merge_registry: [] }
        sentinel = "#{SENTINEL_PREFIX} #{target_project_id}"

        records = ControlledVocabularyTerm.where(project_id: source_project_id)
        return stats unless records.exists?

        records.find_each do |record|
          record.no_cached = true if record.respond_to?(:no_cached=)
          record.project_id = target_project_id

          if record.valid?
            record.save!
            stats[:migrated] += 1
          elsif uniqueness_error?(record)
            target_cvts  = find_conflicting_target_cvts(record)
            unique_targets = target_cvts.values.uniq(&:id)
            sole_target  = unique_targets.first if unique_targets.one?

            if sole_target && sole_target.type == record.type && cvts_semantically_equivalent?(record, sole_target)
              record.errors.details.each do |field, errors|
                next unless errors.any? { |e| e[:error] == :taken }
                case field
                when :name       then record.name       = unique_cvt_name(record.name, record.type, sentinel)
                when :definition then record.definition  = unique_cvt_definition(record.definition, sentinel)
                when :uri        then record.uri         = unique_cvt_uri(record.uri, record.uri_relation, sentinel)
                end
              end

              record.save!
              stats[:migrated] += 1
              stats[:merge_registry] << { model: record.class.name, renamed_id: record.id, target_id: sole_target.id }
            else
              primary_target = sole_target || unique_targets.first
              stats[:conflicts] << {
                id: record.id,
                model: 'ControlledVocabularyTerm',
                conflict_fields: conflict_fields(record),
                errors: record.errors.full_messages,
                source_cvt: {
                  project_id: source_project_id,
                  cvt_type: record.type,
                  name: record.name,
                  definition: record.definition,
                  uri: record.uri,
                  uri_relation: record.uri_relation
                },
                target_cvt: primary_target && {
                  id: primary_target.id,
                  project_id: target_project_id,
                  cvt_type: primary_target.type,
                  name: primary_target.name,
                  definition: primary_target.definition,
                  uri: primary_target.uri,
                  uri_relation: primary_target.uri_relation
                },
                target_cvts: target_cvts.transform_values { |cvt|
                  { id: cvt.id, project_id: target_project_id, cvt_type: cvt.type,
                    name: cvt.name, definition: cvt.definition, uri: cvt.uri, uri_relation: cvt.uri_relation }
                }
              }
            end
          else
            stats[:errors] << { id: record.id, model: 'ControlledVocabularyTerm',
                                error: record.errors.full_messages.join('; ') }
          end
        rescue => e
          stats[:errors] << { id: record.id, model: 'ControlledVocabularyTerm', error: e.message }
        end

        stats
      end

      private

      def uniqueness_error?(record)
        record.errors.details.values.flatten.any? { |e| e[:error] == :taken }
      end

      def conflict_fields(record)
        record.errors.details
          .select { |_, details| details.any? { |d| d[:error] == :taken } }
          .keys
      end

      def cvts_semantically_equivalent?(record, target_cvt)
        record.name == target_cvt.name &&
          record.definition == target_cvt.definition &&
          record.uri_relation == target_cvt.uri_relation &&
          (record.uri.blank? || record.uri == target_cvt.uri)
      end

      def find_conflicting_target_cvts(record)
        matches = {}

        name_match = ControlledVocabularyTerm.find_by(
          type: record.type, name: record.name, project_id: target_project_id
        )
        matches[:name] = name_match if name_match

        if record.definition.present?
          definition_match = ControlledVocabularyTerm.find_by(
            definition: record.definition, project_id: target_project_id
          )
          matches[:definition] = definition_match if definition_match
        end

        if record.uri.present?
          uri_match = ControlledVocabularyTerm.find_by(
            uri: record.uri, uri_relation: record.uri_relation, project_id: target_project_id
          )
          matches[:uri] = uri_match if uri_match
        end

        matches
      end

      def unique_cvt_name(original_name, cvt_type, sentinel)
        candidate = "#{original_name} [#{sentinel}]"
        counter = 2
        while ControlledVocabularyTerm.exists?(type: cvt_type, name: candidate, project_id: target_project_id)
          candidate = "#{original_name} [#{sentinel} #{counter}]"
          counter += 1
        end
        candidate
      end

      def unique_cvt_definition(original_definition, sentinel)
        candidate = "#{original_definition} [#{sentinel}]"
        counter = 2
        while ControlledVocabularyTerm.exists?(definition: candidate, project_id: target_project_id)
          candidate = "#{original_definition} [#{sentinel} #{counter}]"
          counter += 1
        end
        candidate
      end

      def unique_cvt_uri(original_uri, uri_relation, sentinel)
        no_space_sentinel = sentinel.tr(' ', '-')
        candidate = "#{original_uri}/#{no_space_sentinel}"
        counter = 2
        while ControlledVocabularyTerm.exists?(uri: candidate, uri_relation: uri_relation, project_id: target_project_id)
          candidate = "#{original_uri}/#{no_space_sentinel}-#{counter}"
          counter += 1
        end
        candidate
      end
    end
  end
end
