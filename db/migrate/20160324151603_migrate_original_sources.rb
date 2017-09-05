class MigrateOriginalSources < ActiveRecord::Migration[4.2]

  ActiveRecord::Base.transaction do
    [TaxonName, TaxonNameRelationship,Georeference, BiologicalAssociationsGraph, TypeMaterial].each do |k|
      k.all.each do |r|
        next if r.source_id.nil?

        if t = Citation.where(citation_object: r, source_id: r.source_id, project_id: r.project_id).first
          if !t.is_original?
            t.is_original = true
            t.save
          end
        else
          c = Citation.new(is_original: true, citation_object: r, source_id: r.source_id, project_id: r.project_id, created_by_id: r.created_by_id, updated_by_id: r.updated_by_id)
          if c.valid?
            c.save!
          else
            puts "not saved, probably duplicate?! -- #{c.errors.full_messages}"
          end
        end
      end
    end
  end
end
