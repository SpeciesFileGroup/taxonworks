require 'rails_helper'

RSpec.describe OriginRelationship, type: :model do
  let(:origin_relationship) { OriginRelationship.new() }
  
  let(:old_specimen) { FactoryBot.create(:valid_specimen) }
  let(:new_specimen) { FactoryBot.create(:valid_specimen) }

  context 'validation' do
    before { origin_relationship.valid? }

    specify '#old_object is required' do
      expect(origin_relationship.errors.include?(:old_object)).to be_truthy
    end

    specify '#new_object is required' do
      expect(origin_relationship.errors.include?(:new_object)).to be_truthy
    end
    
    context 'with old and new set' do
      before {
        origin_relationship.old_object = old_specimen
        origin_relationship.new_object = new_specimen
      }

      specify 'is valid' do
        expect(origin_relationship.valid?).to be_truthy
      end

    end

  end

end
