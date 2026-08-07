require 'rails_helper'
include Queries::Helpers

describe Queries::Helpers do

  specify '.integer_param symbol' do
    p = {foo: :bar}
    expect{integer_param(p, :foo)}.to raise_error TaxonWorks::Error::API
  end

  specify '.integer_param integer' do
    p = {foo: 1}
    expect(integer_param(p, :foo)).to eq(1)
  end

  specify '.integer_param String' do
    p = {foo: '1'}
    expect(integer_param(p, :foo)).to eq('1')
  end

  specify '.integer_param integer, array' do
    p = {foo: [1, '2'] }
    expect(integer_param(p, :foo)).to eq([1,'2'])
  end

  specify '.integer_param, mixed array' do
    p = {foo: [1, :bar]}
    expect{integer_param(p, :foo)}.to raise_error TaxonWorks::Error::API
  end

  context '.tri_value_array' do
    specify 'returns empty array for nil' do
      expect(tri_value_array(nil)).to eq([])
    end

    specify 'converts true values' do
      expect(tri_value_array([true, 'true'])).to eq([true, true])
    end

    specify 'converts false values' do
      expect(tri_value_array([false, 'false'])).to eq([false, false])
    end

    specify 'converts nil values' do
      expect(tri_value_array([nil, 'nil', ''])).to eq([nil, nil, nil])
    end

    specify 'handles mixed values' do
      expect(tri_value_array([true, false, nil, 'true', 'false', ''])).to eq([true, false, nil, true, false, nil])
    end

    specify 'raises on invalid values' do
      expect { tri_value_array(['yes']) }.to raise_error TaxonWorks::Error::API
    end
  end

end
