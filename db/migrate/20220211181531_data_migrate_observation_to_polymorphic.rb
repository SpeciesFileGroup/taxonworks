class DataMigrateObservationToPolymorphic < ActiveRecord::Migration[6.1]

  def change
    ::Observation.all.each do |o|
      if !o.collection_object_id.nil?
        o.update!(observation_object_id: o.collection_object_id, observation_object_type: 'CollectionObject')
      elsif !o.otu_id.nil?
        o.update!(observation_object_id: o.otu_id, observation_object_type: 'Otu')
      else
        puts "!! Bad observation: #{o.id}, not linked to object" 
      end
    end
  end
end
