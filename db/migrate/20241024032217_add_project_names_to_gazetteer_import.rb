class AddProjectNamesToGazetteerImport < ActiveRecord::Migration[7.1]
  def change
    add_column :gazetteer_imports, :project_names, :string
  end
end
