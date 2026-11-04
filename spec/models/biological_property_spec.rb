require 'rails_helper'

describe BiologicalProperty, type: :model do
  let(:biological_property) { FactoryBot.build(:biological_property) }

  context 'validation' do 
    context 'requires' do
      before do
        biological_property.valid?
      end

      specify 'name' do
        expect(biological_property.errors.include?(:name)).to be_truthy
      end

      specify 'definition' do
        expect(biological_property.errors.include?(:definition)).to be_truthy
      end
    end
  end

  context '#biological_associations' do
    let(:property) { FactoryBot.create(:valid_biological_property) }
    let(:relationship1) { FactoryBot.create(:valid_biological_relationship) }
    let(:relationship2) { FactoryBot.create(:valid_biological_relationship) }
    let(:unrelated_relationship) { FactoryBot.create(:valid_biological_relationship) }

    let!(:ba1) { FactoryBot.create(:valid_biological_association, biological_relationship: relationship1) }
    let!(:ba2) { FactoryBot.create(:valid_biological_association, biological_relationship: relationship2) }
    let!(:unrelated_ba) { FactoryBot.create(:valid_biological_association, biological_relationship: unrelated_relationship) }

    before do
      # Property on both sides of relationship1, should not double count ba1.
      FactoryBot.create(:valid_biological_relationship_subject_type, biological_property: property, biological_relationship: relationship1)
      FactoryBot.create(:valid_biological_relationship_object_type, biological_property: property, biological_relationship: relationship1)
      FactoryBot.create(:valid_biological_relationship_object_type, biological_property: property, biological_relationship: relationship2)
    end

    specify 'returns associations whose relationship uses the property' do
      expect(property.biological_associations).to contain_exactly(ba1, ba2)
    end

    specify 'counts each association once' do
      expect(property.biological_associations.count).to eq(2)
    end
  end
end
