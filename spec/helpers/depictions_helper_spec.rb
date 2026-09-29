require 'rails_helper'

RSpec.describe DepictionsHelper, type: :helper do
  specify '#depiction_to_json with attribution includes image links' do
    depiction = FactoryBot.create(:valid_depiction)
    FactoryBot.create(:valid_attribution, attribution_object: depiction.image)

    json = helper.depiction_to_json(depiction, api: true)

    expect(json[:attributed]).to be true
    expect(json[:thumb]).to be_present
    expect(json[:medium]).to be_present
    expect(json[:original_png]).to be_present
    expect(json[:message]).to be_nil
  end

  specify '#depiction_to_json without attribution redacts image links' do
    depiction = FactoryBot.create(:valid_depiction)

    json = helper.depiction_to_json(depiction, api: true)

    expect(json[:attributed]).to be false
    expect(json[:thumb]).to be_nil
    expect(json[:medium]).to be_nil
    expect(json[:original_png]).to be_nil
    expect(json[:message]).to include('lacks attribution')
  end
end
