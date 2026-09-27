require 'rails_helper'

describe Queries::AssertedDistribution::Autocomplete, type: :model do

  specify '#autocomplete_biological_association' do
    subject_otu = FactoryBot.create(:valid_otu, name: 'Zzyzxbasubjectotu')
    ba = FactoryBot.create(:valid_biological_association, biological_association_subject: subject_otu)
    ad = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: ba)

    q = Queries::AssertedDistribution::Autocomplete.new('Zzyzxbasubjectotu', project_id: project_id)
    expect(q.autocomplete_biological_association.to_a).to contain_exactly(ad)
  end

  specify '#autocomplete includes biological association matches' do
    subject_otu = FactoryBot.create(:valid_otu, name: 'Zzyzxbasubjectotu')
    ba = FactoryBot.create(:valid_biological_association, biological_association_subject: subject_otu)
    ad = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: ba)

    q = Queries::AssertedDistribution::Autocomplete.new('Zzyzxbasubjectotu', project_id: project_id)
    expect(q.autocomplete).to include(ad)
  end

  specify '#autocomplete_biological_association with no matching biological association' do
    q = Queries::AssertedDistribution::Autocomplete.new('Zzyzxnomatchatall', project_id: project_id)
    expect(q.autocomplete_biological_association.to_a).to eq([])
  end

end
