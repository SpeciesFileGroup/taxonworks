namespace :tw do
  namespace :project do
    desc 'Unify two projects - merge all data from source into target'
    task unify: [:environment] do
      $stdout.sync = true

      source_id = ENV['SOURCE_PROJECT_ID']
      target_id = ENV['TARGET_PROJECT_ID']
      user_id   = ENV['USER_ID']&.to_i
      root_id   = ENV['ROOT_TAXON_NAME_ID']&.to_i
      preview   = ActiveModel::Type::Boolean.new.cast(ENV.fetch('PREVIEW', true))

      unless source_id && target_id && user_id
        puts <<~USAGE
          Usage:
            rake tw:project:unify SOURCE_PROJECT_ID=X TARGET_PROJECT_ID=Y USER_ID=Z [PREVIEW=true|false] [ROOT_TAXON_NAME_ID=W]

          Arguments:
            SOURCE_PROJECT_ID (required) - Project to merge from (will be emptied)
            TARGET_PROJECT_ID (required) - Project to merge into (receives all data)
            USER_ID           (required) - ID of the user performing the merge (set as updated_by on migrated records)
            PREVIEW (optional)           - If 'false', performs actual migration. Default: true (dry-run)
            ROOT_TAXON_NAME_ID (optional)- TaxonName ID in target project to use as parent for source hierarchy

          Examples:
            # Preview unification (safe, rolls back)
            rake tw:project:unify SOURCE_PROJECT_ID=5 TARGET_PROJECT_ID=3 USER_ID=1

            # Actually perform unification
            rake tw:project:unify SOURCE_PROJECT_ID=5 TARGET_PROJECT_ID=3 USER_ID=1 PREVIEW=false

            # Merge under specific taxon
            rake tw:project:unify SOURCE_PROJECT_ID=5 TARGET_PROJECT_ID=3 USER_ID=1 ROOT_TAXON_NAME_ID=123 PREVIEW=false
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

      # We don't require user to be a member of the target project.
      if user_id && !User.exists?(id: user_id)
        puts "Error: USER #{user_id} does not exist!"
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
        puts Rainbow("WARNING: This is NOT a preview. Data will be permanently migrated!").red.bright
        puts "Press Ctrl+C within 10 seconds to cancel..."
        sleep 10
        puts ""
      end

      puts "Starting unification..."
      start_time = Time.now

      on_progress = ->(model_name, track, model_result) {
        migrated  = model_result[:migrated].to_i
        destroyed = model_result[:destroyed].to_i
        errors    = model_result[:errors]&.length.to_i
        conflicts = model_result[:conflicts]&.length.to_i
        parts = []
        parts << "#{migrated} migrated"    if migrated  > 0
        parts << "#{destroyed} destroyed"  if destroyed > 0
        parts << Rainbow("#{conflicts} conflict(s)").yellow if conflicts > 0
        parts << Rainbow("#{errors} error(s)").red          if errors    > 0
        parts << '(empty)'                                  if parts.empty?
        duration = model_result[:duration] ? "  #{model_result[:duration]}s" : ''
        $stdout.puts "  #{model_name.ljust(34)}  #{track.to_s.ljust(10)}  #{parts.join(', ')}#{duration}"
      }

      begin
        result = target_project.unify(
          source_project,
          root_taxon_name_id: root_id,
          preview: preview,
          user_id: user_id,
          on_model_migrated: on_progress,
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
          puts Rainbow("✓ Preview completed - no conflicts or errors (changes rolled back)").green
        elsif result[:conflicts].any?
          puts Rainbow("✗ Preview completed - #{result[:conflicts].length} conflict(s) must be resolved before migrating").red
        else
          puts Rainbow("✗ Preview completed with errors").red
        end
      elsif result[:unified]
        puts Rainbow("✓ Unification completed successfully!").green.bright
      else
        puts Rainbow("✗ Unification failed").red.bright
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
        puts Rainbow("\nConflicts requiring manual resolution:").yellow.bright
        result[:conflicts].each_with_index do |conflict, i|
          fields = Array(conflict[:conflict_fields]).join(', ')

          if (src = conflict[:source_cvt])
            puts Rainbow("  #{i + 1}. [#{conflict[:model]}] '#{src[:name]}' (#{src[:cvt_type]}, ID #{conflict[:id]}, source project #{src[:project_id]})").yellow
            puts "       Conflicting field(s): #{fields}"
            puts "       Source definition: #{src[:definition]}"
            puts "       Source uri:        #{src[:uri]} [#{src[:uri_relation]}]" if src[:uri].present?
            if (tgt = conflict[:target_cvt])
              puts "       Conflicts with:    '#{tgt[:name]}' (#{tgt[:cvt_type]}, ID #{tgt[:id]}, target project #{tgt[:project_id]})"
              puts "       Target definition: #{tgt[:definition]}"
              puts "       Target uri:        #{tgt[:uri]} [#{tgt[:uri_relation]}]" if tgt[:uri].present?
            end
            puts Rainbow("       Resolution: edit the name, definition, or uri of one CVT in TaxonWorks before retrying").yellow
          else
            puts Rainbow("  #{i + 1}. [#{conflict[:model]}] ID #{conflict[:id]} - field(s): #{fields}").yellow
            puts "       #{conflict[:errors].first}" if conflict[:errors].any?
          end
        end
      end

      if result[:errors].any?
        puts Rainbow("\nErrors encountered:").red.bright
        result[:errors].each_with_index do |error, i|
          puts Rainbow("  #{i + 1}. [#{error[:model]}] #{error[:error]}").red
        end
      end

      if result[:details_by_model].any?
        puts "\nDetails by model:"
        result[:details_by_model].sort.each do |model_name, details|
          migrated  = details[:migrated]   || 0
          destroyed = details[:destroyed]  || 0
          next if migrated == 0 && destroyed == 0

          track = details[:track] || 'unknown'
          parts = []
          parts << "#{migrated} migrated"   if migrated  > 0
          parts << "#{destroyed} destroyed" if destroyed > 0
          puts "  #{model_name.ljust(40)} #{track.to_s.ljust(10)} #{parts.join(', ')}"
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
