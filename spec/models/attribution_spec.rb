require 'rails_helper'

RSpec.describe Attribution, type: :model do

  let(:attribution) { Attribution.new }

  specify '#license' do 
    attribution.license = 'foo'
    attribution.valid?
    expect(attribution.errors.include?(:license)).to be_truthy
  end

end
