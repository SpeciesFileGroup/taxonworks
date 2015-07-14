require 'rails_helper'

describe Otu, :type => :model do

  let(:otu) { Otu.new }
  before(:all) do
    TaxonName.delete_all
  end

  after(:all) do
    TaxonNameRelationship.delete_all
  end

  # foreign key relationships
  context 'associations' do
    context 'has many' do
      specify 'taxon determinations' do
        expect(otu.taxon_determinations << TaxonDetermination.new).to be_truthy
      end

      specify 'contents' do
        expect(otu.contents << Content.new).to be_truthy
      end

      specify 'topics' do
        expect(otu.topics << Topic.new).to be_truthy
      end
    end
  end

  context 'properties' do
    specify 'name' do
      expect(otu).to respond_to(:name)
    end
  end

  context 'validation' do
    specify 'otu without name and without taxon_name_id is invalid' do
      expect(otu.valid?).to be_falsey
    end
    specify 'otu should require a name or taxon_name_id' do
      otu.soft_validate(:taxon_name)
      expect(otu.soft_validations.messages_on(:taxon_name_id).count).to eq(1)
    end
    specify 'duplicate OTU' do
      o1 = FactoryGirl.create(:otu, name: 'Aus')
      o2 = FactoryGirl.build_stubbed(:otu, name: 'Aus')
      o1.soft_validate(:duplicate_otu)
      expect(o1.soft_validations.messages_on(:taxon_name_id).empty?).to be_truthy
      o2.soft_validate(:duplicate_otu)
      expect(o2.soft_validations.messages_on(:taxon_name_id).count).to eq(1)
    end
  end

  context 'when I create a new OTU' do
    context 'and it only has taxon_name_id populated' do
      specify 'its otu_name should be the taxon name cached_html' do
        expect(otu.otu_name).to eq(nil)

        t = FactoryGirl.create(:relationship_species)
        t.reload
        expect(t.valid?).to be_truthy

        otu.taxon_name = t
        expect(otu.otu_name).to eq('<em>Erythroneura vitis</em> McAtee, 1900')

        otu.name = 'Foo'
        expect(otu.otu_name).to eq('Foo')
      end
    end
  end

  context 'batch loading' do
    let(:file) {
      f   = File.new('/tmp/temp', 'w+')
      str = CSV.generate do |csv|
        csv << ["Aus"]
        csv << ["Bus"]
        csv << [nil]
        csv << ["Cus"]
      end
      f.write str
      f.rewind
      f
    }

    context '.batch_preview' do
      specify '.batch_preview takes a file argument' do
        expect(Otu.batch_preview(file: file)).to be_truthy
      end

      specify '.batch_preview takes hash of arguments' do
        hsh = {file: file, stuff: :things}
        expect(Otu.batch_preview(hsh)).to be_truthy
      end

      specify '.batch_preview returns an Array' do
        expect(Otu.batch_preview(file: file).class).to eq(Array)
      end

      specify '.batch_preview ignores blank lines' do
        expect(Otu.batch_preview(file: file).count).to eq(3)
      end

      specify '.batch_preview takes the first row as headers' do
        expect(Otu.batch_preview(file: file).count).to eq(3)
      end

      specify 'returns Otus' do
        expect(Otu.batch_preview(file: file).first.class).to eq(Otu)
      end

      specify 'returns Otus with names' do
        expect(Otu.batch_preview(file: file).first.name).to eq('Aus')
      end
    end

    context '.batch_create' do
      let(:params) {
        {otus:
           {'1' => {'name' => 'Aus'},
            '2' => {'name' => 'Bus'}}
        }
      }

      specify 'returns an array' do
        expect(Otu.batch_create(params).class).to eq(Array)
      end

      specify 'returns an array of Otus' do
        expect(Otu.batch_create(params).first.class).to eq(Otu)
      end

      specify 'returns named Otus' do
        expect(Otu.batch_create(params).first.name).to eq('Aus')
      end

      specify 'returns multiple Otus' do
        expect(Otu.batch_create(params).count).to eq(2)
      end

    end

  end

  context 'concerns' do
    it_behaves_like 'citable'
    it_behaves_like 'data_attributes'
    it_behaves_like 'identifiable'
    it_behaves_like 'notable'
    it_behaves_like 'taggable'
    it_behaves_like 'is_data'
  end

  context 'complex interactions' do
    let(:a_d1) { FactoryGirl.create(:valid_asserted_distribution) }
    let(:a_d2) { FactoryGirl.create(:valid_asserted_distribution) }
    let(:a_d3) { FactoryGirl.create(:valid_asserted_distribution) }
    let(:otu1) { a_d1.otu }
    let(:otu2) { a_d2.otu }
    let(:box_1) { RSPEC_GEO_FACTORY.multi_polygon([RSPEC_GEO_FACTORY.polygon(LIST_T1)]) }
    let(:box_2) { RSPEC_GEO_FACTORY.multi_polygon([RSPEC_GEO_FACTORY.polygon(LIST_T2)]) }
    let(:box_3) { RSPEC_GEO_FACTORY.multi_polygon([RSPEC_GEO_FACTORY.polygon(LIST_T3)]) }
    let(:box_4) { RSPEC_GEO_FACTORY.multi_polygon([RSPEC_GEO_FACTORY.polygon(LIST_T4)]) }
    let(:item_a) { FactoryGirl.create(:geographic_item_multi_polygon, multi_polygon: box_1) }
    let(:item_b) { FactoryGirl.create(:geographic_item_multi_polygon, multi_polygon: box_2) }
    let(:item_c) { FactoryGirl.create(:geographic_item_multi_polygon, multi_polygon: box_3) }
    let(:item_d) { FactoryGirl.create(:geographic_item_multi_polygon, multi_polygon: box_4) }
    let(:area_a) { FactoryGirl.create(:valid_geographic_area, {name: 'Area_A'}) }
    let(:area_b) { FactoryGirl.create(:valid_geographic_area, {name: 'Area_B'}) }
    let(:area_c) { FactoryGirl.create(:valid_geographic_area, {name: 'Area_C'}) }
    let(:area_d) { FactoryGirl.create(:valid_geographic_area, {name: 'Area_D'}) }
    let(:p0) { FactoryGirl.create(:geographic_item_point, point: POINT0.as_binary) }
    let(:c_e1) { FactoryGirl.create(:valid_collecting_event, {geographic_area: area_a,
                                                              verbatim_label:  'c_e1'}) }
    let(:c_e2) { FactoryGirl.create(:valid_collecting_event, {geographic_area: area_b,
                                                              verbatim_label:  'c_e2'}) }
    let(:c_e3) { FactoryGirl.create(:valid_collecting_event, {geographic_area: area_c,
                                                              verbatim_label:  'c_e3'}) }
    let(:g_r1) { FactoryGirl.create(:georeference_verbatim_data,
                                    api_request:           'gr00_a',
                                    collecting_event:      c_e1,
                                    error_geographic_item: item_a,
                                    geographic_item:       p0) }
    let(:g_r2) { FactoryGirl.create(:georeference_verbatim_data,
                                    api_request:           'gr00_b',
                                    collecting_event:      c_e2,
                                    error_geographic_item: item_b,
                                    geographic_item:       p0) }
    let(:g_r3) { FactoryGirl.create(:georeference_verbatim_data,
                                    api_request:           'gr00_c',
                                    collecting_event:      c_e3,
                                    error_geographic_item: item_c,
                                    geographic_item:       p0) }
    let(:g_r4) { FactoryGirl.create(:georeference_verbatim_data,
                                    api_request:           'gr00_d',
                                    collecting_event:      c_e1,
                                    error_geographic_item: item_d,
                                    geographic_item:       p0) }
    let(:c_o1) { FactoryGirl.create(:valid_collection_object, {collecting_event: c_e1}) }
    let(:c_o2) { FactoryGirl.create(:valid_collection_object, {collecting_event: c_e2}) }
    let(:c_o3) { FactoryGirl.create(:valid_collection_object, {collecting_event: c_e3}) }
    let(:t_d1) { FactoryGirl.create(:valid_taxon_determination, {otu: otu1, biological_collection_object: c_o1}) }
    let(:t_d2) { FactoryGirl.create(:valid_taxon_determination, {otu: otu2, biological_collection_object: c_o2}) }
    let(:t_d3) { FactoryGirl.create(:valid_taxon_determination, {otu: otu1, biological_collection_object: c_o3}) }

    before(:each) {
      area_a.geographic_items.push(item_a)
      area_b.geographic_items.push(item_b)
      area_c.geographic_items.push(item_c)
      area_d.geographic_items.push(item_d)
      [area_a, area_b, area_c, area_d].map(&:save)
      a_d1.geographic_area = area_a
      a_d3.geographic_area = area_c
      a_d3.otu             = otu1
      [a_d1, a_d2, a_d3,
       otu1, otu2,
       c_e1, c_e2, c_e3,
       g_r1, g_r2, g_r3,
       c_o1, c_o2, c_o3,
       t_d1, t_d2, t_d3].map(&:save)
    }
    context 'distribution' do

      specify 'the otu can find its asserted distribution' do
        a_ds1 = otu1.asserted_distributions
        expect(a_ds1.count).to eq(2)
        expect(a_ds1).to contain_exactly(a_d1, a_d3)
        expect(a_ds1.first.geographic_area.name).to eq('Area_A')
        expect(a_ds1.last.geographic_area.name).to eq('Area_C')

        a_ds2 = otu2.asserted_distributions
        expect(a_ds2.count).to eq(1)
        expect(a_ds2).to contain_exactly(a_d2)
      end

      specify 'the otu can find its taxon_determinations' do
        t_ds1 = otu1.taxon_determinations
        expect(t_ds1.count).to eq(2)
        expect(t_ds1).to contain_exactly(t_d1, t_d3)

        t_ds2 = otu2.taxon_determinations
        expect(t_ds2.count).to eq(1)
        expect(t_ds2).to contain_exactly(t_d2)
      end

      specify 'the otu can find its collecting_events' do
        c_es1 = otu1.collecting_events
        expect(c_es1.count).to eq(2)
        expect(c_es1).to contain_exactly(c_e1, c_e3)

        c_es2 = otu2.collecting_events
        expect(c_es2.count).to eq(1)
        expect(c_es2).to contain_exactly(c_e2)
      end

      specify 'the otu can produce some geo_JSON' do
        # pending 'proper declaration of result geoJSON'
        geo_data = otu1.distribution_geoJSON
        expect(geo_data['type']).to eq('Aggregation')
        expect(geo_data['features'].count).to eq(3)
        expect(geo_data['properties'].keys).to contain_exactly('distribution')
        expect(geo_data['properties']['distribution']).to eq(geo_data['features'].count)

        expect(geo_data['features'][0]['type']).to eq('FeatureCollection')
        expect(geo_data['features'][0]['properties']).to eq({asserted_distributions: {'count' => 2}})
        expect(geo_data['features'][0]['features'][0]['type']).to eq('Feature')
        expect(geo_data['features'][0]['features'][0]['geometry']['type']).to eq('MultiPolygon')
        expect(geo_data['features'][0]['features'][0]['geometry']['coordinates'][0][0][0]).to eq([-1, 1, 0])
        expect(geo_data['features'][0]['features'][0]['geometry']['coordinates'][0][0][4]).to eq([-1, 1, 0])
        expect(geo_data['features'][0]['features'][1]['geometry']['coordinates'][0][0][0]).to eq([-3, 3, 0])
        expect(geo_data['features'][0]['features'][1]['geometry']['coordinates'][0][0][4]).to eq([-3, 3, 0])
        expect(geo_data['features'][0]['features'][0]['properties']['geographic_area']).to eq({'id' => area_a.id, 'tag' => 'Area_A'})
        expect(geo_data['features'][0]['features'][1]['properties']['geographic_area']).to eq({'id' => area_c.id, 'tag' => 'Area_C'})

        expect(geo_data['features'][1]['type']).to eq('FeatureCollection')
        expect(geo_data['features'][1]['properties']).to eq({collecting_events_georeferences: {'count' => 2}})
        expect(geo_data['features'][1]['features'][0]['properties']).to eq('collecting_event' => {'id' => c_e1.id, 'tag' => "Collecting event #{c_e1.id}."})
        expect(geo_data['features'][1]['features'][1]['properties']).to eq('collecting_event' => {'id' => c_e3.id, 'tag' => "Collecting event #{c_e3.id}."})

        expect(geo_data['features'][2]['type']).to eq('FeatureCollection')
        expect(geo_data['features'][2]['properties']).to eq({collecting_events_geographic_area: {'count' => 2}})
        expect(geo_data['features'][2]['features'][0]['properties']).to eq('geographic_area' => {'id' => area_a.id, 'tag' => 'Area_A'})
        expect(geo_data['features'][2]['features'][1]['properties']).to eq('geographic_area' => {'id' => area_c.id, 'tag' => 'Area_C'})
      end
    end
  end
end
