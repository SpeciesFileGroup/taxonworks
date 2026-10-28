require 'rails_helper'

# Queries::Pager takes a set (usually `filter.all`), orders it, then pages it.
# See "Sorting and paging" in lib/queries/ARCHITECTURE.md.
describe Queries::Pager, type: :model do
  let(:pager_ids) { ->(set, params = {}) { Queries::Pager.new(set, params).all.map(&:id) } }

  let!(:otu_c) { Otu.create!(name: 'Cus') }
  let!(:otu_a) { Otu.create!(name: 'Aus') }
  let!(:otu_b) { Otu.create!(name: 'Bus') }

  let(:otu_set) { Queries::Otu::Filter.new(otu_id: [otu_a.id, otu_b.id, otu_c.id]).all }

  context 'ordering' do
    specify 'without a sort orders by id' do
      expect(pager_ids.(otu_set)).to eq([otu_c.id, otu_a.id, otu_b.id])
    end

    specify 'applies a sort key' do
      expect(pager_ids.(otu_set, sort: 'name')).to eq([otu_a.id, otu_b.id, otu_c.id])
    end

    specify 'applies a descending sort key' do
      expect(pager_ids.(otu_set, sort: '-name')).to eq([otu_c.id, otu_b.id, otu_a.id])
    end

    specify 'breaks ties on id' do
      otu_tie = Otu.create!(name: 'Aus')
      set = Queries::Otu::Filter.new(otu_id: [otu_tie.id, otu_a.id, otu_b.id]).all
      expect(pager_ids.(set, sort: 'name')).to eq([otu_a.id, otu_tie.id, otu_b.id])
    end

    specify 'an unmatched sort key falls back to id order' do
      expect(pager_ids.(otu_set, sort: 'not_a_sortable_key')).to eq([otu_c.id, otu_a.id, otu_b.id])
    end

    specify 'an unmatched sort key does not drop a matched one' do
      expect(pager_ids.(otu_set, sort: 'not_a_sortable_key,-name')).to eq([otu_c.id, otu_b.id, otu_a.id])
    end

    specify 'unknown and repeated keys do not count toward the cap' do
      keys = (['not_a_sortable_key', 'updated_at'] * Queries::Pager::MAX_SORT_KEYS) + ['-name']
      expect(Queries::Pager.new(otu_set, sort: keys.join(',')).sort_entries)
        .to eq([['updated_at', :asc], ['name', :desc]])
    end

    specify 'caps the number of sort keys, recent and order_by included' do
      keys = Queries::Sort::Base.for(Otu).keys.first(Queries::Pager::MAX_SORT_KEYS + 2)
      entries = Queries::Pager.new(otu_set, sort: keys.join(','), recent: 'true').sort_entries
      expect(entries.length).to eq(Queries::Pager::MAX_SORT_KEYS)
      expect(entries.first).to eq(['updated_at', :desc])
    end

    specify 'accepts ActionController::Parameters' do
      params = ActionController::Parameters.new(sort: '-name')
      expect(pager_ids.(otu_set, params)).to eq([otu_c.id, otu_b.id, otu_a.id])
    end
  end

  context 'sort param' do
    let(:entries) { ->(sort) { Queries::Pager.new(Otu.all, sort:).sort_entries } }

    specify 'blank gives no keys' do
      expect(entries.(nil)).to eq([])
    end

    specify 'no prefix and + are ascending, - is descending' do
      expect(entries.('name,+updated_at,-created_at')).to eq([['name', :asc], ['updated_at', :asc], ['created_at', :desc]])
    end

    specify 'accepts an Array, strips whitespace and drops blanks' do
      expect(entries.([' -name , ', 'updated_at'])).to eq([['name', :desc], ['updated_at', :asc]])
    end

    specify 'drops unknown keys and repeats' do
      expect(entries.('nope,name,-name')).to eq([['name', :asc]])
    end

    specify 'recent is read like other boolean params' do
      expect(Queries::Pager.new(Otu.all, recent: 'TRUE').sort_entries).to eq([['updated_at', :desc]])
      expect(Queries::Pager.new(Otu.all, recent: 'false').sort_entries).to eq([])
    end

    specify 'recent puts the timestamp first, without repeating it' do
      expect(Queries::Pager.new(Otu.all, recent: 'true', sort: 'name,updated_at').sort_entries)
        .to eq([['updated_at', :desc], ['name', :asc]])
    end

    specify 'ends the ORDER BY with the id' do
      sql = Queries::Pager.new(CollectionObject.all, sort: '-collecting_event.verbatim_locality').all.to_sql
      expect(sql).to match(/NULLS LAST, "collection_objects"."id" ASC LIMIT/)
    end
  end

  context 'sort joins and association loading' do
    # Controllers call `includes` on paged results to avoid N+1 queries.
    # A sort's ORDER BY must not make Rails switch those to a JOIN-based
    # eager load (a DISTINCT ids query plus a matching COUNT, both joined
    # to every included has_many).
    %w[identifiers.cached taxon_determinations.otu_name taxon_determinations.year_made].each do |key|
      specify "sort=#{key} keeps includes as separate preload queries" do
        rel = Queries::Pager.new(CollectionObject.all, sort: key).all.includes(:identifiers, :taxon_determinations)
        expect(rel.eager_loading?).to be false
      end
    end

    specify 'references set before sorting are kept' do
      rel = Queries::Pager.new(CollectionObject.references(:identifiers), sort: 'identifiers.cached').all
      expect(rel.references_values).to eq([:identifiers])
    end

    specify 'includes on a non-plain set are kept' do
      rel = Queries::Pager.new(CollectionObject.distinct.includes(:identifiers), sort: 'identifiers.cached').all
      expect(rel.includes_values).to eq([:identifiers])
    end
  end

  context 'paging' do
    specify 'pages with page and per' do
      expect(pager_ids.(otu_set, sort: 'name', per: 2, page: 2)).to eq([otu_c.id])
    end

    # No `paginate` param: truncation always comes with an order.
    specify 'per alone takes the first N in sort order' do
      expect(pager_ids.(otu_set, sort: '-name', per: 2)).to eq([otu_c.id, otu_b.id])
    end

    specify 'per alone without a sort takes the first N by id' do
      expect(pager_ids.(otu_set, per: 2)).to eq([otu_c.id, otu_a.id])
    end

    specify 'total_count counts the set' do
      expect(Queries::Pager.new(otu_set, sort: 'name', per: 2).all.total_count).to eq(3)
    end
  end

  context 'recent' do
    before do
      otu_a.update_column(:updated_at, 3.days.ago)
      otu_b.update_column(:updated_at, 1.day.ago)
      otu_c.update_column(:updated_at, 2.days.ago)
    end

    specify 'orders by updated_at desc' do
      expect(pager_ids.(otu_set, recent: true)).to eq([otu_b.id, otu_c.id, otu_a.id])
    end

    specify 'recent_target created_at orders by created_at desc' do
      otu_a.update_column(:created_at, 1.day.ago)
      otu_b.update_column(:created_at, 3.days.ago)
      otu_c.update_column(:created_at, 2.days.ago)
      expect(pager_ids.(otu_set, recent: true, recent_target: 'created_at')).to eq([otu_a.id, otu_c.id, otu_b.id])
    end

    # e.g. "clone last" (per: 1) after a batch update touched many rows at once.
    specify 'equal timestamps break ties on id' do
      t = 1.hour.ago
      [otu_a, otu_b, otu_c].each { |o| o.update_column(:updated_at, t) }
      expect(pager_ids.(otu_set, recent: true, per: 1)).to eq([otu_c.id])
    end

    specify 'an explicit sort follows recent' do
      t = 1.hour.ago
      otu_a.update_column(:updated_at, t)
      otu_c.update_column(:updated_at, t)
      expect(pager_ids.(otu_set, recent: true, sort: 'name')).to eq([otu_a.id, otu_c.id, otu_b.id])
    end
  end

  context 'set shape' do
    # A set that is not plain (DISTINCT, GROUP BY, from-subquery) can't be
    # ordered by a joined column directly; the pager reduces it first.
    let!(:root) { FactoryBot.create(:root_taxon_name) }
    let!(:genus_z) { Protonym.create!(name: 'Zus', rank_class: Ranks.lookup(:iczn, :genus), parent: root) }
    let!(:genus_y) { Protonym.create!(name: 'Yus', rank_class: Ranks.lookup(:iczn, :genus), parent: root) }

    let!(:otu_z) { Otu.create!(taxon_name: genus_z) }
    let!(:otu_y) { Otu.create!(taxon_name: genus_y) }

    let(:expected) { [otu_y.id, otu_z.id] }
    let(:ids) { [otu_z.id, otu_y.id] }

    specify 'a DISTINCT set' do
      set = Otu.where(id: ids).joins(:taxon_name).distinct
      expect(pager_ids.(set, sort: 'otu')).to eq(expected)
    end

    specify 'a GROUP BY set' do
      set = Otu.where(id: ids).group('otus.id')
      expect(pager_ids.(set, sort: 'otu')).to eq(expected)
    end

    specify 'a from-subquery set' do
      set = Otu.from(Otu.where(id: ids), :otus)
      expect(pager_ids.(set, sort: 'otu')).to eq(expected)
    end

    specify 'a GROUP BY set not grouped by id' do
      set = Otu.where(id: ids).group(:taxon_name_id).select('MIN(otus.id) AS id')
      expect(pager_ids.(set, sort: 'otu')).to eq(expected)
    end

    specify 'a DISTINCT set conditioned on an included association' do
      set = Otu.where(id: ids).includes(:taxon_name).where(taxon_names: {name: %w[Zus Yus]}).references(:taxon_names).distinct
      expect(pager_ids.(set, sort: 'otu')).to eq(expected)
    end

    specify 'a DISTINCT set keeps its select' do
      set = Otu.where(id: ids).select(:id, :name, :taxon_name_id).distinct
      record = Queries::Pager.new(set, sort: 'otu').all.first
      expect(record.has_attribute?(:updated_at)).to be false
    end
  end

  context 'sort classes' do
    specify 'keys are those of the model Sort class' do
      expect(Queries::Sort::Base.for(BiologicalAssociation).keys)
        .to include('id', 'updated_at', 'biological_relationship', 'subject_taxonomy_family', 'object_object_tag')
    end

    specify 'a model without a Sort class has only the timestamp keys' do
      expect(Queries::Sort::Base.for(Container).keys).to contain_exactly('updated_at', 'created_at')
    end

    specify 'User has no keys' do
      expect(Queries::Sort::Base.for(User).keys).to eq([])
    end

    specify 'uses the base class Sort for an STI subclass set' do
      root = FactoryBot.create(:root_taxon_name)
      b = Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, :genus), parent: root)
      a = Protonym.create!(name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus), parent: root)
      expect(pager_ids.(Protonym.where(id: [b.id, a.id]), sort: 'cached')).to eq([a.id, b.id])
    end

    specify 'a model without its own Sort class still sorts by updated_at and created_at' do
      older = FactoryBot.create(:valid_container)
      newer = FactoryBot.create(:valid_container)
      older.update_column(:created_at, 1.day.ago)
      newer.update_column(:updated_at, 1.day.from_now)
      set = Container.where(id: [older.id, newer.id])
      expect(pager_ids.(set, sort: '-updated_at')).to eq([newer.id, older.id])
      expect(pager_ids.(set, sort: 'created_at')).to eq([older.id, newer.id])
    end
  end

  context 'TaxonName' do
    let!(:root) { FactoryBot.create(:root_taxon_name) }
    let!(:family) { Protonym.create!(name: 'Zidae', rank_class: Ranks.lookup(:iczn, :family), parent: root) }
    let!(:genus_b) { Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, :genus), parent: family) }
    let!(:genus_a) { Protonym.create!(name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus), parent: family) }

    let(:names) { [family.id, genus_b.id, genus_a.id] }

    # Formerly TaxonName's own `sort` modes, now ordinary keys of the one `sort` param.
    specify 'sort=alphabetical orders by cached' do
      set = Queries::TaxonName::Filter.new(taxon_name_id: names).all
      expect(pager_ids.(set, sort: 'alphabetical')).to eq([genus_a.id, genus_b.id, family.id])
    end

    specify 'sort=classification orders by depth, then cached' do
      set = Queries::TaxonName::Filter.new(taxon_name_id: names).all
      expect(pager_ids.(set, sort: 'classification').first).to eq(family.id)
    end

    specify 'sort=-classification reverses depth and name' do
      set = Queries::TaxonName::Filter.new(taxon_name_id: names).all
      expect(pager_ids.(set, sort: '-classification')).to eq([genus_b.id, genus_a.id, family.id])
    end

    specify 'orders an ancestrify result (a from-subquery set)' do
      set = Queries::TaxonName::Filter.new(taxon_name_id: [genus_b.id, genus_a.id], ancestrify: true).all
      expected = TaxonName.where(id: set.map(&:id)).order(cached: :desc, id: :asc).pluck(:id)
      expect(expected).to include(family.id, genus_a.id, genus_b.id)
      expect(pager_ids.(set, sort: '-cached')).to eq(expected)
    end
  end

  context 'match_identifiers' do
    let!(:namespace) { FactoryBot.create(:valid_namespace) }
    let!(:co1) { Specimen.create! }
    let!(:co2) { Specimen.create! }
    let!(:co3) { Specimen.create! }

    before do
      [[co1, '111'], [co2, '222'], [co3, '333']].each do |co, i|
        Identifier::Local::CatalogNumber.create!(namespace:, identifier: i, identifier_object: co)
      end
    end

    let(:params) {
      { match_identifiers_type: 'identifier',
        match_identifiers: ["#{namespace.short_name} 222", 'not this one',
                            "#{namespace.short_name} 111", "#{namespace.short_name} 333"].join(','),
        sort: 'match_identifiers' }
    }

    specify 'orders in the order the identifiers were given' do
      set = Queries::CollectionObject::Filter.new(params).all
      expect(pager_ids.(set, params)).to eq([co2.id, co1.id, co3.id])
    end

    specify 'internal ids order as given' do
      p = { match_identifiers_type: 'internal', match_identifiers: [co3.id, co1.id, co2.id].join(','), sort: 'match_identifiers' }
      set = Queries::CollectionObject::Filter.new(p).all
      expect(pager_ids.(set, p)).to eq([co3.id, co1.id, co2.id])
    end

    specify 'order_by=match_identifiers puts it first, before sort' do
      p = params.except(:sort).merge(order_by: 'match_identifiers', sort: '-id')
      set = Queries::CollectionObject::Filter.new(p).all
      expect(pager_ids.(set, p)).to eq([co2.id, co1.id, co3.id])
    end

    specify 'reverses with -match_identifiers' do
      p = params.merge(sort: '-match_identifiers')
      set = Queries::CollectionObject::Filter.new(p).all
      expect(pager_ids.(set, p)).to eq([co3.id, co1.id, co2.id])
    end

    specify 'a record with several matching identifiers appears once' do
      Identifier::Local::CatalogNumber.create!(namespace: FactoryBot.create(:valid_namespace, short_name: 'Other'), identifier: '444', identifier_object: co2)
      p = params.merge(match_identifiers: params[:match_identifiers] + ',Other 444')
      set = Queries::CollectionObject::Filter.new(p).all
      expect(pager_ids.(set, p)).to eq([co2.id, co1.id, co3.id])
      expect(Queries::Pager.new(set, p).all.total_count).to eq(3)
    end

    specify 'a record matched through its container sorts by the container identifier' do
      container = FactoryBot.create(:valid_container)
      container.identifiers << FactoryBot.build(:valid_identifier_local, namespace:, identifier: 'box')
      co4 = Specimen.create!(contained_in: container)
      p = params.merge(match_identifiers: "#{namespace.short_name} box," + params[:match_identifiers])
      set = Queries::CollectionObject::Filter.new(p).all
      expect(pager_ids.(set, p)).to eq([co4.id, co2.id, co1.id, co3.id])
    end

    specify 'an internal id out of the bigint range is ignored' do
      p = { match_identifiers_type: 'internal', match_identifiers: "#{co2.id},99999999999999999999999", sort: 'match_identifiers' }
      set = Queries::CollectionObject::Filter.new(p).all
      expect(pager_ids.(set, p)).to eq([co2.id])
    end

    specify 'caseless=False is case sensitive, as in the facet' do
      p = params.merge(match_identifiers: "#{namespace.short_name} 333,#{namespace.short_name.swapcase} 111,#{namespace.short_name} 222", match_identifiers_caseless: 'False')
      set = Queries::CollectionObject::Filter.new(p).all
      expect(pager_ids.(set, p)).to eq([co3.id, co2.id])
    end

    specify 'an unknown match_identifiers_type is no sort, so default_order applies' do
      p = params.merge(match_identifiers_type: 'nope', sort: nil, order_by: 'match_identifiers')
      expect(Queries::Pager.new(CollectionObject.all, p).sort_entries).to eq([])
    end

    specify 'adds no references' do
      set = Queries::CollectionObject::Filter.new(params).all
      expect(Queries::Sort::MatchIdentifiers.new(CollectionObject, params.with_indifferent_access).apply(set).references_values).to eq([])
    end

    specify 'total_count is not inflated' do
      set = Queries::CollectionObject::Filter.new(params).all
      expect(Queries::Pager.new(set, params).all.total_count).to eq(3)
    end
  end
end
