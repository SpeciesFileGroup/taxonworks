class PopulateBiologicalAssociationIndex < ActiveRecord::Migration[7.2]
  def up
    say_with_time "Populating biological_association_index for existing records" do
      count = 0

      BiologicalAssociation.where.missing(:biological_association_index).find_each do |ba|
        ba.no_biological_association_index = true
        ba.set_biological_association_index
        count += 1

        print '.' if count % 100 == 0
      end

      puts "\nPopulated #{count} index records"
      count
    end
  end

  def down
    say_with_time "Removing all biological_association_index records" do
      count = BiologicalAssociationIndex.count
      BiologicalAssociationIndex.delete_all
      count
    end
  end
end
