require 'rails_helper'

describe BiologicalAssociation, type: :model do

  let(:biological_association) { BiologicalAssociation.new }
  let(:biological_relationship) { FactoryBot.create(:valid_biological_relationship) }
  let(:otu) { FactoryBot.create(:valid_otu) }
  let(:specimen) { FactoryBot.create(:valid_specimen) }

  context 'requires' do
    before(:each) { biological_association.valid?  }

    specify 'biological_relationship' do
      expect(biological_association.errors.include?(:biological_relationship)).to be_truthy
    end

    specify 'biological_association_subject' do
      expect(biological_association.errors.include?(:biological_association_subject)).to be_truthy
    end

    specify 'biological_association_object' do
      expect(biological_association.errors.include?(:biological_association_object)).to be_truthy
    end
  end

  specify 'subject/object_global_id' do
    biological_association.biological_relationship = biological_relationship
    biological_association.subject_global_id = otu.to_global_id.to_s
    biological_association.object_global_id = specimen.to_global_id.to_s
    expect(biological_association.save).to be_truthy
  end

  specify 'subject/object_global_id' do
    expect(BiologicalAssociation.create!(
      subject_global_id: specimen.to_global_id.to_s,
      object_global_id: otu.to_global_id.to_s,
      biological_relationship: biological_relationship
    )).to be_truthy
  end

  specify '#batch_update' do
    a = FactoryBot.create(:valid_biological_association)
    b = FactoryBot.create(:valid_biological_association)
    r = FactoryBot.create(:valid_biological_relationship)

    BiologicalAssociation.batch_update(
      biological_association: { biological_relationship_id: r.id},
      biological_association_query: { biological_association_id: [a.id, b.id] }
    )

    expect(r.biological_associations.count).to eq(2)
  end

  specify '#batch_update preview' do
    a = FactoryBot.create(:valid_biological_association)
    b = FactoryBot.create(:valid_biological_association)
    r = FactoryBot.create(:valid_biological_relationship)

    BiologicalAssociation.batch_update(
      preview: true,
      biological_association: { biological_relationship_id: r.id},
      biological_association_query: {  biological_association_id: [a.id, b.id] }
    )

    expect(r.biological_associations.count).to eq(0)
  end

  specify '#batch_update errors' do
    r = FactoryBot.create(:valid_biological_relationship)

    a = FactoryBot.create(:valid_biological_association, biological_relationship: r)
    b = FactoryBot.create(:valid_biological_association, biological_relationship: r, biological_association_subject: a.biological_association_subject)

    m = BiologicalAssociation.batch_update(
      biological_association: { biological_relationship_id: r.id, biological_association_object_id: a.biological_association_object_id},
      biological_association_query: { biological_association_id: [  b.id ] }
    )

    expect(m.errors).to eq( { "Validation failed: Biological association object has already been taken" => 1 } )
  end

  specify '#rotate' do
    b = FactoryBot.create(:valid_biological_association)

    c = b.subject
    d = b.object

    b.rotate = true
    b.save!

    b.reload
    expect(b.subject).to eq(d)
    expect(b.biological_association_object).to eq(c)
  end

  specify '#rotate with batch update (Hash params)' do
    a = FactoryBot.create(:valid_biological_association)

    b = a.subject
    c = a.object

    r = BiologicalAssociation.batch_update(
      biological_association_query: {  biological_association_id: [a.id] },
      biological_association: {rotate: true}
    )

    expect(r.updated).to contain_exactly(a.id)
    expect(r.not_updated).to eq([])
    expect(r.errors).to eq({})
    a.reload
    expect(a.biological_association_subject).to eq c
    expect(a.biological_association_object).to eq b
  end

  specify '#batch_update, rotate, preview' do
    a = FactoryBot.create(:valid_biological_association)

    c = a.subject
    d = a.object

    r = BiologicalAssociation.batch_update(
      { biological_association_query: { biological_association_id: [a.id] },
        biological_association: {rotate: true},
        preview: true }
    )

    expect(r.updated).to eq([a.id])
    expect(r.not_updated).to eq([])
    expect(r.preview).to be_truthy

    a.reload
    expect(a.subject).to eq(c)
    expect(a.biological_association_object).to eq(d)
  end

  specify '.batch_update() (async)' do
    a = FactoryBot.create(:valid_biological_association)
    b = FactoryBot.create(:valid_biological_association)
    r = FactoryBot.create(:valid_biological_relationship)

    q = ::Queries::BiologicalAssociation::Filter.new({biological_association_id: [a.id, b.id]})

    params = {
      async_cutoff: 1,
      biological_association: {biological_relationship_id: r.id},
      user_id: Current.user_id,
      project_id: Current.project_id
    }.merge(biological_association_query: q.params)

    response = BiologicalAssociation.batch_update(params).to_json

    sleep(2) # jobs trigger in 1 second
    Delayed::Worker.new.work_off

    expect(response[:total_attempted]).to eq(2)
    expect(response[:async]).to eq(true)
    expect(a.reload.biological_relationship).to eq(r)
    expect(b.reload.biological_relationship).to eq(r)
  end

  specify '.batch_update() (async) raises error when user_id is missing' do
    a = FactoryBot.create(:valid_biological_association)
    b = FactoryBot.create(:valid_biological_association)
    r = FactoryBot.create(:valid_biological_relationship)

    q = ::Queries::BiologicalAssociation::Filter.new({biological_association_id: [a.id, b.id]})

    params = {
      async_cutoff: 1,
      biological_association: {biological_relationship_id: r.id},
      user_id: nil,
      project_id: Current.project_id
    }.merge(biological_association_query: q.params)

    expect {
      BiologicalAssociation.batch_update(params)
    }.to raise_error(TaxonWorks::Error, /user_id.*not set in query_batch_update/)
  end

  specify '.batch_update() (async) raises error when project_id is missing' do
    a = FactoryBot.create(:valid_biological_association)
    b = FactoryBot.create(:valid_biological_association)
    r = FactoryBot.create(:valid_biological_relationship)

    q = ::Queries::BiologicalAssociation::Filter.new({biological_association_id: [a.id, b.id]})

    params = {
      async_cutoff: 1,
      biological_association: {biological_relationship_id: r.id},
      user_id: Current.user_id,
      project_id: nil
    }.merge(biological_association_query: q.params)

    expect {
      BiologicalAssociation.batch_update(params)
    }.to raise_error(TaxonWorks::Error, /project_id.*not set in query_batch_update/)
  end

  context '#otu_ids' do
    let(:br) { FactoryBot.create(:valid_biological_relationship) }

    def make_ba(subject:, object:)
      BiologicalAssociation.create!(
        biological_association_subject: subject,
        biological_association_object: object,
        biological_relationship: br,
        project: otu.project
      )
    end

    specify 'direct OTU subject and object' do
      otu2 = FactoryBot.create(:valid_otu)
      ba = make_ba(subject: otu, object: otu2)
      expect(ba.otu_ids).to contain_exactly(otu.id, otu2.id)
    end

    specify 'CollectionObject subject with taxon determination' do
      co = FactoryBot.create(:valid_specimen)
      FactoryBot.create(:taxon_determination, otu:, taxon_determination_object: co)
      ba = make_ba(subject: co, object: otu)
      expect(ba.otu_ids).to contain_exactly(otu.id)
    end

    specify 'FieldOccurrence subject with taxon determination' do
      fo = FactoryBot.create(:valid_field_occurrence)
      FactoryBot.create(:taxon_determination, otu:, taxon_determination_object: fo)
      ba = make_ba(subject: fo, object: otu)
      expect(ba.otu_ids).to contain_exactly(otu.id)
    end

    specify 'CollectionObject with no taxon determination returns no otu_id for that role' do
      co = FactoryBot.create(:valid_specimen)
      otu2 = FactoryBot.create(:valid_otu)
      ba = make_ba(subject: co, object: otu2)
      expect(ba.otu_ids).to contain_exactly(otu2.id)
    end
  end

  context 'concerns' do
    it_behaves_like 'citations'
    it_behaves_like 'is_data'
  end

end

