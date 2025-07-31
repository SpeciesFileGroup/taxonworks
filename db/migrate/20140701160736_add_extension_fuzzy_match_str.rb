class AddExtensionFuzzyMatchStr < ActiveRecord::Migration[4.2]
  def change
    enable_extension 'fuzzystrmatch'
  end
end
