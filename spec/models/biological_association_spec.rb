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

  context 'concerns' do
    it_behaves_like 'citations'
    it_behaves_like 'is_data'
  end

end

