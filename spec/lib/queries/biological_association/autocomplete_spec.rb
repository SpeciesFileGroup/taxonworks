require 'rails_helper'

describe Queries::BiologicalAssociation::Autocomplete, type: :model do

  specify '#autocomplete_exact_id' do
    ba = FactoryBot.create(:valid_biological_association)
    q = Queries::BiologicalAssociation::Autocomplete.new(ba.id.to_s, project_id: project_id)
    expect(q.autocomplete.first).to eq(ba)
  end

  specify '#autocomplete otu subject match' do
    subject_otu = FactoryBot.create(:valid_otu, name: 'Zzyzxsubjectotu')
    ba = FactoryBot.create(:valid_biological_association, biological_association_subject: subject_otu)

    q = Queries::BiologicalAssociation::Autocomplete.new('Zzyzxsubjectotu', project_id: project_id)
    expect(q.autocomplete).to include(ba)
  end

  specify '#autocomplete otu object match' do
    object_otu = FactoryBot.create(:valid_otu, name: 'Zzyzxobjectotu')
    ba = FactoryBot.create(:valid_biological_association, biological_association_object: object_otu)

    q = Queries::BiologicalAssociation::Autocomplete.new('Zzyzxobjectotu', project_id: project_id)
    expect(q.autocomplete).to include(ba)
  end

  specify '#autocomplete collection_object subject match (via taxon determination)' do
    determined_otu = FactoryBot.create(:valid_otu, name: 'Zzyzxcotaxon')
    collection_object = FactoryBot.create(:valid_specimen)
    FactoryBot.create(:valid_taxon_determination, otu: determined_otu, taxon_determination_object: collection_object)

    ba = FactoryBot.create(:valid_biological_association, biological_association_subject: collection_object)

    q = Queries::BiologicalAssociation::Autocomplete.new('Zzyzxcotaxon', project_id: project_id)
    expect(q.autocomplete).to include(ba)
  end

  specify '#autocomplete collection_object object match (via taxon determination)' do
    determined_otu = FactoryBot.create(:valid_otu, name: 'Zzyzxcotaxonobject')
    collection_object = FactoryBot.create(:valid_specimen)
    FactoryBot.create(:valid_taxon_determination, otu: determined_otu, taxon_determination_object: collection_object)

    ba = FactoryBot.create(:valid_biological_association, biological_association_object: collection_object)

    q = Queries::BiologicalAssociation::Autocomplete.new('Zzyzxcotaxonobject', project_id: project_id)
    expect(q.autocomplete).to include(ba)
  end

  specify '#autocomplete field_occurrence subject match (via taxon determination)' do
    determined_otu = FactoryBot.create(:valid_otu, name: 'Zzyzxfotaxon')
    field_occurrence = FactoryBot.create(:valid_field_occurrence)
    FactoryBot.create(:valid_taxon_determination, otu: determined_otu, taxon_determination_object: field_occurrence)

    ba = FactoryBot.create(:valid_biological_association, biological_association_subject: field_occurrence)

    q = Queries::BiologicalAssociation::Autocomplete.new('Zzyzxfotaxon', project_id: project_id)
    expect(q.autocomplete).to include(ba)
  end

  specify '#autocomplete field_occurrence object match (via taxon determination)' do
    determined_otu = FactoryBot.create(:valid_otu, name: 'Zzyzxfotaxonobject')
    field_occurrence = FactoryBot.create(:valid_field_occurrence)
    FactoryBot.create(:valid_taxon_determination, otu: determined_otu, taxon_determination_object: field_occurrence)

    ba = FactoryBot.create(:valid_biological_association, biological_association_object: field_occurrence)

    q = Queries::BiologicalAssociation::Autocomplete.new('Zzyzxfotaxonobject', project_id: project_id)
    expect(q.autocomplete).to include(ba)
  end

  specify '#autocomplete anatomical_part subject match' do
    anatomical_part = FactoryBot.create(:valid_anatomical_part, name: 'Zzyzxanatomicalpart')
    ba = FactoryBot.create(:valid_biological_association, biological_association_subject: anatomical_part)

    q = Queries::BiologicalAssociation::Autocomplete.new('Zzyzxanatomicalpart', project_id: project_id)
    expect(q.autocomplete).to include(ba)
  end

  specify '#autocomplete anatomical_part object match' do
    anatomical_part = FactoryBot.create(:valid_anatomical_part, name: 'Zzyzxanatomicalpartobject')
    ba = FactoryBot.create(:valid_biological_association, biological_association_object: anatomical_part)

    q = Queries::BiologicalAssociation::Autocomplete.new('Zzyzxanatomicalpartobject', project_id: project_id)
    expect(q.autocomplete).to include(ba)
  end

  specify '#autocomplete biological_relationship match' do
    biological_relationship = FactoryBot.create(:valid_biological_relationship, name: 'Zzyzxrelationship')
    ba = FactoryBot.create(:valid_biological_association, biological_relationship: biological_relationship)

    q = Queries::BiologicalAssociation::Autocomplete.new('Zzyzxrelationship', project_id: project_id)
    expect(q.autocomplete).to include(ba)
  end

  specify '#project_id scopes results' do
    other_project = FactoryBot.create(:valid_project, name: 'other')
    other_otu = FactoryBot.create(:valid_otu, name: 'Zzyzxotherproject', project: other_project)
    other_relationship = FactoryBot.create(:valid_biological_relationship, project: other_project)
    other_object_otu = FactoryBot.create(:valid_otu, name: 'other_otu', project: other_project)

    FactoryBot.create(
      :biological_association,
      biological_relationship: other_relationship,
      biological_association_subject: other_otu,
      biological_association_object: other_object_otu,
      project: other_project
    )

    q = Queries::BiologicalAssociation::Autocomplete.new('Zzyzxotherproject', project_id: project_id)
    expect(q.autocomplete).to be_empty
  end

  specify '#ordered_lazy_queries returns unevaluated thunks' do
    q = Queries::BiologicalAssociation::Autocomplete.new('1', project_id: project_id)
    thunks = q.ordered_lazy_queries

    expect(thunks).to be_present
    thunks.each { |t| expect(t).to respond_to(:call) }
  end

  specify '#autocomplete with no matches' do
    q = Queries::BiologicalAssociation::Autocomplete.new('Zzyzxnomatchatall', project_id: project_id)
    expect(q.autocomplete).to eq([])
  end

end
