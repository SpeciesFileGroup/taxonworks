# Validates potential conflicts before project unification
#
# Performs SQL-based analysis to detect uniqueness violations and other
# issues that would prevent successful unification.
#
module ProjectUnification
  class Validator
    attr_reader :source_project_id, :target_project_id

    def initialize(source_project_id, target_project_id)
      @source_project_id = source_project_id
      @target_project_id = target_project_id
    end

    # @return [Hash] Conflict analysis results
    def detect_all_conflicts
      counts = source_record_counts

      {
        status: :ok,
        can_proceed: true,
        conflicts: detect_uniqueness_conflicts,
        warnings: detect_warnings(counts),
        statistics: gather_statistics(counts)
      }
    end

    private

    def source_record_counts
      Project::MANIFEST.each_with_object({}) do |model_name, counts|
        klass = model_name.safe_constantize
        next unless klass&.column_names&.include?('project_id')

        counts[model_name] = klass.where(project_id: source_project_id).count
      end
    end

    def detect_uniqueness_conflicts
      conflicts = {}

      models_to_check = ProjectUnification::ModelClassifier::SLOW_TRACK

      models_to_check.each do |model_name|
        klass = model_name.safe_constantize
        next unless klass

        model_conflicts = check_model_uniqueness(klass)
        conflicts[model_name] = model_conflicts if model_conflicts.any?
      end

      conflicts
    end

    def check_model_uniqueness(klass)
      conflicts = []

      # Find uniqueness validators
      validators = klass.validators.select { |v|
        v.is_a?(ActiveRecord::Validations::UniquenessValidator)
      }

      validators.each do |validator|
        field = validator.attributes.first
        scope_fields = Array(validator.options[:scope] || [])

        # Build and execute conflict detection query
        conflict_records = find_conflicts(
          klass.table_name,
          field,
          scope_fields
        )

        conflicts.concat(conflict_records.map { |r|
          {
            source_id: r['source_id'],
            field: field.to_s,
            value: r[field.to_s],
            scope: scope_fields.map { |sf| [sf, r[sf.to_s]] }.to_h,
            target_id: r['target_id'],
            resolution: 'Will require deduplication or conflict handling'
          }
        })
      end

      conflicts
    end

    def find_conflicts(table_name, field, scope_fields)
      # Remove project_id from scope as we're explicitly handling that
      other_scopes = scope_fields.reject { |s| s.to_s == 'project_id' }

      scope_joins = other_scopes.map { |s| "AND s.#{s} = t.#{s}" }.join(' ')

      sql = <<-SQL
        SELECT
          s.id as source_id,
          t.id as target_id,
          s.#{field}
          #{other_scopes.any? ? ", #{other_scopes.map { |s| "s.#{s}" }.join(', ')}" : ''}
        FROM #{table_name} s
        INNER JOIN #{table_name} t
          ON s.#{field} = t.#{field}
          #{scope_joins}
        WHERE s.project_id = #{source_project_id}
          AND t.project_id = #{target_project_id}
        LIMIT 100
      SQL

      ActiveRecord::Base.connection.exec_query(sql).to_a
    rescue => e
      Rails.logger.error "Conflict detection failed for #{table_name}: #{e.message}"
      []
    end

    def detect_warnings(counts)
      warnings = []

      # Check for large datasets that might take a long time
      total_records = counts.values.sum
      if total_records > 100000
        warnings << {
          type: :performance,
          message: "Source project has #{total_records} records. Unification may take significant time."
        }
      end

      # Check for TaxonName hierarchy depth
      max_depth = check_taxon_name_depth
      if max_depth > 20
        warnings << {
          type: :complexity,
          message: "TaxonName hierarchy is #{max_depth} levels deep. This may impact performance."
        }
      end

      warnings
    end

    def check_taxon_name_depth
      sql = <<-SQL
        SELECT MAX(generations) as max_depth
        FROM taxon_name_hierarchies th
        INNER JOIN taxon_names tn ON th.descendant_id = tn.id
        WHERE tn.project_id = #{source_project_id}
      SQL

      result = ActiveRecord::Base.connection.exec_query(sql).first
      result&.fetch('max_depth', 0) || 0
    end

    def gather_statistics(counts)
      stats = {
        total_records: 0,
        affected_models: 0,
        fast_track_count: 0,
        slow_track_count: 0,
        special_count: 0
      }

      Project::MANIFEST.each do |model_name|
        klass = model_name.safe_constantize
        next unless klass&.column_names&.include?('project_id')
        next if model_name == 'ProjectMember'

        count = counts[model_name] || 0
        next if count == 0

        stats[:affected_models] += 1
        stats[:total_records] += count

        track = ProjectUnification::ModelClassifier.track_for(klass)
        case track
        when :fast
          stats[:fast_track_count] += count
        when :slow
          stats[:slow_track_count] += count
        when :special
          stats[:special_count] += count
        end
      end

      stats[:estimated_duration] = estimate_duration(stats[:total_records])
      stats
    end

    def estimate_duration(total_records)
      # Rough estimates based on processing speed
      seconds = case total_records
                when 0..1000
                  30
                when 1001..10000
                  (total_records / 200.0).round
                when 10001..100000
                  (total_records / 100.0).round
                else
                  (total_records / 50.0).round
                end

      if seconds < 60
        "#{seconds} seconds"
      else
        minutes = (seconds / 60.0).round
        "#{minutes} minutes"
      end
    end
  end
end
