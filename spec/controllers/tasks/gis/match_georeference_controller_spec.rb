require 'rails_helper'

describe Tasks::Gis::MatchGeoreferenceController, type: :controller do
  let(:ce1) { CollectingEvent.new(verbatim_label:    'One of these',
                                  verbatim_locality: 'Hazelwood Rock') }

  context '/tasks/gis/match_georeferenc' do
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
  end

  context 'GET filtered_collecting_events' do
    let(:ce1) { CollectingEvent.new(verbatim_label:    'One of these',
                                    start_date_month:  '1',
                                    start_date_year:   '2015',
                                    verbatim_locality: 'Hazelwood Rock') }
    let(:ce2) { CollectingEvent.new(verbatim_label:    'CE #2',
                                    start_date_day:    '15',
                                    start_date_month:  '1',
                                    start_date_year:   '2015',
                                    verbatim_locality: 'another place') }
    let(:ce3) { CollectingEvent.new(verbatim_label:    'CE #3',
                                    start_date_month:  '1',
                                    start_date_year:   '2001',
                                    verbatim_locality: 'yet somewhere else') }
    before(:each) {
      sign_in
    }

    context 'checking date processing' do
      context 'inclusions' do

        it 'processes case 1y: start date' do
          [ce1, ce2, ce3].map(&:save)
          get :filtered_collecting_events, {start_date_year: '2001'}
          expect(assigns(:collecting_events)).to contain_exactly(ce3)
        end
      end

      it 'processes case 1my: start date' do
        [ce1, ce2, ce3].map(&:save)
        get :filtered_collecting_events, {start_date_month: '1',
                                          start_date_year: '2015'}
        expect(assigns(:collecting_events)).to contain_exactly(ce1, ce2)
      end

      it 'processes case 1dmy: start date' do
        [ce1, ce2, ce3].map(&:save)
        get :filtered_collecting_events, {start_date_day: '15',
                                          start_date_month: '1',
                                          start_date_year: '2015'}
        expect(assigns(:collecting_events)).to contain_exactly(ce2)
      end

      context 'exclusions' do

        it 'processes case 0: no dates' do
          ce1.save
          get :filtered_collecting_events, {}
          expect(assigns(:collecting_events)).to be_empty
        end

        it 'processes case 1m: start date' do
          ce1.save
          get :filtered_collecting_events, {start_date_month: 1}
          expect(assigns(:collecting_events)).to be_empty
        end

        it 'processes case 1my: start date' do
          ce1.save
          get :filtered_collecting_events, {start_date_month: '1', start_date_year: '2001'}
          expect(assigns(:collecting_events)).to be_empty

        end
      end

    end

    context 'checking text processing' do
      context 'inclusions' do

        it 'processes verbatim_locality' do
          ce1.save
          get :filtered_collecting_events, {verbatim_locality_text: 'wood'}
          expect(assigns(:collecting_events)).to contain_exactly(ce1)
        end

        it 'processes verbatim_label' do
          ce1.save
          get :filtered_collecting_events, {any_label_text: ' of '}
          expect(assigns(:collecting_events)).to contain_exactly(ce1)
        end

        it 'processes print_label' do
          ce1.print_label    = ce1.verbatim_label
          ce1.verbatim_label = 'empty'
          ce1.save
          get :filtered_collecting_events, {any_label_text: ' of '}
          expect(assigns(:collecting_events)).to contain_exactly(ce1)
        end

        it 'processes document_label' do
          ce1.document_label = ce1.verbatim_label
          ce1.verbatim_label = 'empty'
          ce1.save
          get :filtered_collecting_events, {any_label_text: ' of '}
          expect(assigns(:collecting_events)).to contain_exactly(ce1)
        end

        it 'processes label and locality' do
          ce1.save
          get :filtered_collecting_events, {any_label_text: ' of ', verbatim_locality_text: 'wood'}
          expect(assigns(:collecting_events)).to contain_exactly(ce1)
        end
      end
    end

    context 'exclusions' do

      it 'processes verbatim_locality' do
        ce1.save
        get :filtered_collecting_events, {verbatim_locality_text: 'PAIN'}
        expect(assigns(:collecting_events)).to be_empty
      end

      it 'processes verbatim_label' do
        ce1.save
        get :filtered_collecting_events, {any_label_text: ' PAIN '}
        expect(assigns(:collecting_events)).to be_empty
      end

      it 'processes print_label' do
        ce1.print_label    = ce1.verbatim_label
        ce1.verbatim_label = 'empty'
        ce1.save
        get :filtered_collecting_events, {any_label_text: ' PAIN '}
        expect(assigns(:collecting_events)).to be_empty
      end

      it 'processes document_label' do
        ce1.document_label = ce1.verbatim_label
        ce1.verbatim_label = 'empty'
        ce1.save
        get :filtered_collecting_events, {any_label_text: ' PAIN '}
        expect(assigns(:collecting_events)).to be_empty
      end

      it 'processes label and locality' do
        ce1.save
        get :filtered_collecting_events, {any_label_text: ' PAIN ', verbatim_locality_text: 'PAIN'}
        expect(assigns(:collecting_events)).to be_empty
      end
    end
  end
end
