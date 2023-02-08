require 'rails_helper'

Dir.glob('lib/queries/**/filter.rb').each do |f|
  require_relative Rails.root + f
end

# Meta-tests
describe Queries::Query::Filter do

  let(:query) { Queries::Query::Filter.new({}) }
  filters = ::Queries::Query::Filter.descendants 

  context 'PARAM' do
    filters.each do |f|
      specify "#{f.name}" do
        expect(f.const_defined?('PARAMS')).to be_truthy
      end
    end
  end

  context 'SUBQURIES' do
    ::Queries::Query::Filter::SUBQUERIES.each do |k,v|
      k = ::Queries::Query::Filter::FILTER_QUERIES[(k.to_s + '_query').to_sym].constantize
      v.each do |t|
        specify "#{k.name}: #{t}" do
          m = (t.to_s + '_query_facet' ).to_sym
          expect(k.new({}).respond_to?(m)).to be_truthy
        end
      end
    end
  end

  context '<model>_id' do
    filters.each do |f|
      specify "#{f.name}" do
        m = (f.base_name + '_id').to_sym
        expect(f.new({}).send(m)).to eq([])
      end
    end
  end

end