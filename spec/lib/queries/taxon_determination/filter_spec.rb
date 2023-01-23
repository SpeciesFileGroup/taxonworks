require 'rails_helper'
require 'support/shared_contexts/shared_geo'

describe Queries::TaxonDetermination::Filter, type: :model, group: [:collection_objects, :otus] do

  let(:p1) { FactoryBot.create(:valid_person) }
  let(:p2) { FactoryBot.create(:valid_person) }

  let(:o1) { FactoryBot.create(:valid_otu) }
  let(:o2) { FactoryBot.create(:valid_otu) }

  let(:s1) { FactoryBot.create(:valid_specimen) }
  let(:s2) { FactoryBot.create(:valid_lot) }

  let!(:td1) { FactoryBot.create(:valid_taxon_determination, otu: o1, biological_collection_object: s1 ) }
  let!(:td2) { FactoryBot.create(:valid_taxon_determination, otu: o2, biological_collection_object: s2 ) }
  let!(:td3) { FactoryBot.create(:valid_taxon_determination, otu: o2, biological_collection_object: s1 ) }

  let!(:d2) { Determiner.create(role_object: td3, person: p1) }
  let!(:d3) { Determiner.create(role_object: td3, person: p2) }

  let(:query) { Queries::TaxonDetermination::Filter.new() }

  specify "by #otu_id" do
    query.otu_id = [o1.id]
    expect(query.all.map(&:id)).to contain_exactly(td1.id)
  end

  specify "by #collection_object_id" do
    query.collection_object_id = [s1.id]
    expect(query.all.map(&:id)).to contain_exactly(td1.id, td3.id)
  end

  specify "by #determiner_id" do
    query.determiner_id = [d2.id]
    expect(query.all.map(&:id)).to contain_exactly(td3.id)
  end


end
