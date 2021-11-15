require 'rails_helper'

describe Queries::BiologicalAssociation::Filter, type: :model, group: [:filter] do

  let(:o1) { Otu.create!(name: 'small') }
  let(:o2) { Otu.create!(name: 'big') }
  let(:o3) { Specimen.create! }

  let!(:r1) { FactoryBot.create(:valid_biological_relationship) } 
  let!(:r2) { FactoryBot.create(:valid_biological_relationship) } 

  let!(:ba1) { BiologicalAssociation.create!(biological_association_subject: o1, biological_association_object: o2, biological_relationship: r1) }
  let!(:ba2) { BiologicalAssociation.create!(biological_association_subject: o1, biological_association_object: o3, biological_relationship: r1) }
  let!(:ba3) { BiologicalAssociation.create!(biological_association_subject: o2, biological_association_object: o3, biological_relationship: r2) }

  let(:root) { FactoryBot.create(:root_taxon_name) }

  let(:query) { Queries::BiologicalAssociation::Filter }

    specify 'by #subject_global_id' do
      o = {subject_global_id: o1.to_global_id.to_s}
      expect(query.new(o).all.map(&:id)).to contain_exactly(ba1.id, ba2.id )
    end

    specify '#object_global_id' do
      o = {object_global_id: o2.to_global_id.to_s}
      expect(query.new(o).all.map(&:id)).to contain_exactly(ba1.id)
    end

    specify '#subject_global_id and #object_global_id' do
      o = {subject_global_id: o1.to_global_id.to_s, object_global_id: o3.to_global_id.to_s}
      expect(query.new(o).all.map(&:id)).to contain_exactly(ba2.id)
    end

    specify '#any_global_id' do
      o = {any_global_id: o2.to_global_id.to_s}
      expect(query.new(o).all.map(&:id)).to contain_exactly(ba1.id, ba3.id)
    end

    specify '#biological_relationship_id' do
      o = {biological_relationship_id: r1.id}
      expect(query.new(o).all.map(&:id)).to contain_exactly(ba1.id, ba2.id)
    end

    specify '#taxon_name_query (both)' do
      g1 =  Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, :genus), parent: root)
      s1 =  Protonym.create!(name: 'eus', rank_class: Ranks.lookup(:iczn, :species), parent: g1)

      g2 =  Protonym.create!(name: 'Cus', rank_class: Ranks.lookup(:iczn, :genus), parent: root)
      s2 =  Protonym.create!(name: 'dus', rank_class: Ranks.lookup(:iczn, :species), parent: g2)

      o1.update(taxon_name_id: s1)

      o = {parent_id: g1.id}
      
      expect(query.new(o).all.map(&:id)).to contain_exactly(ba1.id, ba2.id)
  end
end
