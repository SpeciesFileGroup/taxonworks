class AddPostgresSqlNotNullConstraintsToPolymorphicsI < ActiveRecord::Migration
  def change

    Note.connection.execute('ALTER TABLE notes ALTER COLUMN note_object_type SET NOT NULL;')
    Note.connection.execute('ALTER TABLE notes ALTER COLUMN note_object_id SET NOT NULL;')

    Identifier.connection.execute('ALTER TABLE identifiers ALTER COLUMN identified_object_id SET NOT NULL;')
    Identifier.connection.execute('ALTER TABLE identifiers ALTER COLUMN identified_object_type SET NOT NULL;')

    DataAttribute.connection.execute('ALTER TABLE data_attributes ALTER COLUMN attribute_subject_id SET NOT NULL;')
    DataAttribute.connection.execute('ALTER TABLE data_attributes ALTER COLUMN attribute_subject_type SET NOT NULL;')

    Citation.connection.execute('ALTER TABLE citations ALTER COLUMN citation_object_id SET NOT NULL;')
    Citation.connection.execute('ALTER TABLE citations ALTER COLUMN citation_object_type SET NOT NULL;')

    AlternateValue.connection.execute('ALTER TABLE alternate_values ALTER COLUMN alternate_object_id SET NOT NULL;')
    AlternateValue.connection.execute('ALTER TABLE alternate_values ALTER COLUMN alternate_object_type SET NOT NULL;')

    ContainerItem.connection.execute('ALTER TABLE container_items ALTER COLUMN contained_object_id SET NOT NULL;')
    ContainerItem.connection.execute('ALTER TABLE container_items ALTER COLUMN contained_object_type SET NOT NULL;')

    PinboardItem.connection.execute('ALTER TABLE pinboard_items ALTER COLUMN pinned_object_id SET NOT NULL;')
    PinboardItem.connection.execute('ALTER TABLE pinboard_items ALTER COLUMN pinned_object_type SET NOT NULL;')

    Role.connection.execute('ALTER TABLE roles ALTER COLUMN role_object_id SET NOT NULL;')
    Role.connection.execute('ALTER TABLE roles ALTER COLUMN role_object_type SET NOT NULL;')
  
    Tag.connection.execute('ALTER TABLE tags ALTER COLUMN tag_object_id SET NOT NULL;')
    Tag.connection.execute('ALTER TABLE tags ALTER COLUMN tag_object_type SET NOT NULL;')

  end
end
