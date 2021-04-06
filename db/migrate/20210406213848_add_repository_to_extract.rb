class AddRepositoryToExtract < ActiveRecord::Migration[6.0]
  def change
    add_reference :extracts, :repository, foreign_key: true, index: true
  end
end
