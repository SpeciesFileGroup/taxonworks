class AddPolymorphicSupportAndStiToTestClasses < ActiveRecord::Migration
  def change
    add_column :test_classes, :type, :string
    add_column :test_classes, :sti_id,   :integer
    add_column :test_classes, :sti_type, :string
  end
end
