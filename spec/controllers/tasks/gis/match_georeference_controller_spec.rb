require 'rails_helper'

describe Tasks::Gis::MatchGeoreferenceController, type: :controller do
  let(:ce1) { CollectingEvent.new(verbatim_label:    'One of these',
                                  verbatim_locality: 'Hazelwood Rock') }

  context '/tasks/gis/match_georeference with prebuilt geo objects' do
    before(:all) {
      generate_ce_test_objects
    }

    before(:each) {
      sign_in
    }

    after(:all) {
      clean_slate_geo
    }
    context 'GET index' do
      it 'returns http success' do
        # pending 'proper specification of the route'
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    context 'GET drawn_collecting_events' do

      it 'finds collecting events inside a supplied circle' do
        get :drawn_collecting_events, {geographic_item_attributes_shape: '{"type":"Feature","geometry":{"type":"Point","coordinates":[5.0,-16.0]},"properties":{"radius":448000.0}}'}
        # pending 'fixing drawn_collecting_events for Circle'
        expect(assigns(:collecting_events).to_a).to contain_exactly(@ce_p5, @ce_p6, @ce_p7, @ce_p8, @ce_p9)
      end

      it 'finds collecting events inside a supplied polygon' do
        get :drawn_collecting_events, {geographic_item_attributes_shape: '{"type":"Feature","geometry":{"type":"Polygon","coordinates":[[[1.0,-11.0],[8.0,-11.0],[8.0,-18.0],[1.0,-18.0],[1.0,-11.0]]]},"properties":{}}'}
        # pending 'fixing drawn_collecting_events for polyon'
        expect(assigns(:collecting_events).to_a).to contain_exactly(@ce_p5, @ce_p6, @ce_p7, @ce_p8, @ce_p9)
      end
    end
  end

  context 'GET drawn_georeferences' do
      it 'finds georeferences inside a supplied polygon' do
        get :drawn_georeferences, {geographic_item_attributes_shape: '{"type":"Feature","geometry":{"type":"Polygon","coordinates":[[[1.0,-11.0],[8.0,-11.0],[8.0,-18.0],[1.0,-18.0],[1.0,-11.0]]]},"properties":{}}'}
        # pending 'construction of GeographicItem.are_contained_in_object'
        expect(assigns(:georeferences).to_a).to contain_exactly(@gr05, @gr06, @gr07, @gr08, @gr09)
      end

      it 'finds georeferences inside a supplied circle' do
        get :drawn_georeferences, {geographic_item_attributes_shape: '{"type":"Feature","geometry":{"type":"Point","coordinates":[5.0,-16.0]},"properties":{"radius":448000.0}}'}
        # pending 'construction of GeographicItem.within_radius_of_object'
        expect(assigns(:georeferences).to_a).to contain_exactly(@gr05, @gr06, @gr07, @gr08, @gr09)
      end
    end

    context 'GET filtered_georeferences' do
      context 'inclusion' do
        it 'finds one georeference through filtering collecing events labels' do
          get :filtered_georeferences, {any_label_text: 'ce_a'}
          expect(assigns(:georeferences).to_a).to contain_exactly(@gr_area_d)
        end

        it 'finds multiple georeferences through filtering collecing events labels' do
          get :filtered_georeferences, {any_label_text: 'ce_p2 collect_'}
          expect(assigns(:georeferences).to_a).to contain_exactly(@gr02, @gr121, @gr122)
        end
      end

      context 'exclusion' do
        it 'does no find any if none exist' do
          get :filtered_georeferences, {any_label_text: 'ZeroSum Game'}
          expect(assigns(:georeferences).to_a).to be_empty
        end
      end
    end

    context 'GET tagged_collecting_events and GET tagged_georeferences' do
      let(:cvt0) { FactoryGirl.create(:controlled_vocabulary_term, {type:       'Keyword',
                                                                    name:       'first collecting event',
                                                                    definition: 'tag for first ce'}) }
      let(:tag0) { Tag.new(keyword_id: cvt0.id) }
      let(:tag1) { Tag.new(keyword_id: cvt0.id) }
      let(:tag2) { Tag.new(keyword_id: cvt0.id) }
      before(:each) {
        sign_in
        # [tag0, tag1, tag2].map(&:save)
        @ce_p0.tags << tag0
        @gr00.tags << tag1
        @gr10.tags << tag2
        # [@ce_p0, @gr00, @gr10].map(&:save)
      }

      it 'finds a tagged collecting event' do
        get :tagged_collecting_events, {keyword_id: cvt0.id}
        # pending 'finding a tagged collecting event'
        expect(assigns(:collecting_events)).to contain_exactly(@ce_p0)
      end

      it 'finds a tagged georeference' do
        # pending 'finding a tagged georeference'
        get :tagged_georeferences, {keyword_id: cvt0.id}
        expect(assigns(:georeferences)).to contain_exactly(@gr00, @gr10)
      end
    end

  context 'GET filtered_collecting_events' do
    let(:ce1) { CollectingEvent.new(verbatim_label:    'One of these',
                                    start_date_month:  '1', # January
                                    start_date_year:   '2015',
                                    verbatim_locality: 'Hazelwood Rock') }
    let(:ce2) { CollectingEvent.new(verbatim_label:    'CE #2',
                                    start_date_day:    '15',
                                    start_date_month:  '12', # December
                                    start_date_year:   '2015',
                                    verbatim_locality: 'another place') }
    let(:ce3) { CollectingEvent.new(verbatim_label:    'CE #3',
                                    start_date_month:  '6', # June
                                    start_date_year:   '2002',
                                    verbatim_locality: 'yet somewhere else') }
    let(:ce4) { CollectingEvent.new(verbatim_label:    'Us in the second millennium',
                                    start_date_day:    '4',
                                    start_date_month:  '7', # July
                                    start_date_year:   '1776',
                                    end_date_day:      '31',
                                    end_date_month:    '12', # December
                                    end_date_year:     '2000',
                                    verbatim_locality: 'These United States') }
    before(:each) {
      sign_in
    }

    context 'checking date processing' do
      context 'inclusions' do

        it 'processes case 1y: start date' do
          [ce1, ce2, ce3, ce4].map(&:save)
          get :filtered_collecting_events, {start_date_year: '1776'}
          expect(assigns(:collecting_events)).to contain_exactly(ce4)
        end
      end

      it 'processes case 1m: start date' do
        [ce1, ce2, ce3, ce4].map(&:save)
        get :filtered_collecting_events, {start_date_month: '1'}
        expect(assigns(:collecting_events)).to contain_exactly(ce1)
      end

      it 'processes case 1my: start date' do
        [ce1, ce2, ce3, ce4].map(&:save)
        get :filtered_collecting_events, {start_date_month: '1',
                                          start_date_year:  '2015'}
        expect(assigns(:collecting_events)).to contain_exactly(ce1)
      end

      it 'processes case 1dmy: start date' do
        [ce1, ce2, ce3, ce4].map(&:save)
        get :filtered_collecting_events, {start_date_day:   '15',
                                          start_date_month: '12',
                                          start_date_year:  '2015'}
        expect(assigns(:collecting_events)).to contain_exactly(ce2)
      end

      it 'processes case 2yy: start date, end date' do
        [ce1, ce2, ce3, ce4].map(&:save)
        get :filtered_collecting_events, {start_date_year: '2001',
                                          end_date_year:   '2015'}
        expect(assigns(:collecting_events)).to contain_exactly(ce2, ce1, ce3)
      end

      it 'processes case 2mm: start date, end date' do
        [ce1, ce2, ce3, ce4].map(&:save)
        get :filtered_collecting_events, {start_date_month: '5',
                                          end_date_month:   '8'}
        expect(assigns(:collecting_events)).to contain_exactly(ce4, ce3)
      end

      it 'processes case 2mymy: start date, end date' do
        [ce1, ce2, ce3, ce4].map(&:save)
        get :filtered_collecting_events, {start_date_month: '5',
                                          start_date_year:  '2001',
                                          end_date_month:   '8',
                                          end_date_year:    '2015'}
        pending 'fixing \'my\' to \'my\''
        expect(assigns(:collecting_events)).to contain_exactly(ce2, ce1, ce3)
      end

      context 'exclusions' do

        it 'processes case 0: no dates' do
          [ce1, ce2, ce3, ce4].map(&:save)
          get :filtered_collecting_events, {}
          expect(assigns(:collecting_events)).to be_empty
        end

        it 'processes case 1my: start date' do
          [ce1, ce2, ce3, ce4].map(&:save)
          get :filtered_collecting_events, {start_date_month: '1',
                                            start_date_year:  '2001'}
          expect(assigns(:collecting_events)).to be_empty
        end

        it 'processes case 2: end only, no start' do
          [ce1, ce2, ce3, ce4].map(&:save)
          get :filtered_collecting_events, {end_date_day:   '15',
                                            end_date_month: '1',
                                            end_date_year:  '2015'}
          expect(assigns(:collecting_events)).to be_empty
        end

        it 'processes case 2mm: start date, end date' do
          [ce1, ce2, ce3, ce4].map(&:save)
          get :filtered_collecting_events, {start_date_month: '2',
                                            end_date_month:   '5'}
          expect(assigns(:collecting_events)).to be_empty
        end
      end
    end

    context 'checking text processing' do
      context 'inclusions' do

        it 'processes verbatim_locality' do
          [ce1, ce2, ce3, ce4].map(&:save)
          get :filtered_collecting_events, {verbatim_locality_text: 'wood'}
          expect(assigns(:collecting_events)).to contain_exactly(ce1)
        end

        it 'processes verbatim_label' do
          [ce1, ce2, ce3, ce4].map(&:save)
          get :filtered_collecting_events, {any_label_text: ' of '}
          expect(assigns(:collecting_events)).to contain_exactly(ce1)
        end

        it 'processes print_label' do
          [ce1, ce2, ce3, ce4].map(&:save)
          ce1.print_label    = ce1.verbatim_label
          ce1.verbatim_label = 'empty'
          ce1.save
          get :filtered_collecting_events, {any_label_text: ' of '}
          expect(assigns(:collecting_events)).to contain_exactly(ce1)
        end

        it 'processes document_label' do
          [ce1, ce2, ce3, ce4].map(&:save)
          ce1.document_label = ce1.verbatim_label
          ce1.verbatim_label = 'empty'
          ce1.save
          get :filtered_collecting_events, {any_label_text: ' of '}
          expect(assigns(:collecting_events)).to contain_exactly(ce1)
        end

        it 'processes label and locality' do
          [ce1, ce2, ce3, ce4].map(&:save)
          get :filtered_collecting_events, {any_label_text: ' of ', verbatim_locality_text: 'wood'}
          expect(assigns(:collecting_events)).to contain_exactly(ce1)
        end

        it 'processes identification fragment' do
          [ce1, ce2, ce3, ce4].map(&:save)
          get :filtered_collecting_events, {identifier_text: 'Something'}
          pending 'proper inclusion of identifier test'
          expect(assigns(:collecting_events)).to contain_exactly(ce1)
        end
      end
    end

    context 'exclusions' do

      it 'processes verbatim_locality' do
        [ce1, ce2, ce3, ce4].map(&:save)
        get :filtered_collecting_events, {verbatim_locality_text: 'PAIN'}
        expect(assigns(:collecting_events)).to be_empty
      end

      it 'processes verbatim_label' do
        [ce1, ce2, ce3, ce4].map(&:save)
        get :filtered_collecting_events, {any_label_text: ' PAIN '}
        expect(assigns(:collecting_events)).to be_empty
      end

      it 'processes print_label' do
        [ce1, ce2, ce3, ce4].map(&:save)
        ce1.print_label    = ce1.verbatim_label
        ce1.verbatim_label = 'empty'
        ce1.save
        get :filtered_collecting_events, {any_label_text: ' PAIN '}
        expect(assigns(:collecting_events)).to be_empty
      end

      it 'processes document_label' do
        [ce1, ce2, ce3, ce4].map(&:save)
        ce1.document_label = ce1.verbatim_label
        ce1.verbatim_label = 'empty'
        ce1.save
        get :filtered_collecting_events, {any_label_text: ' PAIN '}
        expect(assigns(:collecting_events)).to be_empty
      end

      it 'processes label and locality' do
        [ce1, ce2, ce3, ce4].map(&:save)
        ce1.save
        get :filtered_collecting_events, {any_label_text: ' PAIN ', verbatim_locality_text: 'PAIN'}
        expect(assigns(:collecting_events)).to be_empty
      end
    end
  end

end
