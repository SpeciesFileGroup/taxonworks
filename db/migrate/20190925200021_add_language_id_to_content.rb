class AddLanguageIdToContent < ActiveRecord::Migration[5.2]
  def change
    add_reference :contents, :language, foreign_key: true
  end
end
