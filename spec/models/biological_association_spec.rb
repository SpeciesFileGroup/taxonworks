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

  specify 'subject is allowed' do
    biological_association.biological_association_subject = FactoryBot.create(:valid_container)
    biological_association.valid?
    expect(biological_association.errors.include?(:biological_association_subject_type)).to be_truthy
  end

  specify 'object is allowed' do
    biological_association.biological_association_object = FactoryBot.create(:valid_container)
    biological_association.valid?
    expect(biological_association.errors.include?(:biological_association_object_type)).to be_truthy
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

    expect(m.errors).to eq( { "Validation failed: Biological association subject has already been taken" => 1 } )
  end

  specify '#batch_rotate' do
    a = FactoryBot.create(:valid_biological_association)

    c = a.subject
    d = a.object

    BiologicalAssociation.batch_rotate(
      { biological_association_query: { }} 
    )

    a.reload
    expect(a.subject).to eq(d)
    expect(a.biological_association_object).to eq(c)
  end

  specify '#batch_rotate response' do
    a = FactoryBot.create(:valid_biological_association)

    r = BiologicalAssociation.batch_rotate(
      biological_association_query: {  biological_association_id: [a.id] }
    )

    expect(r.updated).to contain_exactly(a.id)
    expect(r.not_updated).to eq([])
    expect(r.errors).to eq({})
  end

  specify '#batch_rotate' do
    a = FactoryBot.create(:valid_biological_association)

    c = a.subject
    d = a.object

    BiologicalAssociation.batch_rotate(
      biological_association_query: { biological_association_id: [a.id] }
    )

    a.reload
    expect(a.subject).to eq(d)
    expect(a.biological_association_object).to eq(c)
  end

  specify '#batch_rotate preview' do
    a = FactoryBot.create(:valid_biological_association)

    c = a.subject
    d = a.object

    r = BiologicalAssociation.batch_rotate(
      { biological_association_query: { biological_association_id: [a.id] },
        preview: true }
    )

    expect(r.updated).to eq([a.id])
    expect(r.not_updated).to eq([])
    expect(r.preview).to be_truthy

    a.reload
    expect(a.subject).to eq(c)
    expect(a.biological_association_object).to eq(d)
  end

  context 'concerns' do
    it_behaves_like 'citations'
    it_behaves_like 'is_data'
  end

end

