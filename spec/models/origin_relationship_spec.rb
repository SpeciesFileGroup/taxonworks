require 'rails_helper'

RSpec.describe OriginRelationship, type: :model do
  let(:origin_relationship) { OriginRelationship.new() }

  let(:old_specimen) { FactoryBot.create(:valid_specimen) }
  let(:new_specimen) { FactoryBot.create(:valid_specimen) }

  context 'validation' do

    specify '#old_object is required' do
      origin_relationship.valid? 
      expect(origin_relationship.errors.include?(:old_object)).to be_truthy
    end

    specify '#new_object is required' do
      origin_relationship.valid? 
      expect(origin_relationship.errors.include?(:new_object)).to be_truthy
    end

    specify 'old, new both allowed' do
      origin_relationship.old_object = old_specimen
      origin_relationship.new_object = new_specimen
      expect(origin_relationship.valid?).to be_truthy
    end

    specify 'new not allowed' do
      expect{ origin_relationship.new_object = FactoryBot.create(:valid_collecting_event) }.to raise_error ActiveRecord::InverseOfAssociationNotFoundError 
    end

    specify 'old not allowed' do
      expect{ origin_relationship.old_object = FactoryBot.create(:valid_collecting_event) }.to raise_error ActiveRecord::InverseOfAssociationNotFoundError 
    end

  end
end
