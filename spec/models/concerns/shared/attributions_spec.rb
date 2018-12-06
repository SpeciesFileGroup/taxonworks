require 'rails_helper'

describe 'Attributions', type: :model, group: :attribution do
  let(:class_with_attribution) { TestAttributionable.new } 
  let(:person) { FactoryBot.create(:valid_person) }

  context 'associations' do
    specify 'has_one attribution 1' do
      expect(class_with_attribution).to respond_to(:attribution) 
    end

    specify 'has_one attribution 2' do
      expect(class_with_attribution.attribution).to eq(nil) 
    end

    specify 'has_one attribution 3' do
      expect(class_with_attribution.attribution = FactoryBot.build(:valid_attribution)).to be_truthy
      expect(class_with_attribution.save).to be_truthy
      expect(class_with_attribution.attribution.present?).to be_truthy
    end
  end

  context 'scopes' do
    context '.with_attribution' do
      let!(:b) { Attribution.create!(attribution_object: class_with_attribution, copyright_year: '1920')}

      specify 'without attribution' do
        expect(class_with_attribution.class.without_attribution.count).to eq(0)
      end 

      specify 'with_attribution' do
        expect(class_with_attribution.class.with_attribution.pluck(:id)).to eq( [ class_with_attribution.id  ] )
      end
    end

    context '.without_attribution' do
      specify 'without attribution' do
        class_with_attribution.save
        expect(TestAttributionable.without_attribution.pluck(:id)).to eq([class_with_attribution.id])
      end 

      specify 'with_attribution' do
        expect(class_with_attribution.class.with_attribution.to_a).to eq( [ ] )
      end
    end
  end

  context 'methods' do
    specify '#attributed? with no attribution' do
      expect(class_with_attribution.attributed?).to eq(false)
    end

    specify '#attributed? with a attribution' do
      class_with_attribution.attribution = Attribution.new(copyright_year: '1920')
      expect(class_with_attribution.attributed?).to eq(true)
    end
    context 'object with attribution on destroy' do
      specify 'attached attribution are destroyed' do
        expect(Attribution.count).to eq(0)
        class_with_attribution.attribution = Attribution.new(copyright_year: 1920)
        class_with_attribution.save
        expect(Attribution.count).to eq(1)
        expect(class_with_attribution.destroy).to be_truthy
        expect(Attribution.count).to eq(0)
      end
    end
  end

  context 'nested attributes' do
    before{ 
      class_with_attribution.attribution_attributes = { copyright_year: 1920, creator_roles_attributes: [{person: person}] }
      class_with_attribution.save!
    }


    specify 'base set' do
      expect(class_with_attribution.attribution.copyright_year).to eq(1920)
    end

    specify 'roles saved' do
      expect(class_with_attribution.attribution.attribution_creators.map(&:id)).to contain_exactly(person.id)
    end

  end
end

class TestAttributionable < ApplicationRecord
  include FakeTable
  include Shared::Attributions
end


