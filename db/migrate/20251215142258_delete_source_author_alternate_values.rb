class DeleteSourceAuthorAlternateValues < ActiveRecord::Migration[7.2]
  def up
    # Delete all AlternateValue records for Source objects where the attribute is 'author' or 'editor'
    count = AlternateValue
      .where(alternate_value_object_type: 'Source')
      .where(alternate_value_object_attribute: ['author', 'editor'])
      .delete_all

    puts "Deleted #{count} AlternateValue records for Source.author and Source.editor"
  end

  def down
    # This is a data deletion migration and cannot be reversed
    raise ActiveRecord::IrreversibleMigration
  end
end
