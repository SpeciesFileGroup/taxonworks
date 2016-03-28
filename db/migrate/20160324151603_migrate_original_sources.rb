class MigrateOriginalSources < ActiveRecord::Migration

  ActiveRecord::Base.transaction do
    [TaxonName, TaxonNameRelationship,Georeference, BiologicalAssociationsGraph, TypeMaterial].each do |k|
      k.joins(:source).all.each do |r|
        Citation.create!(is_original: true, citation_object: r, source_id: r.source_id)
      end
    end
  end

end
