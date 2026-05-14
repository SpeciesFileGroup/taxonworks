# Special handlers for models that need custom migration logic
#
# These handlers provide optimized or specialized migration strategies
# for specific models that don't fit the standard validation-based approach.
#
module ProjectUnification
  module SpecialHandlers
    # Handler for cached_* tables - no validation needed, just bulk update.
    class CachedTablesHandler
      attr_reader :source_project_id, :target_project_id, :klass

      def initialize(source_project_id:, target_project_id:, klass:)
        @source_project_id = source_project_id
        @target_project_id = target_project_id
        @klass = klass
      end

      def migrate
        migrated = klass.where(project_id: source_project_id)
                        .update_all(project_id: target_project_id)

        {
          track: :cached,
          migrated: migrated,
          method: :direct_sql,
          errors: []
        }
      rescue => e
        {
          track: :cached,
          migrated: 0,
          method: :direct_sql,
          errors: [{ error: e.message, backtrace: e.backtrace.first(3) }]
        }
      end
    end

    # Handler for CollectingEvent with verbatim_label conflict detection.
    #
    # Unlike Image/Document/CVT, conflicting CEs cannot be automatically merged
    # — they may have different data beyond the verbatim_label. The conflict is
    # surfaced to the user (blocking the migration) so they can resolve it
    # manually (rename or merge the CEs) before retrying.
    class CollectingEventHandler
      attr_reader :source_project_id, :target_project_id

      def initialize(source_project_id:, target_project_id:, options: {})
        @source_project_id = source_project_id
        @target_project_id = target_project_id
      end

      def migrate
        duplicates = detect_verbatim_label_duplicates

        result = {
          track: :special,
          model: 'CollectingEvent',
          migrated: 0,
          conflicts: [],
          errors: []
        }

        if duplicates.any?
          duplicates.each do |label|
            result[:conflicts] << {
              model: 'CollectingEvent',
              conflict_fields: { verbatim_label: label },
              errors: ["verbatim_label '#{label}' already exists in the target project — resolve manually before retrying"]
            }
          end
          return result
        end

        result[:migrated] = migrate_with_sql
        result
      rescue => e
        {
          track: :special,
          model: 'CollectingEvent',
          migrated: 0,
          conflicts: [],
          errors: [{ error: e.message, backtrace: e.backtrace.first(3) }]
        }
      end

      private

      def detect_verbatim_label_duplicates
        CollectingEvent.where(project_id: source_project_id)
                       .where.not(verbatim_label: nil)
                       .where(verbatim_label: CollectingEvent.where(project_id: target_project_id).select(:verbatim_label))
                       .distinct
                       .pluck(:verbatim_label)
      end

      def migrate_with_sql
        CollectingEvent.where(project_id: source_project_id)
                       .update_all(project_id: target_project_id)
      end
    end

    # Handler for ProjectSource with duplicate detection.
    #
    # ProjectSource is a denormalized index of "sources cited in this project",
    # maintained automatically by Citation#after_create via find_or_create_by.
    # When a source_id already exists in the target project's project_sources,
    # the source record is redundant — delete it and bulk-update the rest.
    # delete_all bypasses the before_destroy :check_for_use callback (which would
    # block deletion while citations still reference the source in the source project).
    class ProjectSourceHandler
      attr_reader :source_project_id, :target_project_id

      def initialize(source_project_id:, target_project_id:, options: {})
        @source_project_id = source_project_id
        @target_project_id = target_project_id
      end

      def migrate
        conflict_ids = find_conflict_ids

        ProjectSource.where(id: conflict_ids).delete_all if conflict_ids.any?

        migrated = ProjectSource.where(project_id: source_project_id)
                                .update_all(project_id: target_project_id)

        {
          track: :special,
          model: 'ProjectSource',
          migrated: migrated,
          duplicates_deleted: conflict_ids.size,
          errors: []
        }
      rescue => e
        {
          track: :special,
          model: 'ProjectSource',
          migrated: 0,
          errors: [{ error: e.message, backtrace: e.backtrace.first(3) }]
        }
      end

      private

      def find_conflict_ids
        ProjectSource.where(project_id: source_project_id)
                     .where(source_id: ProjectSource.where(project_id: target_project_id).select(:source_id))
                     .pluck(:id)
      end
    end

    # Handler for RangedLotCategory with name-based duplicate detection.
    #
    # Phase 1 (migrate): source categories whose name collides with a target
    # category have their name replaced with a per-record sentinel string so the
    # bulk SQL update can move them without a uniqueness conflict. They are
    # registered in merge_registry for Phase 2.
    #
    # Phase 2 (run_cleanup): target.unify(sentinel) reroutes ranged_lots
    # (CollectionObjects) from the sentinel to the surviving target category,
    # then destroys the sentinel.
    class RangedLotCategoryHandler
      SENTINEL_PREFIX = 'UNIFICATION TO PROJECT'
      attr_reader :source_project_id, :target_project_id

      def initialize(source_project_id:, target_project_id:, options: {})
        @source_project_id = source_project_id
        @target_project_id = target_project_id
      end

      def migrate
        result = {
          track: :special,
          model: 'RangedLotCategory',
          migrated: 0,
          duplicates_found: [],
          errors: [],
          merge_registry: []
        }

        find_conflicts.each do |source_rlc, target_id|
          source_rlc.update_columns(
            name: "#{SENTINEL_PREFIX} #{target_project_id} #{source_rlc.id}"
          )
          result[:duplicates_found] << { source_id: source_rlc.id, target_id: target_id }
          result[:merge_registry] << {
            model: 'RangedLotCategory', renamed_id: source_rlc.id, target_id: target_id
          }
        end

        result[:migrated] = RangedLotCategory.where(project_id: source_project_id)
                                             .update_all(project_id: target_project_id)
        result
      rescue => e
        {
          track: :special,
          model: 'RangedLotCategory',
          migrated: 0,
          errors: [{ error: e.message, backtrace: e.backtrace.first(3) }]
        }
      end

      private

      def find_conflicts
        target_names = RangedLotCategory.where(project_id: target_project_id).pluck(:name, :id).to_h

        RangedLotCategory.where(project_id: source_project_id).filter_map do |rlc|
          target_id = target_names[rlc.name]
          [rlc, target_id] if target_id
        end
      end
    end

    # Handler for OtuPageLayout with name-based duplicate detection.
    #
    # Phase 1 (migrate): source layouts whose name collides with a target layout
    # have their name replaced with a per-record sentinel string so the bulk SQL
    # update can move them without a uniqueness conflict. They are registered in
    # merge_registry for Phase 2.
    #
    # Phase 2 (run_cleanup): target.unify(sentinel) reroutes OtuPageLayoutSections
    # from the sentinel to the surviving target layout, then destroys the sentinel.
    # Sections that would create a topic_id conflict on the target layout are
    # dropped (cascade-destroyed with the sentinel) — target's sections take
    # precedence.
    class OtuPageLayoutHandler
      SENTINEL_PREFIX = 'UNIFICATION TO PROJECT'
      attr_reader :source_project_id, :target_project_id

      def initialize(source_project_id:, target_project_id:, options: {})
        @source_project_id = source_project_id
        @target_project_id = target_project_id
      end

      def migrate
        result = {
          track: :special,
          model: 'OtuPageLayout',
          migrated: 0,
          duplicates_found: [],
          errors: [],
          merge_registry: []
        }

        find_conflicts.each do |source_layout, target_id|
          source_layout.update_columns(
            name: "#{SENTINEL_PREFIX} #{target_project_id} #{source_layout.id}"
          )
          result[:duplicates_found] << { source_id: source_layout.id, target_id: target_id }
          result[:merge_registry] << {
            model: 'OtuPageLayout', renamed_id: source_layout.id, target_id: target_id
          }
        end

        result[:migrated] = OtuPageLayout.where(project_id: source_project_id)
                                         .update_all(project_id: target_project_id)
        result
      rescue => e
        {
          track: :special,
          model: 'OtuPageLayout',
          migrated: 0,
          errors: [{ error: e.message, backtrace: e.backtrace.first(3) }]
        }
      end

      private

      def find_conflicts
        target_names = OtuPageLayout.where(project_id: target_project_id).pluck(:name, :id).to_h

        OtuPageLayout.where(project_id: source_project_id).filter_map do |layout|
          target_id = target_names[layout.name]
          [layout, target_id] if target_id
        end
      end
    end

    # Handler for Image with fingerprint-based deduplication.
    #
    # Phase 1 (migrate): source images whose fingerprint collides with a target
    # image have their fingerprint replaced with a per-record sentinel string so
    # the bulk SQL update can move them without a uniqueness conflict. They are
    # registered in merge_registry for Phase 2.
    #
    # Phase 2: handled by the generic Service#run_cleanup, which calls
    # target.unify(sentinel) to re-route all associations and destroy the sentinel.
    class ImageHandler
      SENTINEL_PREFIX = 'UNIFICATION TO PROJECT'

      attr_reader :source_project_id, :target_project_id

      def initialize(source_project_id:, target_project_id:, options: {})
        @source_project_id = source_project_id
        @target_project_id = target_project_id
      end

      def migrate
        result = {
          track: :special,
          model: 'Image',
          migrated: 0,
          duplicates_found: [],
          errors: [],
          merge_registry: []
        }

        duplicate_pairs.each do |source_image, target_id|
          original_fingerprint = source_image.image_file_fingerprint
          source_image.update_columns(
            image_file_fingerprint: "#{SENTINEL_PREFIX} #{target_project_id} #{source_image.id}"
          )
          result[:duplicates_found] << {
            source_id: source_image.id,
            target_id: target_id,
            fingerprint: original_fingerprint
          }
          result[:merge_registry] << {
            model: 'Image',
            renamed_id: source_image.id,
            target_id: target_id
          }
        end

        result[:migrated] = Image.where(project_id: source_project_id)
                                 .update_all(project_id: target_project_id)
        result
      rescue => e
        {
          track: :special,
          model: 'Image',
          migrated: 0,
          errors: [{ error: e.message, backtrace: e.backtrace.first(3) }]
        }
      end

      private

      def duplicate_pairs
        target_by_fingerprint = Image.where(project_id: target_project_id)
                                     .where.not(image_file_fingerprint: nil)
                                     .pluck(:image_file_fingerprint, :id)
                                     .to_h

        Image.where(project_id: source_project_id)
             .where(image_file_fingerprint: target_by_fingerprint.keys)
             .map { |img| [img, target_by_fingerprint[img.image_file_fingerprint]] }
      end
    end

    # Handler for Document with fingerprint-based deduplication.
    # Mirrors ImageHandler — see its comment for the Phase 1 / Phase 2 design.
    class DocumentHandler
      SENTINEL_PREFIX = 'UNIFICATION TO PROJECT'

      attr_reader :source_project_id, :target_project_id

      def initialize(source_project_id:, target_project_id:, options: {})
        @source_project_id = source_project_id
        @target_project_id = target_project_id
      end

      def migrate
        result = {
          track: :special,
          model: 'Document',
          migrated: 0,
          duplicates_found: [],
          errors: [],
          merge_registry: []
        }

        duplicate_pairs.each do |source_document, target_id|
          original_fingerprint = source_document.document_file_fingerprint
          source_document.update_columns(
            document_file_fingerprint: "#{SENTINEL_PREFIX} #{target_project_id} #{source_document.id}"
          )
          result[:duplicates_found] << {
            source_id: source_document.id,
            target_id: target_id,
            fingerprint: original_fingerprint
          }
          result[:merge_registry] << {
            model: 'Document',
            renamed_id: source_document.id,
            target_id: target_id
          }
        end

        result[:migrated] = Document.where(project_id: source_project_id)
                                    .update_all(project_id: target_project_id)
        result
      rescue => e
        {
          track: :special,
          model: 'Document',
          migrated: 0,
          errors: [{ error: e.message, backtrace: e.backtrace.first(3) }]
        }
      end

      private

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

      def initialize(source_project_id:, target_project_id:, options: {})
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
