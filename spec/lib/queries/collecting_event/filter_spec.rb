require 'rails_helper'

describe Queries::CollectingEvent::Filter, type: :model, group: [:collecting_event] do

  let(:query) { Queries::CollectingEvent::Filter.new({}) }

  let!(:ce1) { CollectingEvent.create(
    verbatim_locality: 'Out there',
    start_date_year: 2010,
    start_date_month: 2,
    start_date_day: 18)
  }

  let!(:ce2) { CollectingEvent.create(
    verbatim_locality: 'Out there, under the stars',
    verbatim_field_number: 'Foo manchu',
    start_date_year: 2000,
    start_date_month: 2,
    start_date_day: 18,
    print_label: 'THERE: under the stars:18-2-2000') }

  # let!(:namespace) { FactoryBot.create(:valid_namespace, short_name: 'Foo') }
  # let!(:i1) { Identifier::Local::FieldNumber.create!(identifier_object: ce1, identifier: '123', namespace: namespace) }
  # let(:p1) { FactoryBot.create(:valid_person, last_name: 'Smith') }

  specify '#recent' do
    query.recent = true
    expect(query.all.map(&:id)).to contain_exactly(ce2.id, ce1.id)
  end

  context 'otus' do
    let!(:o) { Otu.create!(name: 'foo') }
    let!(:s) { Specimen.create!(collecting_event: ce1, taxon_determinations_attributes: [{otu: o}]) }

    specify '#otu_id' do
      q = Queries::CollectingEvent::Filter.new(otu_id: [o.id])
      expect(q.all).to contain_exactly(ce1)
    end
  end

  specify '#collection_objects' do
    CollectionObject.create!(collecting_event: ce1, total: 1)
    query.collection_objects = true
    expect(query.all.map(&:id)).to contain_exactly(ce1.id)
  end

  specify '#collection_objects' do
    CollectionObject.create!(collecting_event: ce1, total: 1)
    query.collection_objects = false
    expect(query.all.map(&:id)).to contain_exactly(ce2.id)
  end

  specify 'auto added accessors 1' do
    expect(query).to respond_to(:field_notes)
  end

  specify 'attributes are persisted 1' do
    q = Queries::CollectingEvent::Filter.new(field_notes: 'Foo')
    expect(q.field_notes).to eq('Foo')
  end

  specify 'attributes can be set 1' do
    query.field_notes = 'Foo'
    expect(query.field_notes).to eq('Foo')
  end

  specify 'and clauses 1' do
    query.start_date_year = 2000
    expect(query.all).to contain_exactly(ce2)
  end

  specify 'and clauses 2' do
    query.start_date_year = 2000
    query.start_date_month = 3
    expect(query.all).to contain_exactly()
  end

  specify 'md5 1' do
    ce2.update!(verbatim_label: 'QQQQ')
    query.md5_verbatim_label = true
    query.in_labels = 'QQQ'
    expect(query.all.map(&:id)).to contain_exactly()
  end

  specify 'md5 2' do
    ce2.update!(verbatim_label: 'QQQQ')
    query.md5_verbatim_label = true
    query.in_labels = 'QQQQ'
    expect(query.all.map(&:id)).to contain_exactly(ce2.id)
  end

  specify 'between date range 1' do
    query.start_date = '1999-1-1'
    query.end_date = '2001-1-1'
    expect(query.all.map(&:id)).to contain_exactly(ce2.id)
  end

  specify 'between date range 1, ActionController::Parameters' do
    h = {start_date: '1999-1-1', end_date: '2001-1-1'}
    p = ActionController::Parameters.new( h )
    q = Queries::CollectingEvent::Filter.new(p)

    expect(q.all.map(&:id)).to contain_exactly(ce2.id)
  end

  specify 'between date range 2 - conflicts' do
    query.start_date_year = '1945'
    query.start_date = '1999-1-1'
    query.end_date = '2001-1-1'
    expect(query.all.map(&:id)).to contain_exactly()
  end

  specify '#in_labels' do
    query.in_labels = 'star'
    expect(query.all.map(&:id)).to contain_exactly(ce2.id)
  end

  specify '#in_labels' do
    query.in_labels = 'star'
    expect(query.all.map(&:id)).to contain_exactly(ce2.id)
  end

  specify '#keyword_id_and[]' do
    t = Tag.create(tag_object: ce1, keyword: FactoryBot.create(:valid_keyword))
    query.keyword_id_and = [t.keyword_id]
    expect(query.all.map(&:id)).to contain_exactly(ce1.id)
  end

  specify '#geographic_area_id[]' do
    ce1.update!(geographic_area: FactoryBot.create(:valid_geographic_area))
    query.geographic_area_id = [ce1.geographic_area_id]
    expect(query.all.map(&:id)).to contain_exactly(ce1.id)
  end

  context 'geo' do
    let(:point_lat) { '10.0' }
    let(:point_long) { '10.0' }

    # let(:factory_polygon) { RSPEC_GEO_FACTORY.polygon(point_lat, point_long) }
    let(:factory_point) { RSPEC_GEO_FACTORY.point(point_lat, point_long) }
    let(:geographic_item) { GeographicItem.create!( geography: factory_point ) }

    let!(:point_georeference) {
      Georeference::VerbatimData.create!(
        collecting_event: ce1,
        geographic_item:
      )
    }

    let(:wkt_point) { 'POINT (10.0 10.0)'}
    let(:wkt_polygon) { 'POLYGON ((5 5, 15 5, 15 15, 5 15, 5 5))'}
    let(:wkt_multipolygon) { 'MULTIPOLYGON ( ((5 5, 15 5, 15 15, 5 15, 5 5)), ((20 35, 35 35, 40 40, 20 35)) )' }

    let(:geo_json_polygon) {
      '{ "type": "Polygon","coordinates": [[ [5.0, 5.0], [15.0, 5.0], [15.0, 15.0], [5.0, 15.0], [5.0, 5.0] ]] }'
    }

    let(:gi_polygon) {
      FactoryBot.create(:geographic_item, geography: wkt_polygon)
    }

    let(:gz_polygon) {
      FactoryBot.create(:gazetteer,
        geographic_item: gi_polygon,
        name: 'gi_polygon'
      )
    }

    specify '#wkt (POINT)' do
      query.wkt = wkt_point
      expect(query.all.map(&:id)).to contain_exactly(ce1.id)
    end

    specify '#wkt (POLYGON)' do
      query.wkt = wkt_polygon
      expect(query.all.map(&:id)).to contain_exactly(ce1.id)
    end

    specify '#wkt (MULTIPOLYGON)' do
      query.wkt = wkt_multipolygon
      expect(query.all.map(&:id)).to contain_exactly(ce1.id)
    end

    specify '#geo_json (POLYGON)' do
      query.geo_json = geo_json_polygon
      expect(query.all.map(&:id)).to contain_exactly(ce1.id)
    end

    specify '#gazetteer_id' do
      query.gazetteer_id = gz_polygon.id
      expect(query.all.map(&:id)).to contain_exactly(ce1.id)
    end

  end
end
