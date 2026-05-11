# Special handler for TaxonName model during project unification
#
# TaxonNames require special handling due to:
# - closure_tree hierarchical structure
# - Each project having a unique Root taxon
# - Complex parent-child relationships
# - Need to preserve hierarchy integrity
#
module ProjectUnification
  class TaxonNameHandler
    attr_reader :source_project_id, :target_project_id, :options

    def initialize(source_project_id, target_project_id, options = {})
      @source_project_id = source_project_id
      @target_project_id = target_project_id
      @options = options
    end

    # Migrate TaxonName hierarchy from source to target project
    # @return [Hash] Migration results
    def migrate
      source_project = Project.find(source_project_id)
      target_project = Project.find(target_project_id)

      source_root = source_project.root_taxon_name
      target_parent = determine_target_parent(target_project)

      stats = {
        track: :special,
        model: 'TaxonName',
        migrated: 0,
        source_root_id: source_root.id,
        target_parent_id: target_parent.id,
        closure_tree_rebuilt: false,
        errors: []
      }

      begin
        # Count all descendants before moving (excluding root)
        total_count = count_descendants(source_root)

        # Skip if there are no children to migrate (only root exists)
        if total_count == 0
          stats[:migrated] = 0
          stats[:note] = 'No TaxonNames to migrate (only root exists)'
          return stats
        end

        # Temporarily disable cached field updates for performance
        disable_cached_callbacks do
          move_children_to_target(source_root, target_parent)
          update_all_descendants_project_id(source_root)

          stats[:migrated] = total_count

          # Rebuild only target_parent's subtree — all source names now hang off it.
          # TaxonName.rebuild! is O(all projects); instance rebuild! is O(moved subtree).
          target_parent.rebuild!
          stats[:closure_tree_rebuilt] = true
        end
      rescue => e
        stats[:errors] << {
          error: e.message,
          backtrace: e.backtrace.first(3)
        }
      end

      stats
    end

    private

    # Determine where to attach the source hierarchy in the target project
    def determine_target_parent(target_project)
      if options[:root_taxon_name_id]
        TaxonName.find(options[:root_taxon_name_id])
      else
        target_project.root_taxon_name
      end
    end

    # Count all descendants of source root (excluding root itself)
    def count_descendants(source_root)
      source_root.descendants.unscope(:order).count
    end

    # Move all direct children of source root to target parent
    # Updates both parent_id AND project_id atomically
    def move_children_to_target(source_root, target_parent)
      children = source_root.children.unscope(:order)

      children.each do |child|
        child.update_columns(
          parent_id: target_parent.id,
          project_id: target_project_id
        )
      end
    end

    # Update project_id for all descendants in one bulk operation
    def update_all_descendants_project_id(source_root)
      # Get all descendants except direct children (already updated in move_children_to_target)
      # Use closure_tree's descendants method with unscope for performance
      descendants = source_root.descendants.unscope(:order).where.not(parent_id: source_root.id)

      return if descendants.empty?

      # Bulk update all descendants' project_id via ActiveRecord for performance
      TaxonName.where(id: descendants.select(:id)).update_all(project_id: target_project_id)
    end

    # Temporarily disable cached field callbacks for performance
    def disable_cached_callbacks
      Thread.current[:tw_taxon_name_no_cached] = true
      yield
    ensure
      Thread.current[:tw_taxon_name_no_cached] = nil
    end
  end
end
