require 'spec_helper'

describe GeographicAreaType do
  let(:geographic_area_type) {FactoryGirl.create(:p_geographic_area_type)}

  context 'associations' do
    context 'has_many' do

    end
  end

  context 'validation' do
    specify 'name' do
      expect(geographic_area_type).to respond_to(:name)
    end

    specify 'name' do
      expect(geographic_area_type).to respond_to(:name)
      expect(geographic_area_type.name.blank?).to be_false
    end
  end
end
