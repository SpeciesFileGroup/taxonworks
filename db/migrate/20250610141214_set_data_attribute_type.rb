class SetDataAttributeType < ActiveRecord::Migration[7.2]
  def change
    d = DataAttribute.where(type: 'DataAttribute')
    d.find_each do |i|
      # DataAttributes that were created with base type were created from the
      # UI, where only InternalAttributes can be created.
      i.update_column(:type, 'InternalAttribute')
    end
  end
end
