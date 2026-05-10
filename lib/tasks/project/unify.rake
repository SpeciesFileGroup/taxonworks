namespace :tw do
  namespace :project do
    desc 'Unify two projects - merge all data from source into target'
    task unify: [:environment] do
      source_id = ENV['SOURCE_PROJECT_ID']
      target_id = ENV['TARGET_PROJECT_ID']
      root_id = ENV['ROOT_TAXON_NAME_ID']&.to_i
      preview = ActiveModel::Type::Boolean.new.cast(ENV.fetch('PREVIEW', true))

      unless source_id && target_id
        puts <<~USAGE
          Usage:
            rake tw:project:unify SOURCE_PROJECT_ID=X TARGET_PROJECT_ID=Y [PREVIEW=true|false] [ROOT_TAXON_NAME_ID=Z]

          Arguments:
            SOURCE_PROJECT_ID (required) - Project to merge from (will be emptied)
            TARGET_PROJECT_ID (required) - Project to merge into (receives all data)
            PREVIEW (optional)           - If 'false', performs actual migration. Default: true (dry-run)
            ROOT_TAXON_NAME_ID (optional)- TaxonName ID in target project to use as parent for source hierarchy

          Examples:
            # Preview unification (safe, rolls back)
            rake tw:project:unify SOURCE_PROJECT_ID=5 TARGET_PROJECT_ID=3

            # Actually perform unification
            rake tw:project:unify SOURCE_PROJECT_ID=5 TARGET_PROJECT_ID=3 PREVIEW=false

            # Merge under specific taxon
            rake tw:project:unify SOURCE_PROJECT_ID=5 TARGET_PROJECT_ID=3 ROOT_TAXON_NAME_ID=123 PREVIEW=false
        USAGE
        exit 1
      end

      if source_id == target_id
        puts "Error: source and target project IDs must be different"
        exit 1
      end

      begin
        source_project = Project.find(source_id)
        target_project = Project.find(target_id)
      rescue ActiveRecord::RecordNotFound => e
        puts "Error: #{e.message}"
        exit 1
      end

      if root_id && !TaxonName.exists?(id: root_id, project_id: target_project.id)
        puts "Error: ROOT_TAXON_NAME_ID #{root_id} does not exist in target project"
        exit 1
      end

      puts "=" * 80
      puts "PROJECT UNIFICATION"
      puts "=" * 80
      puts "Source Project: #{source_project.name} (ID: #{source_id})"
      puts "Target Project: #{target_project.name} (ID: #{target_id})"
      puts "Preview Mode:   #{preview ? 'YES (will rollback)' : 'NO (will persist changes)'}"
      if root_id
        root_taxon = TaxonName.find(root_id)
        puts "Target Root:    #{root_taxon.cached} (ID: #{root_id})"
      end
      puts "=" * 80
      puts ""

      if !preview
        puts "WARNING: This is NOT a preview. Data will be permanently migrated!"
        puts "Press Ctrl+C within 5 seconds to cancel..."
        sleep 5
        puts ""
      end

      puts "Starting unification..."
      start_time = Time.now

      begin
        result = target_project.unify(
          source_project,
          root_taxon_name_id: root_id,
          preview: preview,
          confirm: !preview,
          skip_cached_rebuild: false
        )
      rescue Interrupt
        puts "\nInterrupted — transaction rolled back."
        exit 1
      end

      puts "\n" + "=" * 80
      puts "RESULTS"
      puts "=" * 80

      if preview
        if result[:errors].empty? && result[:conflicts].empty?
          puts "✓ Preview completed - no conflicts or errors (changes rolled back)"
        elsif result[:conflicts].any?
          puts "✗ Preview completed - #{result[:conflicts].length} conflict(s) must be resolved before migrating"
        else
          puts "✗ Preview completed with errors"
        end
      elsif result[:unified]
        puts "✓ Unification completed successfully!"
      else
        puts "✗ Unification failed"
      end

      puts "\nStatistics:"
      puts "  Models processed:    #{result[:statistics][:models_processed]}"
      puts "  Records migrated:    #{result[:statistics][:records_migrated]}"
      puts "  Fast track:          #{result[:statistics][:fast_track_count]}"
      puts "  Medium track:        #{result[:statistics][:medium_track_count]}"
      puts "  Slow track:          #{result[:statistics][:slow_track_count]}"
      puts "  Special handling:    #{result[:statistics][:special_track_count]}"
      puts "  Conflicts:           #{result[:conflicts].length}"
      puts "  Errors:              #{result[:statistics][:errors_encountered]}"
      puts "  Duration:            #{result[:duration_seconds]}s"

      if result[:conflicts].any?
        puts "\nConflicts requiring manual resolution:"
        result[:conflicts].each_with_index do |conflict, i|
          fields = Array(conflict[:conflict_fields]).join(', ')
          puts "  #{i + 1}. [#{conflict[:model]}] ID #{conflict[:id]} - field(s): #{fields}"
          puts "       #{conflict[:errors].first}" if conflict[:errors].any?
        end
      end

      if result[:errors].any?
        puts "\nErrors encountered:"
        result[:errors].each_with_index do |error, i|
          puts "  #{i + 1}. [#{error[:model]}] #{error[:error]}"
        end
      end

      if result[:details_by_model].any?
        puts "\nDetails by model:"
        result[:details_by_model].sort.each do |model_name, details|
          migrated = details[:migrated] || 0
          next if migrated == 0

          track = details[:track] || 'unknown'
          puts "  #{model_name.ljust(40)} #{track.to_s.ljust(10)} #{migrated} records"
        end
      end

      puts "\n" + "=" * 80

      if result[:rollback_performed]
        puts "All changes were rolled back (preview mode or errors occurred)"
      end

      exit(result[:unified] ? 0 : 1)
    end

    desc 'Preview project unification conflicts without migrating data'
    task preview_conflicts: [:environment] do
      source_id = ENV['SOURCE_PROJECT_ID']
      target_id = ENV['TARGET_PROJECT_ID']

      unless source_id && target_id
        puts "Usage: rake tw:project:preview_conflicts SOURCE_PROJECT_ID=X TARGET_PROJECT_ID=Y"
        exit 1
      end

      puts "Analyzing potential conflicts between projects #{source_id} and #{target_id}..."
      puts ""

      validator = ProjectUnification::Validator.new(source_id.to_i, target_id.to_i)
      analysis = validator.detect_all_conflicts

      puts "=" * 80
      puts "CONFLICT ANALYSIS"
      puts "=" * 80

      puts "\nStatistics:"
      puts "  Total records to migrate: #{analysis[:statistics][:total_records]}"
      puts "  Affected models:          #{analysis[:statistics][:affected_models]}"
      puts "  Fast track records:       #{analysis[:statistics][:fast_track_count]}"
      puts "  Medium track records:     #{analysis[:statistics][:medium_track_count]}"
      puts "  Slow track records:       #{analysis[:statistics][:slow_track_count]}"
      puts "  Special handling:         #{analysis[:statistics][:special_count]}"
      puts "  Estimated duration:       #{analysis[:statistics][:estimated_duration]}"

      if analysis[:conflicts].any?
        puts "\nPotential conflicts found:"
        analysis[:conflicts].each do |model_name, conflicts|
          puts "\n  #{model_name}: #{conflicts.length} conflict(s)"
          conflicts.first(5).each do |conflict|
            puts "    - Record #{conflict[:source_id]}: #{conflict[:field]} = '#{conflict[:value]}'"
          end
          puts "    ... and #{conflicts.length - 5} more" if conflicts.length > 5
        end
      else
        puts "\n✓ No conflicts detected"
      end

      if analysis[:warnings].any?
        puts "\nWarnings:"
        analysis[:warnings].each do |warning|
          puts "  [#{warning[:type]}] #{warning[:message]}"
        end
      end

      puts "\nCan proceed: #{analysis[:can_proceed] ? 'YES' : 'NO'}"
      puts "=" * 80
    end

    desc 'Show statistics about a project for unification planning'
    task project_stats: [:environment] do
      project_id = ENV['PROJECT_ID']

      unless project_id
        puts "Usage: rake tw:project:project_stats PROJECT_ID=X"
        exit 1
      end

      project = Project.find(project_id)

      puts "=" * 80
      puts "PROJECT STATISTICS: #{project.name} (ID: #{project_id})"
      puts "=" * 80

      total_records = 0
      stats_by_track = Hash.new(0)

      puts "\nRecords by model:"
      Project::MANIFEST.each do |model_name|
        klass = model_name.safe_constantize
        next unless klass&.column_names&.include?('project_id')

        count = klass.where(project_id: project_id).count
        next if count == 0

        track = ProjectUnification::ModelClassifier.track_for(klass)
        stats_by_track[track] += count
        total_records += count

        puts "  #{model_name.ljust(45)} #{track.to_s.ljust(10)} #{count.to_s.rjust(8)} records"
      end

      puts "\n" + "-" * 80
      puts "Total records: #{total_records}"
      puts "\nBy processing track:"
      stats_by_track.sort.each do |track, count|
        puts "  #{track.to_s.ljust(10)} #{count.to_s.rjust(8)} records"
      end
      puts "=" * 80
    end
  end
end
