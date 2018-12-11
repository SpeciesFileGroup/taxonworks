require 'rails_helper'

describe Queries::CollectingEvent::Filter, type: :model, group: [:collecting_event] do

  let(:query) { Queries::CollectingEvent::Filter.new({}) }

  let!(:ce1) { CollectingEvent.create(verbatim_locality: 'Out there', start_date_year: 2010, start_date_month: 2, start_date_day: 18) }

  let!(:ce2) { CollectingEvent.create(verbatim_locality: 'Out there, under the stars', 
                                      verbatim_trip_identifier: 'Foo manchu',
                                      start_date_year: 2000, 
                                      start_date_month: 2, 
                                      start_date_day: 18,
                                      print_label: 'THERE: under the stars:18-2-2000') }



  # let!(:namespace) { FactoryBot.create(:valid_namespace, short_name: 'Foo') }
  # let!(:i1) { Identifier::Local::TripCode.create!(identifier_object: ce1, identifier: '123', namespace: namespace) }
  # let(:p1) { FactoryBot.create(:valid_person, last_name: 'Smith') }

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

  specify 'between date range 1' do
    query.start_date = '1999/1/1'
    query.end_date = '2001/1/1'
    expect(query.all.map(&:id)).to contain_exactly(ce2.id)
  end

  specify 'between date range 2 - conflicts' do
    query.start_date_year = '1945'
    query.start_date = '1999/1/1'
    query.end_date = '2001/1/1'
    expect(query.all.map(&:id)).to contain_exactly()
  end

  specify '#in_labels' do
    query.in_labels = 'star'
    expect(query.all.map(&:id)).to contain_exactly(ce2.id)
  end

  specify '#in_verbatim_locality' do
    query.in_verbatim_locality = 'Under'
    expect(query.all.map(&:id)).to contain_exactly(ce2.id)
  end

  specify '#in_labels' do
    query.in_labels = 'star'
    expect(query.all.map(&:id)).to contain_exactly(ce2.id)
  end

  specify '#recent' do
    query.recent = 1 
    expect(query.all.map(&:id)).to contain_exactly(ce2.id)
  end

  context 'annotations' do
    let(:keyword) { FactoryBot.create(:valid_keyword) }
    let!(:tag) { Tag.create(tag_object: ce1, keyword: keyword) }

    specify '#keyword_ids[]' do
      query.keyword_ids = [keyword.id]
      expect(query.all.map(&:id)).to contain_exactly(ce1.id)
    end
  end

  context 'geo' do
    let(:point_lat) { '20.0' }
    let(:point_long) { '20.0' }

    let(:factory_point) { RSPEC_GEO_FACTORY.point(point_lat, point_long) }

    let(:geographic_item) { GeographicItem::Point.create!( point: factory_point ) }

    let!(:point_georeference) {
      Georeference::VerbatimData.create!(
        collecting_event: ce1,
        geographic_item: geographic_item,
      )
    }

    let(:point_shape) { 
      s = geographic_item.to_geo_json_feature
      s['properties'].merge!('radius' => 20)
      s
    }

    specify '#shape (point)' do
      query.shape = point_shape
      expect(query.all.map(&:id)).to contain_exactly(ce1.id)
    end 

    specify '#shape, combined 1' do
      query.shape = point_shape
      query.in_verbatim_locality = 'out'
      expect(query.all.map(&:id)).to contain_exactly(ce1.id)
    end

    specify '#shape, combined 2' do
      query.shape = point_shape
      query.in_verbatim_locality = 'RRRRAWR!'
      expect(query.all.map(&:id)).to contain_exactly()
    end
  end

end
