require 'rails_helper'

Dir.glob('lib/queries/**/filter.rb').each do |f|
  require_relative Rails.root + f
end

# Meta-tests
describe Queries::Query::Filter do

  let(:query) { Queries::Query::Filter.new({}) }
  filters = ::Queries::Query::Filter.descendants 

  context 'PARAMS defined' do
    filters.each do |f|
      specify "#{f.name}" do
        expect(f.const_defined?('PARAMS')).to be_truthy
      end
    end
  end

  # Check that the query cross-referencing in SUBQUERIES has
  # corresponding query facets in the filters.
  #
  # Inverse of below
  context 'SUBQUERY reference of _query_facet present in filter' do
    ::Queries::Query::Filter::SUBQUERIES.each do |k,v|
      k = ::Queries::Query::Filter::FILTER_QUERIES[(k.to_s + '_query').to_sym].constantize
      next if k.name =~ /Image|Source/ # Queries are dynamically added in these filters, and have no corresponding method name
      v.each do |t|
        specify "#{k.name}: #{t}" do
          m = (t.to_s + '_query_facet' ).to_sym
          expect(k.new({}).respond_to?(m)).to be_truthy
        end
      end
    end
  end

  # Check that the query methods in filters have
  # corresponding references in SUBQUERIES
  # Inverse of above
  context '_query_facet referenced in SUBQUERIES' do
    filters.each do |f|

      f.new({}).public_methods(false).select{|a| a.to_s =~ /_query_facet/}.each do |m|
        next if m.to_s =~ /base_/

        specify "#{f}: #{m}" do
          v = m.to_s.gsub(/_query_facet/, '').to_sym
          expect( ::Queries::Query::Filter::SUBQUERIES[f.base_name.to_sym]).to include( v )
        end
      end
    end
  end

  context '<Model>.js matches content of SUBQUERIES' do
    Dir.glob('app/javascript//**/filter/links/*.js').each do |file|
      n = file.split('/').last
      next unless n =~ /^[A-Z]/ # Constants start with a capital

      filter_name = n.split('.').first.tableize.singularize.to_sym 

      models = File.read(file)
      models =~ /.*\[(.*)\]/m
      query_names = $1.split(',').map(&:strip).select{|a| a.present?}.collect{|a| a.gsub('FILTER_', '').downcase.to_sym}

      # Ensure all Model.js constants match what is asserted in SUBQUERIES
      specify "#{n}" do
        expect( query_names ).to contain_exactly( *::Queries::Query::Filter.inverted_subqueries[filter_name]  )
      end
    end
  end

  context '<model>_id present in filter' do
    filters.each do |f|
      specify "#{f.name}" do
        m = (f.base_name + '_id').to_sym
        expect(f.new({}).send(m)).to eq([])
      end
    end
  end

end