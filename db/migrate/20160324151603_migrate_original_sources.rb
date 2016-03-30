class MigrateOriginalSources < ActiveRecord::Migration

  ActiveRecord::Base.transaction do
    [TaxonName, TaxonNameRelationship,Georeference, BiologicalAssociationsGraph, TypeMaterial].each do |k|
      k.all.each do |r|
        next if r.source_id.nil?
        Citation.create!(is_original: true, citation_object: r, source_id: r.source_id)
      end
    end
  end

end
