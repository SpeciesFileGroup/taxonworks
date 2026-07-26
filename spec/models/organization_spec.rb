require 'rails_helper'

RSpec.describe Organization, type: :model do

  let(:organization) { Organization.new }

  specify 'valid with #name' do
    organization.name = 'My organization'
    expect(organization.valid?).to be_truthy
  end

  specify 'invalid without #name' do
    expect(organization.valid?).to be_falsey
  end

  specify 'invalid with #name == #alternate_name' do
    organization.name = 'one'
    organization.alternate_name = 'one'
    expect(organization.valid?).to be_falsey
  end

  context '#geographic_area' do
    let(:earth) { FactoryBot.create(:earth_geographic_area) }
    let(:country) { FactoryBot.create(:level0_geographic_area) }
    let(:state) { FactoryBot.create(:level1_geographic_area) }

    before { organization.name = 'My organization' }

    specify 'a country is valid' do
      organization.geographic_area = country
      expect(organization.valid?).to be_truthy
    end

    specify 'a level below country is valid' do
      organization.geographic_area = state
      expect(organization.valid?).to be_truthy
    end

    specify 'an area that does not resolve to a country is invalid' do
      organization.geographic_area = earth
      expect(organization.valid?).to be_falsey
      expect(organization.errors.include?(:geographic_area)).to be_truthy
    end

    specify '#country returns the resolved country' do
      organization.geographic_area = state
      expect(organization.country).to eq(state.level0)
    end
  end

  context 'depictions' do
    specify 'an Organization can be depicted' do
      o = FactoryBot.create(:valid_organization)
      d = FactoryBot.create(:valid_depiction_logo, depiction_object: o)
      expect(o.depictions.reload).to include(d)
    end
  end

end
