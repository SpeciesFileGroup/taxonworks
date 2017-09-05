class AddExtensionFuzzyMatchStr < ActiveRecord::Migration[4.2]
  def up
    execute 'CREATE EXTENSION IF NOT EXISTS fuzzystrmatch'
  end

  def down
    execute 'DROP EXTENSION fuzzystrmatch'
  end
end
