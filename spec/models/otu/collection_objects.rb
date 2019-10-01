require 'rails_helper'

describe Otu, type: :model, group: :otu do

  let(:o1) { Otu.create!(name: 'first') }
  let(:o2) { Otu.create!(name: 'second') }
  let(:o3) { Otu.create!(name: 'third') }

  context 'taxon determinations' do

    let(:co) { FactoryBot.create(:valid_collection_object) } 

    let!(:td1) { FactoryBot.create(:valid_taxon_determination, otu: o1, biological_collection_object: co) } 
    let!(:td2) { FactoryBot.create(:valid_taxon_determination, otu: o2, biological_collection_object: co) } 
    let!(:td3) { FactoryBot.create(:valid_taxon_determination, otu: o3, biological_collection_object: co) } 

    specify '#current_collection_objects 1' do
      expect(o1.current_collection_objects).to contain_exactly()
    end

    specify '#current_collection_objects 2' do
      expect(o2.current_collection_objects).to contain_exactly()
    end

    specify '#current_collection_objects 3' do
      expect(o3.current_collection_objects).to contain_exactly(co)
    end

    specify '#current_collection_objects after moving' do
      td2.move_to_top
      expect(o2.current_collection_objects).to contain_exactly(co)
    end

    specify '#current_collection_objects after destroy' do
      td3.destroy
      expect(o2.current_collection_objects).to contain_exactly(co)
    end

    specify '#current_collection_objects after destroy 2' do
      td1.destroy
      expect(o3.current_collection_objects).to contain_exactly(co)
    end

  end

end
