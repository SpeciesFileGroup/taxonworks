class ChgSrcAbstract2text < ActiveRecord::Migration
  def change
    reversible do |dir|
      change_table :sources do |t|
        dir.up do
          t.change :abstract, :text
        end

        dir.down do
          t.change :abstract, :string
        end
      end
    end
  end
end
