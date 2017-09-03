class DataMigrateCachedPeople < ActiveRecord::Migration[4.2]
  def change
    Person.all.each do |p |
      $user_id = p.updated_by_id
      p.save
    end
    $user_id = nil
  end
end
