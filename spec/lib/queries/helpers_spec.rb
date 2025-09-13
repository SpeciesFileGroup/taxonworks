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

end
