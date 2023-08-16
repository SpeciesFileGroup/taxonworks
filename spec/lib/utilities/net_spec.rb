require 'rails_helper'

describe 'Utilities::Net' do

  context '#resolves?' do

    specify 'responding URI' do
      text = 'http://data.nhm.ac.uk/object/a9bdc16d-c9ba-4e32-9311-d5250af2b5ac'
      VCR.use_cassette('responding URI') do
        expect(Utilities::Net.resolves?(text)).to be_truthy
      end
    end

    specify 'non-responding URI' do
      text = 'https://sandbox.speciesfile.org/object/a9bdc16d-c9ba-4e32-9311-d5250af2b5ac'
      VCR.use_cassette('non-responding URI') do
        expect(Utilities::Net.resolves?(text)).to be_falsey
      end
    end

    specify 'non-conforming URI' do
      text = 'data.nhm.ac.uk/object/a9bdc16d-c9ba-4e32-9311-d5250af2b5ac'
      VCR.use_cassette('non-conforming URI') do
        expect(Utilities::Net.resolves?(text)).to be_falsey
      end
    end

    specify 'empty (non-nil) URI' do
      text = ''
      VCR.use_cassette('empty (non-nil) URI') do
        expect(Utilities::Net.resolves?(text)).to be_falsey
      end
    end
  end
end
