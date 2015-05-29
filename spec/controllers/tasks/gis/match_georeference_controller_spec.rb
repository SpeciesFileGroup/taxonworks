require 'rails_helper'

describe Tasks::Gis::MatchGeoreferenceController, type: :controller do
  let(:ce1) { CollectingEvent.new(verbatim_label:    'One of these',
                                  verbatim_locality: 'Hazelwood Rock') }

  context '/tasks/gis/match_georeference' do
    before(:all) {
      generate_ce_test_objects
    }

    before(:each) {
      sign_in
    }

    after(:all) {
      clean_slate_geo
    }
    describe "GET index" do
      it "returns http success" do
        # pending 'proper specification of the route'
        get :index
        expect(response).to have_http_status(:success)
      end
    end
    context 'GET drawn_georeferences' do
      it 'finds things inside a supplied polygon' do
        get :drawn_georeferences, {geographic_item_attributes_shape: '{"type":"Feature","geometry":{"type":"Polygon","coordinates":[[[1.0,-11.0],[8.0,-11.0],[8.0,-18.0],[1.0,-18.0],[1.0,-11.0]]]},"properties":{}}'}
        # pending 'construction of GeographicItem.are_contained_in_object'
        expect(assigns(:georeferences).to_a).to contain_exactly(@gr05, @gr06, @gr07, @gr08, @gr09)
      end
      it 'finds things inside a supplied circle' do
        get :drawn_georeferences, {geographic_item_attributes_shape: '{"type":"Feature","geometry":{"type":"Point","coordinates":[5.0,-16.0]},"properties":{"radius":448000.0}}'}
        # pending 'construction of GeographicItem.within_radius_of_object'
        expect(assigns(:georeferences).to_a).to contain_exactly(@gr05, @gr06, @gr07, @gr08, @gr09)
      end
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
