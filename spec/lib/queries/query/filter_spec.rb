require 'rails_helper'

Dir.glob('lib/queries/**/filter.rb').each do |f|
  require_relative Rails.root + f
end

# Meta-tests
describe Queries::Query::Filter, type: [:model] do

  let(:query) { Queries::Query::Filter.new({}) }
  filters = ::Queries::Query::Filter.descendants

  # !! Careful, this is internal use only, involved
  # !! in things like Person filters across projects.
  specify '#project_id = false? / #only_project?' do
    a = ::Queries::Otu::Filter.new(project_id: false)
    expect(a.only_project?).to be_falsey
  end

  specify '#project_id = false' do
    a = ::Queries::Otu::Filter.new(project_id: false)
    expect(a.project_id).to eq([])
  end

  specify '#only_project?' do
    a = ::Queries::Otu::Filter.new({})
    expect(a.only_project?).to be_truthy # project_id is applied by default
  end

  specify '#only_project?' do
    a = ::Queries::Otu::Filter.new({})
    a.otu_id = 1
    expect(a.only_project?).to be_falsey # project_id is applied by default
  end

  context '#apply_venn' do
    let(:o1) { FactoryBot.create(:valid_otu) }
    let(:o2) { FactoryBot.create(:valid_otu) }
    let(:o3) { FactoryBot.create(:valid_otu) }

    specify '#apply_venn ab' do
      v = "http://127.0.0.1:3000/otus/filter.json?name=#{o2.name}"
      a = ::Queries::Otu::Filter.new(otu_id: [o1.id, o2.id, o3.id], venn: v, venn_mode: :ab)
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

    specify '#apply_venn #venn_mode b multiply encoded' do
      v = "http://127.0.0.1:3000/otus/filter.json?otu_id%25255B%25255D=#{o2.id}&otu_id%25255B%25255D=#{o3.id}"
      a = ::Queries::Otu::Filter.new(otu_id: [o2.id], venn: v, venn_mode: :b)
      expect(a.all).to contain_exactly(o3)
    end

    specify '#venn_query includes b pagination by default' do
      v = "http://127.0.0.1:3000/otus/filter.json?otu_id[]=#{o1.id}&otu_id[]=#{o2.id}&otu_id[]=#{o3.id}&paginate=true&page=2&per=1"

      a = ::Queries::Otu::Filter.new(
        otu_id: [o1.id, o2.id, o3.id], venn: v, venn_mode: :a)
      expect(a.all).to contain_exactly(o1, o3)
    end

    specify '#venn_query #venn_ignore_pagination' do
      v = "http://127.0.0.1:3000/otus/filter.json?otu_id[]=#{o1.id}&otu_id[]=#{o2.id}&paginate=true&page=2&per=1"

      a = ::Queries::Otu::Filter.new(
        otu_id: [o1.id, o2.id, o3.id],
        venn: v, venn_mode: :a, venn_ignore_pagination: true
      )
      expect(a.all).to contain_exactly(o3)
    end
  end

  context 'order_by' do
    context 'order_by: :match_identifiers' do
      let(:query) { Queries::CollectionObject::Filter.new({}) }

      let!(:namespace) { FactoryBot.create(:valid_namespace) }

      let!(:co1) { Specimen.create! }
      let!(:co2) { Specimen.create! }
      let!(:co3) { Specimen.create! }

      let!(:id1) do
        Identifier::Local::CatalogNumber.create!(
          namespace: namespace,
          identifier: '111',
          identifier_object: co1
        )
      end

      let!(:id2) do
        Identifier::Local::CatalogNumber.create!(
          namespace: namespace,
          identifier: '222',
          identifier_object: co2
        )
      end

      let!(:id3) do
        Identifier::Local::CatalogNumber.create!(
          namespace: namespace,
          identifier: '333',
          identifier_object: co3
        )
      end

      before do
        query.match_identifiers_type = 'identifier'
        query.match_identifiers = [
          "#{namespace.short_name} 222",
          'not this one',
          "#{namespace.short_name} 111",
          "#{namespace.short_name} 333"
        ].join(',')

        query.order_by = :match_identifiers
      end

      specify 'orders results to match the order of match_identifiers' do
        expect(query.all.to_a).to eq [co2, co1, co3] # ordered
      end

      specify 'can be counted without raising (regression check)' do
        expect(query.all.count).to eq 3
      end
    end
  end


  context 'venn param preservation' do
    specify 'venn params are preserved in filter params hash' do
      v = 'http://127.0.0.1:3000/otus/filter.json?name=Ant'
      q = ::Queries::Otu::Filter.new(
        otu_id: [1, 2],
        venn: v,
        venn_mode: 'ab',
        venn_ignore_pagination: true
      )

      # Venn params should be in the params hash
      expect(q.params[:venn]).to eq(v)
      expect(q.params[:venn_mode]).to eq('ab')
      expect(q.params[:venn_ignore_pagination]).to be_truthy
    end

    specify 'venn params are preserved when filter is reconstructed' do
      v = 'http://127.0.0.1:3000/otus/filter.json?name=Ant'
      q = ::Queries::Otu::Filter.new(
        otu_id: [1, 2],
        venn: v,
        venn_mode: 'a',
        venn_ignore_pagination: false
      )

      # Reconstruct filter from params (as done in batch_by_filter_scope)
      reconstructed = ::Queries::Query::Filter.instantiated_base_filter(
        { 'otu_query' => q.params }
      )

      # Venn params should be preserved in reconstructed filter
      expect(reconstructed.venn).to eq(v)
      expect(reconstructed.venn_mode).to eq(:a)
      expect(reconstructed.venn_ignore_pagination).to be_falsey
    end

    specify 'venn params work with ActionController::Parameters' do
      v = 'http://127.0.0.1:3000/otus/filter.json?name=Ant'
      p = ActionController::Parameters.new(
        otu_query: {
          otu_id: [1, 2],
          venn: v,
          venn_mode: 'ab',
          venn_ignore_pagination: 'true'
        }
      )

      q = ::Queries::Query::Filter.instantiated_base_filter(p)

      expect(q.venn).to eq(v)
      expect(q.venn_mode).to eq(:ab)
      expect(q.venn_ignore_pagination).to be_truthy
      expect(q.params[:venn]).to eq(v)
    end

    specify 'venn params are preserved in nested subqueries' do
      # Test that venn works on a subquery (e.g., otu_query within collection_object_query)
      otu_venn = 'http://127.0.0.1:3000/otus/filter.json?name=Formicidae'

      q = ::Queries::CollectionObject::Filter.new(
        collection_object_id: [1, 2, 3],
        otu_query: {
          otu_id: [10, 20],
          venn: otu_venn,
          venn_mode: 'ab',
          venn_ignore_pagination: true
        }
      )

      # Check the nested otu_query has venn params
      expect(q.otu_query).to be_present
      expect(q.otu_query.venn).to eq(otu_venn)
      expect(q.otu_query.venn_mode).to eq(:ab)
      expect(q.otu_query.venn_ignore_pagination).to be_truthy

      # Check venn params are in the nested query's params hash
      expect(q.otu_query.params[:venn]).to eq(otu_venn)
      expect(q.otu_query.params[:venn_mode]).to eq('ab')
      expect(q.otu_query.params[:venn_ignore_pagination]).to be_truthy
    end

    specify 'venn params in subqueries survive reconstruction' do
      # Test that venn on subqueries survives the serialization/reconstruction cycle
      otu_venn = 'http://127.0.0.1:3000/otus/filter.json?name=Formicidae'

      q = ::Queries::CollectionObject::Filter.new(
        collection_object_id: [1, 2, 3],
        otu_query: {
          otu_id: [10, 20],
          venn: otu_venn,
          venn_mode: 'a',
          venn_ignore_pagination: false
        }
      )

      # Reconstruct from params (simulating batch_by_filter_scope)
      reconstructed = ::Queries::Query::Filter.instantiated_base_filter(
        { 'collection_object_query' => q.params }
      )

      # Nested otu_query should still have venn params
      expect(reconstructed.otu_query).to be_present
      expect(reconstructed.otu_query.venn).to eq(otu_venn)
      expect(reconstructed.otu_query.venn_mode).to eq(:a)
      expect(reconstructed.otu_query.venn_ignore_pagination).to be_falsey
    end
  end

  specify '#venn_query' do
    v = 'http://127.0.0.1:3000/otus/filter.json?per=50&name=Ant&extend%5B%5D=taxonomy&page=1'

    q = ::Queries::Otu::Filter.new({})
    q.venn = v
    expect(q.venn_query.class).to eq(::Queries::Otu::Filter)
  end

  specify '#venn_query params includes pagination params by default' do
    v = 'http://127.0.0.1:3000/otus/filter.json?per=50&name=Ant&extend%5B%5D=taxonomy&page=1&paginate=true'

    q = ::Queries::Otu::Filter.new({})
    q.venn = v
    b = q.venn_query
    expect(b.params).to eq({name: 'Ant', paginate: 'true', page: '1', per: '50'})
  end

  specify '#venn_query #venn_ignore_pagination=true' do
    v = 'http://127.0.0.1:3000/otus/filter.json?per=50&name=Ant&extend%5B%5D=taxonomy&page=1&paginate=true'

    q = ::Queries::Otu::Filter.new({
      venn: v,
      venn_ignore_pagination: 'true'
    })
    b = q.venn_query
    expect(b.params).to eq({name: 'Ant'})
  end

  specify '#venn_mode 0' do
    query.venn_mode = 'ab'
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
    expect(Queries::Query::Filter.instantiated_base_filter(p).referenced_klass).to eq(::Otu)
  end

  specify '.instantiated_base_filter 1' do
    p = ActionController::Parameters.new(otu_query: {otu_id: [1,2,3]}, foo: :bar)
    expect(Queries::Query::Filter.instantiated_base_filter(p).otu_id).to eq([1,2,3])
  end

  specify '.instantiated_base_filter params 1 ' do
    p = ActionController::Parameters.new(collecting_event_query: {wildcard_attribute: 'verbatim_locality'})
    expect(Queries::Query::Filter.instantiated_base_filter(p).params).to include(:wildcard_attribute)
  end

  specify '.instantiated_base_filter params 2 ' do
    p = ActionController::Parameters.new(collecting_event_query: {wildcard_attribute: ['verbatim_locality']})
    expect(Queries::Query::Filter.instantiated_base_filter(p).params).to include(:wildcard_attribute)
  end

  specify '.base_filter 1' do
    p = ActionController::Parameters.new(collection_object_query: {}, foo: :bar)
    expect(Queries::Query::Filter.base_filter(p)).to eq(::Queries::CollectionObject::Filter)
  end

  specify '.base_filter 1' do
    p = ActionController::Parameters.new(collection_object_query: { otu_query: {}}, foo: :bar)
    expect(Queries::Query::Filter.base_filter(p)).to eq(::Queries::CollectionObject::Filter)
  end

  specify '#disable_paging' do
    o1 = FactoryBot.create(:valid_otu)
    o2 = FactoryBot.create(:valid_otu)

    a = ::Queries::Otu::Filter.new(
      otu_id: [o1.id, o2.id], paginate: true, per: 1, page: 1
    )
    a.disable_paging
    expect(a.paginate).to be_falsey
    expect(a.all.count).to eq(2)
  end

  specify '#disable_paging .set_paging' do
    o1 = FactoryBot.create(:valid_otu)
    o2 = FactoryBot.create(:valid_otu)

    a = ::Queries::Otu::Filter.new(
      otu_id: [o1.id, o2.id], paginate: true, per: 1, page: 2
    )
    state = a.disable_paging
    q = a.all
    q = a.class.set_paging(q, state)

    expect(q.current_page).to be(2)
    expect(q.limit_value).to be(1) # per
    expect(q.count).to eq(1)
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
      next if k.name =~ /Image|Source|DataAttribute|Observation/ # Queries are dynamically added in these filters, and have no corresponding method name
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
      # TaxonNameRelationship sends to TaxonName in 3 different ways.
      next if ['TaxonNameRelationship.js'].include?(n)

      # puts n

      filter_name = n.split('.').first.tableize.singularize.to_sym

      models = File.read(file)
      models =~ /.*\[(.*)\]/m
      query_names = $1.split(',').map(&:strip).select{|a| a.present?}.collect{|a| a.gsub('FILTER_', '').downcase.to_sym}

      # Ensure all Model.js constants match what is asserted in SUBQUERIES
      specify "#{n}" do
        a = *::Queries::Query::Filter.inverted_subqueries[filter_name]
        a.delete(:biological_associations_graph) if a # There is no BiologicalAssociationsGraph UI
        a.delete(:data_attribute) if a # etc
        a.delete(:controlled_vocabulary_term) if a
        a.delete(:conveyance) if a # There is no depiction filter
        a.delete(:depiction) if a # There is no depiction filter

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
