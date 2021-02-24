require 'rails_helper'

describe Vendor::Gnfinder, type: :model do
  specify '#result' do
    expect(Vendor::Gnfinder.result('my text')).to be_truthy
  end
end
