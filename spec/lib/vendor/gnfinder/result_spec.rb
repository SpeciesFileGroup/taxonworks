require 'rails_helper'
describe Vendor::Gnfinder::Result, type: [:model]  do

  let(:finder) { Vendor::Gnfinder.finder }
  let(:text) { 'A story involving illumination and a male Gallus gallus domesticus on a Canis lupus sp. nov. on a Equus asinus.' }
  let(:found) { finder.find_names(text, verification: true, words_around: 3) }

  let(:result) { Vendor::Gnfinder::Result.new(found) }

  let(:names) { ["Canis lupus", "Equus asinus", "Gallus gallus domesticus"] }

  specify '#unique_names' do
    expect(result.unique_names.keys).to contain_exactly(*names)
  end

  specify '#new_names' do
    expect(result.new_names.keys).to contain_exactly('Canis lupus')
  end

  specify '#missing_names' do
    expect(result.missing_names.keys).to contain_exactly(*names)
  end

  specify '#found_all?' do
    expect(result.found_all?).to be_falsey
  end

  specify '#found_names' do
    expect(result.found_names).to be_empty
  end

  specify '#verified_names' do
    expect(result.verified_names.keys).to contain_exactly(*names)
  end

end
