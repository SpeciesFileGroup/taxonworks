class ModifySourceDateFields < ActiveRecord::Migration
  def change
    add_column :sources, :year_suffix, :string
    reversible do |dir|
      change_table :sources do |t|
        dir.up do
          t.change :day,  :integer, :limit=>1 # sets day to tinyint (<127)
          t.change :year, :integer, :limit=>2 # sets year to smallint (<32767)
        end

        dir.down do
          t.change :day, :integer
          t.change :year, :integer
        end
      end
    end
    #change_column :sources, :day, :integer, :limit=>1
    #change_column :sources, :year, :integer, :limit=>2

   end
end
