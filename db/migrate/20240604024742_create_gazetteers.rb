class CreateGazetteers < ActiveRecord::Migration[7.1]
  def change
    create_table :gazetteers do |t|

      t.timestamps
    end
  end
end
