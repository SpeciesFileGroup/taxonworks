# Handles the actual data migration between projects.
#
# Processes models in *reverse* MANIFEST order using two strategies:
#   fast  — bulk SQL UPDATE, no per-record validation
#   slow  — per-record valid? to detect target-project uniqueness conflicts,
#            then save!(validate: false) on success
#
# !! A note on somewhat implicit assumptions as we move objects one at a time
# from source to target project:
# * we run in reverse manifest order: that means that when we validate-save in
#   the target project, any validations that check that FK values are in the
#   same project will pass (aside from the global one we've disabled during
#   unify, are there any such??)
# * when we validate a moved object, some data is still in the source project,
#   so validations like "are there any other objects in this project with this
#   data?" are not seeing all of the data they should - this should be okay
#   because the object is assumed to have already passed that validation in the
#   source project. (If there was bad data in the source, it could stay bad in
#   the target for this reason.)
# * Validations like "make sure all of the children of this object are in the
#   same project" WOULD FAIL when children hadn't been moved to the target
#   project yet. Which is to say !! this system is not bullet proof !!, there
#   are implicit assumptions about how existing validations behave.
module ProjectUnification
  class Migrator
    attr_reader :source_project_id, :target_project_id, :options

    def initialize(source_project_id:, target_project_id:, options: {})
      @source_project_id = source_project_id
      @target_project_id = target_project_id
      @options = options
      @on_model_migrated = options[:on_model_migrated]
    end

    # Migrate all models from source to target project.
    # @return [Hash] Migration results with statistics and errors
    def migrate_all
      results = {
        statistics: {
          models_processed: 0,
          records_migrated: 0,
          fast_track_count: 0,
          slow_track_count: 0,
          special_track_count: 0,
          errors_encountered: 0
        },
        details_by_model: {},
        conflicts: [],
        errors: [],
        merge_registry: []
      }

      # MANIFEST is ordered for deletion: FK children appear before FK parents so
      # children can be deleted without violating FK constraints. For migration we
      # need the opposite — parents must arrive in the target project before their
      # children, so that when a child calls valid? with project_id = target_project_id
      # any same-project validator on its FK will find the parent already there.
      # Reversing MANIFEST gives us that order cheaply.
      Project::MANIFEST.reverse.each do |model_name|
        # ControlledVocabularyTerm is skipped here and handled last — after all
        # FK-bearing rows are in the target project — so rename-on-conflict
        # leaves no dangling cross-project references.
        next if model_name == 'ControlledVocabularyTerm'

        klass = model_name.safe_constantize
        next unless klass
        next unless klass.column_names.include?('project_id')
        next unless ProjectUnification::ModelClassifier.should_migrate?(klass)

        track = ProjectUnification::ModelClassifier.track_for(klass)

        model_started_at = Time.now
        model_result = case track
                       when :fast
                         process_fast_track(klass)
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
          model_result[:duration] = (Time.now - model_started_at).round(1)
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
      cvt_started_at = Time.now
      cvt_result = process_controlled_vocabulary_terms
      if cvt_result
        cvt_result[:duration] = (Time.now - cvt_started_at).round(1)
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

    # Fast track: Bulk SQL UPDATE for simple cases.
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

    # Slow track: per-record valid? to detect uniqueness conflicts, then save
    # without re-running validations.
    def process_slow_track(klass)
      stats = { track: :slow, migrated: 0, destroyed: 0, conflicts: [], errors: [] }

      records = klass.where(project_id: source_project_id)
      return nil unless records.exists?

      records.find_each do |record|
        record.no_cached = true if record.respond_to?(:no_cached=)
        record.project_id = target_project_id

        if record.valid?
          record.save!(validate: false)
          stats[:migrated] += 1
        elsif uniqueness_error?(record)
          if record.respond_to?(:handle_unify_conflict)
            apply_conflict_handler(record, stats)
          else
            stats[:conflicts] << {
              id: record.id,
              model: klass.name,
              conflict_fields: conflict_fields(record),
              errors: record.errors.full_messages
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
        stats[:errors] << {
          id: record.id,
          model: klass.name,
          error: e.message
        }
      end

      stats
    end

    # Process cached tables with direct SQL update.
    def process_cached_table(klass)
      handler = ProjectUnification::SpecialHandlers::CachedTablesHandler.new(
        source_project_id,
        target_project_id,
        klass.table_name
      )
      handler.migrate
    end

    # Special handling for models that need custom logic.
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
    def apply_conflict_handler(record, stats)
      result = record.handle_unify_conflict(target_project_id)

      if result == :destroyed
        stats[:destroyed] += 1
      else
        record.save! unless result
        stats[:migrated] += 1
      end
    end

    # Migrate ControlledVocabularyTerm records last, after all FK-bearing rows have
    # been moved to the target project.  On a uniqueness conflict, only the specific
    # failing field(s) are stamped with a sentinel suffix so the record can be saved.
    # Each such CVT is added to a merge_registry so the Service can invoke
    # Shared::Unify#unify in Phase 2, collapsing it into its target counterpart now
    # that both are in the same project.
    #
    # The sentinel is deliberately conspicuous — if Phase 2 cleanup ever fails, the
    # user can find the bad data by searching for "UNIFICATION TO PROJECT".
    def process_controlled_vocabulary_terms
      klass = ControlledVocabularyTerm
      stats = { track: :slow, migrated: 0, conflicts: [], errors: [], merge_registry: [] }
      sentinel = "UNIFICATION TO PROJECT #{target_project_id}"

      records = klass.where(project_id: source_project_id)
      return nil unless records.exists?

      records.find_each do |record|
        record.no_cached = true if record.respond_to?(:no_cached=)
        record.project_id = target_project_id

        if record.valid?
          record.save!
          stats[:migrated] += 1
        elsif uniqueness_error?(record)
          target_cvts = find_conflicting_target_cvts(record)
          unique_targets = target_cvts.values.uniq(&:id)
          sole_target = unique_targets.first if unique_targets.one?

          if sole_target && sole_target.type == record.type && cvts_semantically_equivalent?(record, sole_target)
            record.errors.details.each do |field, errors|
              next unless errors.any? { |e| e[:error] == :taken }
              case field
              when :name
                record.name = unique_cvt_name(record.name, record.type, sentinel)
              when :definition
                record.definition = unique_cvt_definition(record.definition, sentinel)
              when :uri
                record.uri = unique_cvt_uri(record.uri, record.uri_relation, sentinel)
              end
            end

            record.save!
            stats[:migrated] += 1
            stats[:merge_registry] << {
              model: record.class.name,
              renamed_id: record.id,
              target_id: sole_target.id
            }
          else
            primary_target = sole_target || unique_targets.first
            stats[:conflicts] << {
              id: record.id,
              model: klass.name,
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
                {
                  id: cvt.id,
                  project_id: target_project_id,
                  cvt_type: cvt.type,
                  name: cvt.name,
                  definition: cvt.definition,
                  uri: cvt.uri,
                  uri_relation: cvt.uri_relation
                }
              }
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

    def cvts_semantically_equivalent?(record, target_cvt)
      record.name == target_cvt.name &&
        record.definition == target_cvt.definition &&
        record.uri_relation == target_cvt.uri_relation &&
        (record.uri.blank? || record.uri == target_cvt.uri)
    end

    # Returns a hash of { field_sym => ControlledVocabularyTerm } for each field on
    # +record+ that conflicts with an existing CVT in the target project.  Each field
    # may identify a *different* target CVT; callers must check whether all entries
    # resolve to the same record before attempting auto-resolution.
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

    # Returns a name that does not conflict with any CVT of the same type in the target project.
    def unique_cvt_name(original_name, cvt_type, sentinel)
      candidate = "#{original_name} [#{sentinel}]"
      counter = 2
      while ControlledVocabularyTerm.exists?(type: cvt_type, name: candidate, project_id: target_project_id)
        candidate = "#{original_name} [#{sentinel} #{counter}]"
        counter += 1
      end
      candidate
    end

    # Returns a definition that does not conflict with any CVT in the target project.
    def unique_cvt_definition(original_definition, sentinel)
      candidate = "#{original_definition} [#{sentinel}]"
      counter = 2
      while ControlledVocabularyTerm.exists?(definition: candidate, project_id: target_project_id)
        candidate = "#{original_definition} [#{sentinel} #{counter}]"
        counter += 1
      end
      candidate
    end

    # Returns a URI that does not conflict in the target project (scoped by uri_relation).
    # Appends the sentinel without spaces so the result remains a valid URI.
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
