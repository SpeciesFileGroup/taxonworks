class AddCachedNumericIdentifierToIdentifier < ActiveRecord::Migration[6.1]

  # !! If existing data are present then this must be followed with running a Rake task like:
  #   export PARALLEL_PROCESSOR_COUNT=4 && rake tw:maintenance:identifiers:rebuild_identifiers_cache
  def change
    add_column :identifiers, :cached_numeric_identifier, :float # use float for speed and potential decimal identifiers
    add_index :identifiers, :cached_numeric_identifier
  end
end
