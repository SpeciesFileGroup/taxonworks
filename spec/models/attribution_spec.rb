require 'rails_helper'

RSpec.describe Attribution, type: :model do

  let(:attribution) { Attribution.new }

  specify '#license' do 
    attribution.license = 'foo'
    attribution.valid?
    expect(attribution.errors.include?(:license)).to be_truthy
  end

  specify '#attribution_object_type' do
    attribution.attribution_object_type = "" 
    attribution.save
    expect(attribution.attribution_object_type).to eq(nil) 
  end

end
