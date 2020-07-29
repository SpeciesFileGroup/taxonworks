class CreateTblFileUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :tblFileUsers, primary_key: :FileUserID do |t|
      t.integer :AuthUserID
      t.integer :FileID
      t.integer :Access
      t.datetime :LastLogin
      t.integer :NumLogins
      t.datetime :LastEdit
      t.integer :NumEdits
      t.datetime :CreatedOn
      t.integer :CreatedBy

      t.index :AuthUserID
      t.index :FileID
      t.index :CreatedBy
    end
  end
end
