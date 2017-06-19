class AddExtensionFuzzyMatchStr < ActiveRecord::Migration
  def up
    execute 'CREATE EXTENSION IF NOT EXISTS fuzzystrmatch'
  end

  def down
    execute 'DROP EXTENSION fuzzystrmatch'
  end
end
