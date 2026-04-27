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
    # @option options [Integer] :root_taxon_name_id Optional target parent for TaxonName hierarchy
    # @option options [Boolean] :preview If true, rolls back all changes (default: true)
    # @option options [Boolean] :skip_cached_rebuild Skip rebuilding cached fields (default: false)
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
        errors: [],
        rollback_performed: false
      }
    end

    # Execute the unification process
    # @return [Hash] Results hash with detailed statistics and error information
    def unify
      @results[:started_at] = Time.now

      validate_prerequisites!

      Project.transaction do
        run_migration

        @results[:unified] = @results[:errors].empty?

        if @options[:preview] || @results[:errors].any?
          @results[:rollback_performed] = true
          raise ActiveRecord::Rollback
        end
      rescue ActiveRecord::Rollback
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
    end

    def run_migration
      migrator = ProjectUnification::Migrator.new(
        source_project.id,
        target_project.id,
        @options
      )

      migration_results = migrator.migrate_all

      @results[:statistics] = migration_results[:statistics]
      @results[:details_by_model] = migration_results[:details_by_model]
      @results[:errors].concat(migration_results[:errors])

      # Rebuild cached fields unless skipped
      unless @options[:skip_cached_rebuild] || @options[:preview]
        rebuilder = ProjectUnification::CachedRebuilder.new(target_project.id)
        rebuild_results = rebuilder.rebuild_all
        @results[:cached_rebuild] = rebuild_results
      end
    end
  end
end
