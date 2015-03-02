require 'rails_helper'

describe GeographicAreaType, :type => :model do
  let(:geographic_area_type) {FactoryGirl.build(:geographic_area_type)}

  context 'associations' do
    context 'has_many' do
      specify 'geographic_areas' do
        expect(geographic_area_type.geographic_areas << GeographicArea.new()).to be_truthy
      end
    end
  end

  context 'validation' do
    before(:all) {
      GeographicAreaType.destroy_all
    }
    before(:each) {
      geographic_area_type.valid?
    }
    specify '#name' do
      expect(geographic_area_type.errors.include?(:name)).to be_truthy
    end
  
    specify 'only a name is required' do
      geographic_area_type.name = 'Country'
      expect(geographic_area_type.save).to be_truthy
    end 
  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
