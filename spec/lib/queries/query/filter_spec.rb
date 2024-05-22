require 'rails_helper'

Dir.glob('lib/queries/**/filter.rb').each do |f|
  require_relative Rails.root + f
end

# Meta-tests
describe Queries::Query::Filter, type: [:model] do

  let(:query) { Queries::Query::Filter.new({}) }
  filters = ::Queries::Query::Filter.descendants

  context '#apply_venn' do
    let(:o1) { FactoryBot.create(:valid_otu) }
    let(:o2) { FactoryBot.create(:valid_otu) }
    let(:o3) { FactoryBot.create(:valid_otu) }

    specify '#apply_venn ab' do
      v = "http://127.0.0.1:3000/otus/filter.json?name=#{o2.name}"
      a = ::Queries::Otu::Filter.new(otu_id: [o1.id, o2.id, o3.id], venn: v)
      expect(a.all).to contain_exactly(o2)
    end

    specify '#apply_venn #venn_mode a' do
      v = "http://127.0.0.1:3000/otus/filter.json?name=#{o2.name}"
      a = ::Queries::Otu::Filter.new(otu_id: [o1.id, o2.id, o3.id], venn: v, venn_mode: :a)
      expect(a.all).to contain_exactly(o1, o3)
    end

    specify '#apply_venn #venn_mode b' do
      v = "http://127.0.0.1:3000/otus/filter.json?otu_id[]=#{o2.id}&otu_id[]=#{o3.id}"
      a = ::Queries::Otu::Filter.new(otu_id: [o1.id, o2.id], venn: v, venn_mode: :b)
      expect(a.all).to contain_exactly(o3)
    end

    specify '#apply_venn #venn_mode b' do
      v = "http://127.0.0.1:3000/otus/filter.json?otu_id[]=#{o2.id}&otu_id[]=#{o3.id}"
      a = ::Queries::Otu::Filter.new(otu_id: [o1.id, o2.id], venn: v, venn_mode: :b)
      expect(a.all).to contain_exactly(o3)
    end
  end

  specify '#venn_query' do
    v = 'http://127.0.0.1:3000/otus/filter.json?per=50&name=Ant&extend%5B%5D=taxonomy&page=1'

    q = ::Queries::Otu::Filter.new({})
    q.venn = v
    expect(q.venn_query.class).to eq(::Queries::Otu::Filter)
  end

  specify '#venn_query params' do
    v = 'http://127.0.0.1:3000/otus/filter.json?per=50&name=Ant&extend%5B%5D=taxonomy&page=1'

    a = ::Queries::Otu::Filter.new({})
    a.venn = v
    b = a.venn_query
    expect(b.params).to eq({name: 'Ant', page: '1', per: '50'})
  end

  specify '#venn_mode 0' do
    expect(query.venn_mode).to eq(:ab)
  end

  specify '#venn_mode 1' do
    query.venn_mode = 'a'
    expect(query.venn_mode).to eq(:a)
  end

  specify '#venn_mode 2' do
    query.venn_mode = 'x'
    expect(query.venn_mode).to eq(nil)
  end

  specify '.instantiated_base_filter 1' do
    p = ActionController::Parameters.new(otu_query: {}, foo: :bar)
    expect(Queries::Query::Filter.instatiated_base_filter(p).referenced_klass).to eq(::Otu)
  end

  specify '.instantiated_base_filter 1' do
    p = ActionController::Parameters.new(otu_query: {otu_id: [1,2,3]}, foo: :bar)
    expect(Queries::Query::Filter.instatiated_base_filter(p).otu_id).to eq([1,2,3])
  end

  specify '.instantiated_base_filter params 1 ' do
    p = ActionController::Parameters.new(collecting_event_query: {wildcard_attribute: 'verbatim_locality'})
    expect(Queries::Query::Filter.instatiated_base_filter(p).params).to include(:wildcard_attribute)
  end

  specify '.instantiated_base_filter params 2 ' do
    p = ActionController::Parameters.new(collecting_event_query: {wildcard_attribute: ['verbatim_locality']})
    expect(Queries::Query::Filter.instatiated_base_filter(p).params).to include(:wildcard_attribute)
  end

  specify '.base_filter 1' do
     p = ActionController::Parameters.new(collection_object_query: {}, foo: :bar)
     expect(Queries::Query::Filter.base_filter(p)).to eq(::Queries::CollectionObject::Filter)
  end

  specify '.base_filter 1' do
     p = ActionController::Parameters.new(collection_object_query: { otu_query: {}}, foo: :bar)
     expect(Queries::Query::Filter.base_filter(p)).to eq(::Queries::CollectionObject::Filter)
  end

  context 'PARAMS defined' do
    filters.each do |f|
      specify "#{f.name}" do
        expect(f.const_defined?('PARAMS')).to be_truthy
      end
    end
  end

  # Check that the query cross-referencing in SUBQUERY has
  # corresponding query facets in the filters.
  #
  # Inverse of below
  context 'SUBQUERY reference of _query_facet present in filter' do
    ::Queries::Query::Filter::SUBQUERIES.each do |k,v|
      k = ::Queries::Query::Filter::FILTER_QUERIES[(k.to_s + '_query').to_sym].constantize
      next if k.name =~ /Image|Source|DataAttribute/ # Queries are dynamically added in these filters, and have no corresponding method name
      v.each do |t|
        specify "#{k.name}: #{t}" do
          m = (t.to_s + '_query_facet' ).to_sym
          expect(k.new({}).respond_to?(m)).to be_truthy
        end
      end
    end
  end

  # Check that the query methods in filters have
  # corresponding references in SUBQUERY
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

  context 'app/javascript/**/filter/links/<Model>.js matches content of SUBQUERIES' do
    Dir.glob('app/javascript/**/filter/links/*.js').each do |file|
      n = file.split('/').last
      next unless n =~ /^[A-Z]/ # Constants start with a capital

      # puts n

      filter_name = n.split('.').first.tableize.singularize.to_sym

      models = File.read(file)
      models =~ /.*\[(.*)\]/m
      query_names = $1.split(',').map(&:strip).select{|a| a.present?}.collect{|a| a.gsub('FILTER_', '').downcase.to_sym}

      # Ensure all Model.js constants match what is asserted in SUBQUERIES
      specify "#{n}" do
        a = *::Queries::Query::Filter.inverted_subqueries[filter_name]
        a.delete(:biological_associations_graph) if a # There is no BiologicalAssociationsGraph UI
        a.delete(:dwc_occurrence) if a # ... or  DwcOccurrence
        a.delete(:data_attribute) if a # etc
        a.delete(:controlled_vocabulary_term) if a

        expect( query_names ).to contain_exactly( *a )
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
