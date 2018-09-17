require 'rails_helper'

describe Queries::BiologicalAssociation::Filter, type: :model do

  let(:o1) { FactoryBot.create(:valid_otu) }
  let(:o2) { FactoryBot.create(:valid_otu) }
  let(:o3) { FactoryBot.create(:valid_specimen) }

  let!(:r1) { FactoryBot.create(:valid_biological_relationship) } 
  let!(:r2) { FactoryBot.create(:valid_biological_relationship) } 

  let!(:ba1) { BiologicalAssociation.create!(biological_association_subject: o1, biological_association_object: o2, biological_relationship: r1) }
  let!(:ba2) { BiologicalAssociation.create!(biological_association_subject: o1, biological_association_object: o3, biological_relationship: r1) }
  let!(:ba3) { BiologicalAssociation.create!(biological_association_subject: o2, biological_association_object: o3, biological_relationship: r2) }

  let(:query) { Queries::BiologicalAssociation::Filter }

  context '#matching_global_id' do
    specify 'by #subject_global_id' do
      o = {subject_global_id: o1.to_global_id.to_s}
      expect(query.new(o).all.map(&:id)).to contain_exactly(ba1.id, ba2.id )
    end

    specify 'by #object_global_id' do
      o = {object_global_id: o2.to_global_id.to_s}
      expect(query.new(o).all.map(&:id)).to contain_exactly(ba1.id)
    end

    specify 'by both global_ids' do
      o = {subject_global_id: o1.to_global_id.to_s, object_global_id: o3.to_global_id.to_s}
      expect(query.new(o).all.map(&:id)).to contain_exactly(ba2.id)
    end

    specify 'matching_any_global_id' do
      o = {any_global_id: o2.to_global_id.to_s}
      expect(query.new(o).all.map(&:id)).to contain_exactly(ba1.id, ba3.id)
    end

    specify 'by #biological_relationship_id' do
      o = {biological_relationship_id: r1.id}
      expect(query.new(o).all.map(&:id)).to contain_exactly(ba1.id, ba2.id)
    end



  end

end
