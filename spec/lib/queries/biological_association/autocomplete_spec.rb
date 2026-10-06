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

  specify '#otu_matches returns biological associations in otu candidate order' do
    # Created first, so likely first in an unordered result
    partial_otu = FactoryBot.create(:valid_otu, name: 'Zzyzxrank partial')
    partial_ba = FactoryBot.create(:valid_biological_association, biological_association_subject: partial_otu)
    exact_otu = FactoryBot.create(:valid_otu, name: 'Zzyzxrank')
    exact_ba = FactoryBot.create(:valid_biological_association, biological_association_subject: exact_otu)

    q = Queries::BiologicalAssociation::Autocomplete.new('Zzyzxrank', project_id:)
    expect(q.otu_matches(:subject, 10)).to eq([exact_ba, partial_ba])
  end

  context 'restrict_to' do
    let(:subject_otu) { FactoryBot.create(:valid_otu, name: 'Zzyzxrestrictotu') }
    let!(:ba1) { FactoryBot.create(:valid_biological_association, biological_association_subject: subject_otu) }
    let!(:ba2) { FactoryBot.create(:valid_biological_association, biological_association_subject: subject_otu) }

    specify 'restricts otu matches' do
      q = Queries::BiologicalAssociation::Autocomplete.new('Zzyzxrestrictotu', project_id:, restrict_to: BiologicalAssociation.where(id: ba2.id))
      expect(q.autocomplete).to contain_exactly(ba2)
    end

    specify 'restricts exact id matches' do
      q = Queries::BiologicalAssociation::Autocomplete.new(ba1.id.to_s, project_id:, restrict_to: BiologicalAssociation.where(id: ba2.id))
      expect(q.autocomplete).to_not include(ba1)
    end

    specify 'restricts biological relationship matches' do
      ba1.biological_relationship.update!(name: 'Zzyzxrestrictrelationship')
      ba2.update!(biological_relationship: ba1.biological_relationship)
      q = Queries::BiologicalAssociation::Autocomplete.new('Zzyzxrestrictrelationship', project_id:, restrict_to: BiologicalAssociation.where(id: ba2.id))
      expect(q.autocomplete).to contain_exactly(ba2)
    end

    specify 'raises when the relation is of another model' do
      q = Queries::BiologicalAssociation::Autocomplete.new('Zzyzxrestrictotu', project_id:, restrict_to: Otu.all)
      expect { q.autocomplete }.to raise_error(ArgumentError, /Otu/)
    end

    specify 'restricts candidate otus, per side, before limiting them' do
      # The exact name match outranks the partial one, so unrestricted
      # the single allowed otu candidate would be exact_otu, which has no
      # BA in the restriction.
      exact_otu = FactoryBot.create(:valid_otu, name: 'Zzyzxpushdown')
      partial_otu = FactoryBot.create(:valid_otu, name: 'Zzyzxpushdown partial')
      FactoryBot.create(:valid_biological_association, biological_association_subject: exact_otu)
      ba = FactoryBot.create(:valid_biological_association, biological_association_subject: partial_otu)
      # partial_otu as object shouldn't make it a subject candidate
      other = FactoryBot.create(:valid_biological_association, biological_association_object: exact_otu)

      q = Queries::BiologicalAssociation::Autocomplete.new('Zzyzxpushdown', project_id:,
        restrict_to: BiologicalAssociation.where(id: [ba.id, other.id]))

      expect(q.otu_matches(:subject, 1)).to contain_exactly(ba)
      expect(q.otu_matches(:object, 1)).to contain_exactly(other)
    end

    specify 'restricts collection object, field occurrence, and anatomical part candidates per side' do
      co = FactoryBot.create(:valid_specimen)
      fo = FactoryBot.create(:valid_field_occurrence)
      ap = FactoryBot.create(:valid_anatomical_part)
      FactoryBot.create(:valid_biological_association, biological_association_object: co)
      FactoryBot.create(:valid_biological_association, biological_association_object: fo)
      FactoryBot.create(:valid_biological_association, biological_association_object: ap)

      q = Queries::BiologicalAssociation::Autocomplete.new('Zzyzx', project_id:,
        restrict_to: BiologicalAssociation.all)

      expect(q.collection_object_autocomplete(:subject).restrict_to).to_not include(co)
      expect(q.collection_object_autocomplete(:object).restrict_to).to contain_exactly(co)
      expect(q.field_occurrence_autocomplete(:subject).restrict_to).to_not include(fo)
      expect(q.field_occurrence_autocomplete(:object).restrict_to).to contain_exactly(fo)
      expect(q.anatomical_part_autocomplete(:subject).restrict_to).to_not include(ap)
      expect(q.anatomical_part_autocomplete(:object).restrict_to).to contain_exactly(ap)
    end

    specify 'is not applied when nil' do
      q = Queries::BiologicalAssociation::Autocomplete.new('Zzyzxrestrictotu', project_id:, restrict_to: nil)
      expect(q.autocomplete).to include(ba1, ba2)
    end
  end

  context 'without restrict_to' do
    specify 'subject/object candidates are restricted to records on that side of a biological association in the project' do
      in_ba = FactoryBot.create(:valid_otu, name: 'Zzyzxdefaultside')
      not_in_ba = FactoryBot.create(:valid_otu, name: 'Zzyzxdefaultside other')
      FactoryBot.create(:valid_biological_association, biological_association_subject: in_ba)

      q = Queries::BiologicalAssociation::Autocomplete.new('Zzyzxdefaultside', project_id:)

      expect(q.otu_autocomplete(:subject).restrict_to).to include(in_ba)
      expect(q.otu_autocomplete(:subject).restrict_to).to_not include(not_in_ba)
      expect(q.otu_autocomplete(:object).restrict_to).to_not include(in_ba)
    end

    specify 'subject/object candidates exclude records only in another project\'s biological associations' do
      other_project = FactoryBot.create(:valid_project, name: 'other')
      other_otu = FactoryBot.create(:valid_otu, project: other_project)
      FactoryBot.create(
        :biological_association,
        biological_relationship: FactoryBot.create(:valid_biological_relationship, project: other_project),
        biological_association_subject: other_otu,
        biological_association_object: FactoryBot.create(:valid_otu, project: other_project),
        project: other_project
      )

      q = Queries::BiologicalAssociation::Autocomplete.new('Zzyzx', project_id:)
      expect(q.otu_autocomplete(:subject).restrict_to).to_not include(other_otu)
    end
  end

  context 'limit' do
    specify 'caps results, default RESULTS_LIMIT' do
      o = FactoryBot.create(:valid_otu, name: 'Zzyzxlimitba')
      3.times { FactoryBot.create(:valid_biological_association, biological_association_subject: o) }

      expect(Queries::BiologicalAssociation::Autocomplete.new('Zzyzxlimitba', project_id:).autocomplete.size).to eq(3)
      expect(Queries::BiologicalAssociation::Autocomplete.new('Zzyzxlimitba', project_id:, limit: 2).autocomplete.size).to eq(2)
    end

    specify 'is passed to the subject/object autocompletes' do
      q = Queries::BiologicalAssociation::Autocomplete.new('Zzyzx', project_id:, limit: 7)
      expect(q.otu_autocomplete(:subject).limit).to eq(7)
    end
  end

  specify 'passes its results limit to the subject/object autocompletes' do
    q = Queries::BiologicalAssociation::Autocomplete.new('Zzyzx', project_id:)
    expect(q.otu_autocomplete(:subject).limit).to eq(Queries::BiologicalAssociation::Autocomplete::RESULTS_LIMIT)
    expect(q.collection_object_autocomplete(:object).limit).to eq(Queries::BiologicalAssociation::Autocomplete::RESULTS_LIMIT)
  end

  specify '#otu_matches returns no more than the results allowed, best ranked first' do
    o = FactoryBot.create(:valid_otu, name: 'Zzyzxmanybas')
    bas = 3.times.map { FactoryBot.create(:valid_biological_association, biological_association_subject: o) }

    q = Queries::BiologicalAssociation::Autocomplete.new('Zzyzxmanybas', project_id:)
    expect(q.otu_matches(:subject, 2)).to eq(bas.first(2))
  end

  specify '#biological_relationship_matches returns no more than the results allowed, in order' do
    r = FactoryBot.create(:valid_biological_relationship, name: 'Zzyzxmanyrelationship')
    bas = 3.times.map { FactoryBot.create(:valid_biological_association, biological_relationship: r) }

    q = Queries::BiologicalAssociation::Autocomplete.new('Zzyzxmanyrelationship', project_id:)
    expect(q.biological_relationship_matches(2)).to eq(bas.first(2))
  end

  specify '#autocomplete exact id is scoped to the project' do
    other_project = FactoryBot.create(:valid_project, name: 'other')
    other_ba = FactoryBot.create(
      :biological_association,
      biological_relationship: FactoryBot.create(:valid_biological_relationship, project: other_project),
      biological_association_subject: FactoryBot.create(:valid_otu, project: other_project),
      biological_association_object: FactoryBot.create(:valid_otu, project: other_project),
      project: other_project
    )

    q = Queries::BiologicalAssociation::Autocomplete.new(other_ba.id.to_s, project_id:)
    expect(q.autocomplete).to_not include(other_ba)
  end

end
