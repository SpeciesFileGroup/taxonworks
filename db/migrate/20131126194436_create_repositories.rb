class CreateRepositories < ActiveRecord::Migration[4.2]
  def change
    create_table :repositories do |t|
      t.string :name
      t.string :url
      t.string :acronym
      t.string :status
      t.string :institutional_LSID
      t.boolean :is_index_herbarioum_record

      t.timestamps
    end
  end
end
