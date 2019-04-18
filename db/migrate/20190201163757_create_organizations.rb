class CreateOrganizations < ActiveRecord::Migration[5.2]
  def change
    create_table :organizations do |t|
      t.string :name, null: false, index: true
      t.string :alternate_name
      t.text :description
      t.text :disambiguating_description
      t.string :address
      t.string :email
      t.string :telephone
      t.string :duns
      t.string :global_location_number
      t.string :legal_name
      t.integer :same_as_id

      t.integer :area_served_id
      t.integer :department_id
      t.integer :parent_organization_id

      t.integer :created_by_id, null: false, index: true
      t.integer :updated_by_id, null: false, index: true
      t.timestamps null: false
    end

    add_foreign_key :organizations, :organizations, column: :same_as_id
    add_foreign_key :organizations, :organizations, column: :department_id 
    add_foreign_key :organizations, :organizations, column: :parent_organization_id 
    add_foreign_key :organizations, :geographic_areas, column: :area_served_id 
    
    add_foreign_key :organizations, :users, column: :created_by_id 
    add_foreign_key :organizations, :users, column: :updated_by_id 
  end
end
