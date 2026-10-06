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

  specify '#autocomplete_biological_association excludes biological associations without asserted distributions' do
    subject_otu = FactoryBot.create(:valid_otu, name: 'Zzyzxbasubjectotu')
    FactoryBot.create(:valid_biological_association, biological_association_subject: subject_otu)
    ba = FactoryBot.create(:valid_biological_association, biological_association_subject: subject_otu)
    FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: ba)

    expect(Queries::BiologicalAssociation::Autocomplete).to receive(:new)
      .with('Zzyzxbasubjectotu', hash_including(restrict_to: satisfy { |r| r.to_a == [ba] }))
      .and_call_original

    Queries::AssertedDistribution::Autocomplete.new('Zzyzxbasubjectotu', project_id:)
      .autocomplete_biological_association
  end

  specify '#autocomplete_biological_association with more restricting ids than LITERAL_RESTRICTION_MAX' do
    stub_const('Queries::AssertedDistribution::Autocomplete::LITERAL_RESTRICTION_MAX', 0)
    subject_otu = FactoryBot.create(:valid_otu, name: 'Zzyzxbasubjectotu')
    FactoryBot.create(:valid_biological_association, biological_association_subject: subject_otu)
    ba = FactoryBot.create(:valid_biological_association, biological_association_subject: subject_otu)
    ad = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: ba)

    q = Queries::AssertedDistribution::Autocomplete.new('Zzyzxbasubjectotu', project_id:)
    expect(q.autocomplete_biological_association.to_a).to contain_exactly(ad)
  end

  specify '#autocomplete_biological_association does not run the BA autocomplete when no BA has an asserted distribution' do
    subject_otu = FactoryBot.create(:valid_otu, name: 'Zzyzxbasubjectotu')
    FactoryBot.create(:valid_biological_association, biological_association_subject: subject_otu)

    expect(Queries::BiologicalAssociation::Autocomplete).to_not receive(:new)

    q = Queries::AssertedDistribution::Autocomplete.new('Zzyzxbasubjectotu', project_id:)
    expect(q.autocomplete_biological_association).to be_nil
  end

  specify '#autocomplete_biological_association keeps the BA autocomplete ranking' do
    # Created first, so likely first in an unordered result
    weaker_otu = FactoryBot.create(:valid_otu, name: 'Zzyzxrankedotu weaker')
    weaker_ba = FactoryBot.create(:valid_biological_association, biological_association_subject: weaker_otu)
    weaker_ad = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: weaker_ba)

    exact_otu = FactoryBot.create(:valid_otu, name: 'Zzyzxrankedotu')
    exact_ba = FactoryBot.create(:valid_biological_association, biological_association_subject: exact_otu)
    exact_ad = FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: exact_ba)

    expect(
      Queries::BiologicalAssociation::Autocomplete.new('Zzyzxrankedotu', project_id:).autocomplete
    ).to eq([exact_ba, weaker_ba])

    q = Queries::AssertedDistribution::Autocomplete.new('Zzyzxrankedotu', project_id:)
    expect(q.autocomplete_biological_association.to_a).to eq([exact_ad, weaker_ad])
  end

end
