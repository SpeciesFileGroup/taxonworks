require 'rails_helper'

describe Queries::Extract::Autocomplete, type: :model do
  let!(:extract) { FactoryBot.create(:valid_extract) }

  let(:other_project) { FactoryBot.create(:valid_project, name: 'other') }

  specify '#autocomplete_otu_taxon_name_id_determined_as' do
    p = Protonym.create!(
      name: 'Zzzus',
      rank_class: Ranks.lookup(:iczn, :genus),
      parent: FactoryBot.create(:root_taxon_name)
    )
    o = Otu.create!(taxon_name: p)
    d = FactoryBot.create(:valid_taxon_determination, otu: o)
    e = FactoryBot.create(:valid_extract, origin: d.biological_collection_object)

    FactoryBot.create(:valid_extract) # not this one

    query = Queries::Extract::Autocomplete.new('zzu', project_id: Current.project_id )
    expect(query.autocomplete_otu_taxon_name_id_determined_as.map(&:id)).to contain_exactly(e.id)
  end

  specify 'by taxon_name, partially' do
    p = Protonym.create!(
      name: 'Zzzus',
      rank_class: Ranks.lookup(:iczn, :genus),
      parent: FactoryBot.create(:root_taxon_name)
    )
    o = Otu.create!(taxon_name: p)
    d = FactoryBot.create(:valid_taxon_determination, otu: o)
    e = FactoryBot.create(:valid_extract, origin: d.biological_collection_object)

    FactoryBot.create(:valid_extract) # not this one

    query = Queries::Extract::Autocomplete.new('zzu', project_id: Current.project_id )
    expect(query.autocomplete.map(&:id)).to contain_exactly(e.id)
  end

  specify 'no match' do
    query = Queries::Extract::Autocomplete.new('zzz')
    expect(query.autocomplete).to be_empty
  end

  specify '#id, #project_id' do
    FactoryBot.create(:valid_extract, project: other_project) # not this one
    q = Queries::Extract::Autocomplete.new(extract.id.to_s, project_id: Current.project_id)
    expect(q.autocomplete).to contain_exactly(extract)
  end

end
