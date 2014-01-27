class CreateCitationTopics < ActiveRecord::Migration
  def change
    create_table :citation_topics do |t|
      t.references :topic, index: true
      t.references :citation, index: true
      t.string :pages

      t.timestamps
    end
  end
end
