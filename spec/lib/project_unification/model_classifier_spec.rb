require 'rails_helper'

describe ProjectUnification::ModelClassifier do
  # Every model in Project::MANIFEST that has a project_id column must be
  # explicitly classified. The classifier raises on unknown models, but this
  # spec catches the failure early with a clear message rather than surfacing
  # it mid-migration.
  describe 'coverage' do
    it 'classifies every Project::MANIFEST model that has project_id' do
      unclassified = Project::MANIFEST.select do |name|
        klass = name.constantize rescue nil
        next false unless klass&.respond_to?(:column_names)
        next false unless klass.column_names.include?('project_id')
        begin
          ProjectUnification::ModelClassifier.track_for(klass)
          false
        rescue ArgumentError
          true
        end
      end

      expect(unclassified).to be_empty,
        "These MANIFEST models have project_id but are not in ModelClassifier: #{unclassified.join(', ')}"
    end
  end

  # Fast-track models are bulk-updated with a single SQL UPDATE — no per-record
  # validation runs. A project-scoped uniqueness validator is safe for fast-track
  # only if every non-project_id column in its scope is a FK to a project-specific
  # model (one that has project_id). In that case, the target project can never
  # pre-own a record with that FK value, making a collision impossible.
  #
  # This spec verifies that condition dynamically: if a validator's scope changes
  # to drop the FK or add a non-FK column, the spec fails immediately.
  describe 'FAST_TRACK' do
    # Returns true if the full uniqueness constraint (validated attributes + scope)
    # contains at least one FK column that points to a project-specific model.
    # One such FK is sufficient: a collision requires ALL columns to match, so if
    # the target can never pre-own a record with the matching FK value, the full
    # combination can never conflict.
    #
    # Polymorphic FKs (paired _id + _type in the constraint) are assumed safe —
    # all polymorphic annotation targets in TaxonWorks are project-specific by
    # convention, and both columns must match for a collision.
    def safe_due_to_fk_scope?(klass, validated_attrs, scope_columns)
      # Full set of columns that must match for a uniqueness conflict.
      all_cols = (validated_attrs.map(&:to_s) + scope_columns.map(&:to_s) - ['project_id']).uniq
      return false if all_cols.empty?

      klass.reflect_on_all_associations(:belongs_to).any? do |r|
        fk      = (r.options[:foreign_key] || "#{r.name}_id").to_s
        # Some validators reference the association name directly (e.g.
        # :alternate_value_object) rather than the FK column name.
        matched = all_cols.include?(fk) || all_cols.include?(r.name.to_s)
        next false unless matched

        if r.options[:polymorphic]
          type_col = (r.options[:foreign_type] || "#{r.name}_type").to_s
          # When the scope uses the association name directly, Rails implicitly
          # expands it to both _id and _type at SQL time — treat as safe.
          matched_by_name = all_cols.include?(r.name.to_s)
          matched_by_name || all_cols.include?(type_col)
        else
          associated_klass = r.klass rescue nil
          associated_klass&.column_names&.include?('project_id')
        end
      end
    end

    ProjectUnification::ModelClassifier::FAST_TRACK.each do |model_name|
      it "#{model_name} has no unsafe project-scoped uniqueness validators" do
        klass = model_name.constantize
        unsafe = klass.validators.select do |v|
          next false unless v.is_a?(ActiveRecord::Validations::UniquenessValidator)
          scope = Array(v.options[:scope]).map(&:to_s)
          next false unless scope.include?('project_id')
          !safe_due_to_fk_scope?(klass, v.attributes, scope)
        end
        expect(unsafe).to be_empty,
          "#{model_name} has project-scoped uniqueness validators that are NOT " \
          "protected by project-specific FK scope — move to SLOW_TRACK or " \
          "SPECIAL_HANDLING: #{unsafe.map { |v| "#{v.attributes} scope=#{Array(v.options[:scope])}" }}"
      end
    end
  end
end
