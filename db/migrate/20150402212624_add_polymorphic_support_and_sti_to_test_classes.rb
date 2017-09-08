class AddPolymorphicSupportAndStiToTestClasses < ActiveRecord::Migration[4.2]
  def change
    add_column :test_classes, :type, :string
    add_column :test_classes, :sti_id,   :integer
    add_column :test_classes, :sti_type, :string
  end
end
