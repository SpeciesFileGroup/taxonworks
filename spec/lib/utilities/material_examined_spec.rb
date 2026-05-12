require 'rails_helper'

describe Utilities::MaterialExamined do

  # Helpers to build minimal DwC hashes
  def rec(country: '', state: '', county: '', count: 1)
    { 'country' => country, 'stateProvince' => state, 'county' => county, 'individualCount' => count.to_s }
  end

  describe 'geographic alphabetic sorting' do
    # Records supplied in intentionally non-alphabetical order:
    #   Illinois / Ogle before Illinois / Champaign Co., Alabama after Illinois
    let(:records) do
      [
        rec(country: 'United States', state: 'Illinois', county: 'Ogle'),
        rec(country: 'United States', state: 'Illinois', county: 'Champaign Co.'),
        rec(country: 'United States', state: 'Alabama'),
      ]
    end

    subject(:result) do
      Utilities::MaterialExamined.new(records, order: [:country, :state, :county, :total]).render
    end

    specify 'states are sorted alphabetically within their country' do
      expect(result.index('Alabama')).to be < result.index('Illinois')
    end

    specify 'counties are sorted alphabetically within their state' do
      expect(result.index('Champaign')).to be < result.index('Ogle')
    end
  end

end
