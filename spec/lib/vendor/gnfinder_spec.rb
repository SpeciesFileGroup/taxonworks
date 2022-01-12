require 'rails_helper'

describe TaxonWorks::Vendor::Gnfinder, type: :model do
  specify '#result' do
    expect(TaxonWorks::Vendor::Gnfinder.result('my text')).to be_truthy
  end
end
