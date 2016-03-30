class MigrateOriginalSources < ActiveRecord::Migration

  ActiveRecord::Base.transaction do
    [TaxonName, TaxonNameRelationship,Georeference, BiologicalAssociationsGraph, TypeMaterial].each do |k|
      k.all.each do |r|
        next if r.source_id.nil?
        Citation.create!(is_original: true, citation_object: r, source_id: r.source_id, project_id: r.project_id, created_by_id: r.created_by_id, updated_by_id: r.updated_by_id)
      end
    end
  end

end
