require 'rails_helper'

describe Queries::CollectionObject::Autocomplete, type: :model do

  context 'restrict_to' do
    let(:otu) { FactoryBot.create(:valid_otu, name: 'Zzyzxdetermined') }
    let!(:o1) { FactoryBot.create(:valid_specimen) }
    let!(:o2) { FactoryBot.create(:valid_specimen) }

    before do
      [o1, o2].each do |o|
        FactoryBot.create(:valid_taxon_determination, otu:, taxon_determination_object: o)
      end
    end

    specify 'restricts results to the given CollectionObjects' do
      q = Queries::CollectionObject::Autocomplete.new('Zzyzxdetermined', project_id:, restrict_to: ::CollectionObject.where(id: o2.id))
      expect(q.autocomplete).to contain_exactly(o2)
    end

    specify 'restricts exact id matches' do
      q = Queries::CollectionObject::Autocomplete.new(o1.id.to_s, project_id:, restrict_to: ::CollectionObject.where(id: o2.id))
      expect(q.autocomplete).to_not include(o1)
    end

    specify 'raises when the relation is of another model' do
      q = Queries::CollectionObject::Autocomplete.new('Zzyzxdetermined', project_id:, restrict_to: Otu.all)
      expect { q.autocomplete }.to raise_error(ArgumentError, /Otu/)
    end

    specify 'is not applied when nil' do
      q = Queries::CollectionObject::Autocomplete.new('Zzyzxdetermined', project_id:, restrict_to: nil)
      expect(q.autocomplete).to include(o1, o2)
    end
  end

  context 'limit' do
    specify 'defaults to 40' do
      expect(Queries::CollectionObject::Autocomplete.new('Zzyzx', project_id:).limit).to eq(40)
    end

    specify 'caps results' do
      otu = FactoryBot.create(:valid_otu, name: 'Zzyzxlimit')
      3.times do
        FactoryBot.create(:valid_taxon_determination, otu:, taxon_determination_object: FactoryBot.create(:valid_specimen))
      end

      expect(Queries::CollectionObject::Autocomplete.new('Zzyzxlimit', project_id:).autocomplete.size).to eq(3)
      expect(Queries::CollectionObject::Autocomplete.new('Zzyzxlimit', project_id:, limit: 2).autocomplete.size).to eq(2)
    end
  end

end
