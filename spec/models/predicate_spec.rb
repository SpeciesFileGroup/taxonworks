require 'rails_helper'

describe Predicate, type: :model do
  let(:predicate) { Predicate.create!(name: 'My predicate', definition: 'My longer definition.') }
  let(:otu) { FactoryBot.create(:valid_otu) }
  let(:specimen) { FactoryBot.create(:valid_specimen) }

  specify '#internal_attributes' do
    expect(predicate.internal_attributes << InternalAttribute.new(attribute_subject: otu, value: 123)).to be_truthy
  end

  context 'scopes' do
    let!(:other_predicate) { Predicate.create!(name: 'My other predicate', definition: 'My really longer definition.') }

    let!(:data_attribute) { otu.data_attributes << InternalAttribute.new(predicate: predicate, value: '123') }

    let!(:other_attribute) { specimen.data_attributes << InternalAttribute.new(predicate: other_predicate, value: '123', created_at: 4.years.ago, updated_at: 4.years.ago) }


    specify '.used_on_klass 1' do
      expect(Predicate.used_on_klass('Otu')).to contain_exactly(predicate)
    end

    specify '.used_on_klass 2' do
      expect(Predicate.used_on_klass('CollectionObject')).to contain_exactly(other_predicate)
    end

    specify '.used_recently' do
      expect(Predicate.used_recently(predicate.created_by_id, predicate.project_id, '')).to contain_exactly()
    end

    specify '#used_recently.used_on_klass 1' do
      expect(Predicate.used_recently(predicate.created_by_id, predicate.project_id, 'Otu')).to contain_exactly(predicate.id)
    end

    specify '#used_recently.used_on_klass 1' do
      expect(Predicate.used_recently(predicate.created_by_id, predicate.project_id, 'CollectionObject')).to contain_exactly()
    end

  end

  context 'validation' do
    # specify "can be used for attributes only"
  end
end
