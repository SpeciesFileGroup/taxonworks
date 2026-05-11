# Handles the actual data migration between projects
#
# Processes models in MANIFEST order, applying different strategies
# based on validation complexity (fast/medium/slow tracks).
#
module ProjectUnification
  class Migrator
    attr_reader :source_project_id, :target_project_id, :options

    def initialize(source_project_id, target_project_id, options = {})
      @source_project_id = source_project_id
      @target_project_id = target_project_id
      @options = options
      @on_model_migrated = options[:on_model_migrated]
    end

    # Migrate all models from source to target project
    # @return [Hash] Migration results with statistics and errors
    def migrate_all
      results = {
        statistics: {
          models_processed: 0,
          records_migrated: 0,
          fast_track_count: 0,
          medium_track_count: 0,
          slow_track_count: 0,
          special_track_count: 0,
          errors_encountered: 0
        },
        details_by_model: {},
        conflicts: [],
        errors: [],
        merge_registry: []
      }

      # Process in MANIFEST order (dependencies first).
      # Note: We reverse because MANIFEST is in deletion order.
      # ControlledVocabularyTerm is skipped here and handled last — after all
      # FK-bearing rows are in the target project — so rename-on-conflict leaves
      # no dangling cross-project references.
      Project::MANIFEST.reverse.each do |model_name|
        next if model_name == 'ControlledVocabularyTerm'

        klass = model_name.safe_constantize
        next unless klass
        next unless klass.column_names.include?('project_id')
        next unless ProjectUnification::ModelClassifier.should_migrate?(klass)

        track = ProjectUnification::ModelClassifier.track_for(klass)

        model_result = case track
                       when :fast
                         process_fast_track(klass)
                       when :medium, :implicit
                         process_medium_track(klass)
                       when :slow
                         process_slow_track(klass)
                       when :cached
                         process_cached_table(klass)
                       when :special
                         process_special_handling(klass)
                       else
                         next
                       end

        if model_result
          @on_model_migrated&.call(model_name, track, model_result)

          results[:details_by_model][model_name] = model_result
          results[:statistics][:models_processed] += 1
          results[:statistics][:records_migrated] += model_result[:migrated] || 0

          # Update track-specific counter
          track_key = "#{track}_track_count".to_sym
          results[:statistics][track_key] ||= 0
          results[:statistics][track_key] += model_result[:migrated] || 0

          results[:statistics][:errors_encountered] += model_result[:errors]&.length || 0
          results[:conflicts].concat(model_result[:conflicts] || [])
          results[:errors].concat(model_result[:errors] || [])
        end
      end

      # ControlledVocabularyTerm — processed last so all FK-bearing rows already
      # live in the target project.  Conflicts are resolved by renaming the source
      # CVT; the registry of renamed→target pairs is returned for Phase 2 cleanup.
      cvt_result = process_controlled_vocabulary_terms
      if cvt_result
        @on_model_migrated&.call('ControlledVocabularyTerm', :slow, cvt_result)
        results[:details_by_model]['ControlledVocabularyTerm'] = cvt_result
        results[:statistics][:models_processed]    += 1
        results[:statistics][:records_migrated]    += cvt_result[:migrated] || 0
        results[:statistics][:slow_track_count]    += cvt_result[:migrated] || 0
        results[:statistics][:errors_encountered]  += cvt_result[:errors]&.length || 0
        results[:conflicts].concat(cvt_result[:conflicts] || [])
        results[:errors].concat(cvt_result[:errors] || [])
        results[:merge_registry].concat(cvt_result[:merge_registry] || [])
      end

      results
    end

    private

    # Fast track: Bulk SQL UPDATE for simple cases
    def process_fast_track(klass)
      return nil unless klass.where(project_id: source_project_id).exists?

      sql = ActiveRecord::Base.sanitize_sql_array([
        "UPDATE #{klass.table_name} SET project_id = ? WHERE project_id = ?",
        target_project_id,
        source_project_id
      ])

      rows_affected = ActiveRecord::Base.connection.execute(sql).cmd_tuples

      {
        track: :fast,
        migrated: rows_affected,
        method: :bulk_sql,
        errors: []
      }
    rescue => e
      {
        track: :fast,
        migrated: 0,
        errors: [{
          error: e.message,
          model: klass.name
        }]
      }
    end

    # Medium track: Batch processing with validation
    def process_medium_track(klass)
      stats = { track: :medium, migrated: 0, destroyed: 0, conflicts: [], errors: [] }

      records = klass.where(project_id: source_project_id)
      return nil unless records.exists?

      records.find_in_batches(batch_size: 500) do |batch|
        batch.each do |record|
          record.no_cached = true if record.respond_to?(:no_cached=)
          record.project_id = target_project_id

          if record.valid?
            record.save!(validate: false)
            stats[:migrated] += 1
          elsif uniqueness_error?(record) && record.respond_to?(:handle_unify_conflict)
            apply_conflict_handler(record, stats, save_with_validation: false)
          elsif uniqueness_error?(record)
            stats[:conflicts] << {
              id: record.id,
              model: klass.name,
              conflict_fields: conflict_fields(record),
              errors: record.errors.full_messages
            }
          else
            stats[:errors] << {
              id: record.id,
              model: klass.name,
              error: record.errors.full_messages.join('; ')
            }
          end
        rescue => e
          stats[:errors] << {
            id: record.id,
            model: klass.name,
            error: e.message
          }
        end
      end

      stats
    end

    # Slow track: Per-record processing with custom handlers
    def process_slow_track(klass)
      stats = { track: :slow, migrated: 0, destroyed: 0, conflicts: [], errors: [] }

      records = klass.where(project_id: source_project_id)
      return nil unless records.exists?

      records.find_each do |record|
        record.no_cached = true if record.respond_to?(:no_cached=)
        record.project_id = target_project_id

        if record.valid?
          record.save!
          stats[:migrated] += 1
        elsif uniqueness_error?(record) && record.respond_to?(:handle_unify_conflict)
          apply_conflict_handler(record, stats, save_with_validation: true)
        elsif uniqueness_error?(record)
          stats[:conflicts] << {
            id: record.id,
            model: klass.name,
            conflict_fields: conflict_fields(record),
            errors: record.errors.full_messages
          }
        else
          stats[:errors] << {
            id: record.id,
            model: klass.name,
            error: record.errors.full_messages.join('; ')
          }
        end
      rescue => e
        stats[:errors] << {
          id: record.id,
          model: klass.name,
          error: e.message
        }
      end

      stats
    end

    # Process cached tables with direct SQL update
    def process_cached_table(klass)
      handler = ProjectUnification::SpecialHandlers::CachedTablesHandler.new(
        source_project_id,
        target_project_id,
        klass.table_name
      )
      handler.migrate
    end

    # Special handling for models that need custom logic
    def process_special_handling(klass)
      result = case klass.name
               when 'TaxonName'
                 handler = ProjectUnification::TaxonNameHandler.new(
                   source_project_id,
                   target_project_id,
                   options
                 )
                 handler.migrate
               when 'CollectingEvent'
                 handler = ProjectUnification::SpecialHandlers::CollectingEventHandler.new(
                   source_project_id,
                   target_project_id,
                   options
                 )
                 handler.migrate
               when 'Image'
                 handler = ProjectUnification::SpecialHandlers::ImageHandler.new(
                   source_project_id,
                   target_project_id,
                   options
                 )
                 handler.migrate
               when 'Document'
                 handler = ProjectUnification::SpecialHandlers::DocumentHandler.new(
                   source_project_id,
                   target_project_id,
                   options
                 )
                 handler.migrate
               else
                 raise NotImplementedError, "No special handler defined for #{klass.name}"
               end

      result
    end

    # Dispatch to handle_unify_conflict and update stats based on its return value.
    #
    # handle_unify_conflict return convention:
    #   nil / false  -> handler did not persist; caller should save! the record
    #   true         -> handler persisted via update_columns; skip save!
    #   :destroyed   -> handler destroyed the source record (merged into target); skip save!
    def apply_conflict_handler(record, stats, save_with_validation:)
      result = record.handle_unify_conflict(target_project_id)

      if result == :destroyed
        stats[:destroyed] += 1
      else
        record.save!(validate: save_with_validation) unless result
        stats[:migrated] += 1
      end
    end

    # Migrate ControlledVocabularyTerm records last, after all FK-bearing rows have
    # been moved to the target project.  On a uniqueness conflict, the source CVT is
    # renamed (suffix "[<source project name>]", with a counter if needed) so it can
    # be saved without conflict.  Each renamed CVT is added to a merge_registry so
    # the Service can invoke Shared::Unify#unify in Phase 2, collapsing renamed CVTs
    # into their target counterparts now that both are in the same project.
    def process_controlled_vocabulary_terms
      klass = ControlledVocabularyTerm
      stats = { track: :slow, migrated: 0, conflicts: [], errors: [], merge_registry: [] }

      records = klass.where(project_id: source_project_id)
      return nil unless records.exists?

      source_name = Project.find(source_project_id).name

      records.find_each do |record|
        record.no_cached = true if record.respond_to?(:no_cached=)
        record.project_id = target_project_id

        if record.valid?
          record.save!
          stats[:migrated] += 1
        elsif uniqueness_error?(record)
          original_name       = record.name
          original_definition = record.definition

          target_cvt = find_conflicting_target_cvt(record, original_name, original_definition)

          record.name       = unique_cvt_name(original_name, record.type, source_name)
          record.definition = unique_cvt_definition(original_definition, source_name)
          record.save!
          stats[:migrated] += 1

          if target_cvt && target_cvt.type == record.type
            stats[:merge_registry] << {
              model: record.class.name,
              renamed_id: record.id,
              target_id: target_cvt.id
            }
          end
        else
          stats[:errors] << {
            id: record.id,
            model: klass.name,
            error: record.errors.full_messages.join('; ')
          }
        end
      rescue => e
        stats[:errors] << { id: record.id, model: klass.name, error: e.message }
      end

      stats
    end

    def find_conflicting_target_cvt(record, original_name, original_definition)
      ControlledVocabularyTerm.find_by(type: record.type, name: original_name, project_id: target_project_id) ||
        ControlledVocabularyTerm.find_by(definition: original_definition, project_id: target_project_id)
    end

    # Returns a name that does not conflict with any CVT of the same type in target project.
    def unique_cvt_name(original_name, cvt_type, suffix)
      candidate = "#{original_name} [#{suffix}]"
      counter   = 2
      while ControlledVocabularyTerm.exists?(type: cvt_type, name: candidate, project_id: target_project_id)
        candidate = "#{original_name} [#{suffix} #{counter}]"
        counter  += 1
      end
      candidate
    end

    # Returns a definition that does not conflict with any CVT in target project.
    # Returns the original unchanged if it doesn't already conflict.
    def unique_cvt_definition(original_definition, suffix)
      return original_definition unless ControlledVocabularyTerm.exists?(definition: original_definition, project_id: target_project_id)
      candidate = "#{original_definition} [#{suffix}]"
      counter   = 2
      while ControlledVocabularyTerm.exists?(definition: candidate, project_id: target_project_id)
        candidate = "#{original_definition} [#{suffix} #{counter}]"
        counter  += 1
      end
      candidate
    end

    def uniqueness_error?(record)
      record.errors.details.values.flatten.any? { |e| e[:error] == :taken }
    end

    def conflict_fields(record)
      record.errors.details
        .select { |_, details| details.any? { |d| d[:error] == :taken } }
        .keys
    end
  end
end
