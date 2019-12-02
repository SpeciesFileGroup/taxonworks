require 'rails_helper'
require 'catalog'
describe Catalog, group: :catalogs, spinup: true do

  let(:catalog) { Catalog.new(targets: []) }

  specify '#new' do
    expect {Catalog.new}.to raise_error ArgumentError
  end

  specify '#new' do
    expect(Catalog.new(targets: [])).to be_truthy
  end

  specify '#items' do
    expect(catalog.items).to eq([]) 
  end

  specify '#items_chronologically' do
    expect(catalog.items_chronologically).to eq([]) 
  end

end


