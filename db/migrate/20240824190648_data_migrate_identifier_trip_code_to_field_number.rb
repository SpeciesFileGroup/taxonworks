class DataMigrateIdentifierTripCodeToFieldNumber < ActiveRecord::Migration[7.1]
  def change

    Identifier::Local::TripCode.update_all(type: 'Identifier::Local::FieldNumber')

  end
end
