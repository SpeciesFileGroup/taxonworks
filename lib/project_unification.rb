# Main service object for project unification
#
# Orchestrates the process of merging all data from one project into another,
# handling validation conflicts, maintaining data integrity, and preserving
# complex relationships like TaxonName hierarchies.
#
# @example Basic usage
#   service = ProjectUnification.new(source_project, target_project)
#   result = service.unify(preview: true)
#
module ProjectUnification
  class Service
    attr_reader :source_project, :target_project, :options, :results

    # @param source_project [Project] Project to merge from (will be emptied)
    # @param target_project [Project] Project to merge into (receives all data)
    # @param options [Hash]
    # @option options [Integer] :root_taxon_name_id Optional target parent for
    #   TaxonName hierarchy
    # @option options [Boolean] :preview If true, rolls back all changes
    #   (default: true)
    # @option options [Integer] :user_id ID of the user performing the
    #   unification; required so that updated_by_id is set correctly on all
    #   migrated records (including during preview, since record.valid? triggers
    #   before_validation callbacks)
    # @option options [Boolean] :skip_cached_rebuild Skip rebuilding cached
    #   fields (default: false)
    def initialize(source_project, target_project, options = {})
      @source_project = source_project
      @target_project = target_project
      @options = {
        preview: true,
        skip_cached_rebuild: false
      }.merge(options)

      @results = {
        unified: false,
        preview_mode: @options[:preview],
        source_project_id: source_project.id,
        target_project_id: target_project.id,
        started_at: nil,
        completed_at: nil,
        duration_seconds: 0,
        statistics: {},
        details_by_model: {},
        conflicts: [],
        errors: [],
        rollback_performed: false
      }
    end

    # Execute the unification process
    # @return [Hash] Results hash with detailed statistics and error information
    def unify
      @results[:started_at] = Time.now

      validate_prerequisites!

      # Capture ambient Current state so we can restore it after (important if
      # called from a request context; from a rake task they'd both be nil).
      saved_user_id = Current.user_id
      saved_project_id = Current.project_id

      # Migration must run under the provided user so that updated_by_id is set
      # correctly on every record. project_id is cleared so that
      # find_or_create_by calls in callbacks cannot accidentally scope to the
      # caller's ambient project.
      Current.user_id = @options[:user_id]
      Current.project_id = nil

      # Allows for cross-project saves
      Thread.current[:tw_project_unification] = true

      Project.transaction do
        run_migration

        @results[:unified] = @results[:errors].empty? && @results[:conflicts].empty?

        if @options[:preview] || @results[:errors].any? || @results[:conflicts].any?
          raise ActiveRecord::Rollback
        end
      rescue ActiveRecord::Rollback
        @results[:rollback_performed] = true
        raise
      rescue StandardError => e
        @results[:errors] << {
          model: 'Transaction',
          error: e.message,
          backtrace: e.backtrace.first(5)
        }
        @results[:rollback_performed] = true
        raise ActiveRecord::Rollback
      rescue Exception => e
        @results[:rollback_performed] = true
        raise
      end

      @results[:completed_at] = Time.now
      @results[:duration_seconds] = (@results[:completed_at] - @results[:started_at]).round(2)

      @results
    ensure
      Thread.current[:tw_project_unification] = nil
      Current.user_id = saved_user_id
      Current.project_id = saved_project_id
    end

    private

    def validate_prerequisites!
      if source_project.id == target_project.id
        raise ArgumentError, 'Cannot unify a project with itself'
      end

      if @options[:root_taxon_name_id]
        target_taxon = TaxonName.find_by(id: @options[:root_taxon_name_id])
        unless target_taxon && target_taxon.project_id == target_project.id
          raise ArgumentError, 'root_taxon_name_id must belong to target project'
        end
      end

      if @options[:user_id]
        unless User.find_by(id: @options[:user_id])
          raise ArgumentError, 'user_id must be a valid user'
        end
      end
    end

    def run_migration
      migrator = ProjectUnification::Migrator.new(
        source_project_id: source_project.id,
        target_project_id: target_project.id,
        @options
      )

      migration_results = migrator.migrate_all

      @results[:statistics] = migration_results[:statistics]
      @results[:details_by_model] = migration_results[:details_by_model]
      @results[:conflicts].concat(migration_results[:conflicts])
      @results[:errors].concat(migration_results[:errors])

      # Run unify on records that need it - both sides are now in the target
      # project, so Shared::Unify works without cross-project restrictions.
      run_cleanup(migration_results[:merge_registry] || [])

      # Rebuild cached fields unless skipped
      unless @options[:skip_cached_rebuild] || @options[:preview]
        rebuilder = ProjectUnification::CachedRebuilder.new(target_project.id)
        rebuild_results = rebuilder.rebuild_all
        @results[:cached_rebuild] = rebuild_results
      end
    end

    # Iterate the merge registry produced by Phase 1 and call Shared::Unify#unify
    # on each pair.  Failures are collected as errors (not raised) so one bad pair
    # does not abort the remaining cleanup.
    def run_cleanup(merge_registry)
      merge_registry.each do |entry|
        klass   = entry[:model].constantize
        target  = klass.find(entry[:target_id])
        renamed = klass.find(entry[:renamed_id])
        result  = target.unify(renamed, cutoff: 1000)
        next if result[:result][:unified]
        @results[:errors] << {
          model: entry[:model],
          error: "Post-migration unify failed for #{entry[:model]} ID #{entry[:renamed_id]}: #{result[:result][:message]}"
        }
      end
    end
  end
end
