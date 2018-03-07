require 'rails_helper'

describe Tasks::CollectingEvents::Parse::Stepwise::LatLongController, type: :controller, group: [:collecting_events] do
  before(:each) { sign_in }

  let(:ce_find) {
    FactoryBot.create(:valid_collecting_event,
                       verbatim_label: 'Strange verbatim_label #1. Matched by DD7 [40.092067, -88.249519]',
                       verbatim_latitude:  nil,
                       verbatim_longitude: nil,
                       verbatim_elevation: nil)
  }
  let(:ce_dont_find) {
    FactoryBot.create(:valid_collecting_event,
                       verbatim_label:     'Don\'t find me!',
                       verbatim_latitude:  "n40º5'31.4412\"",
                       verbatim_longitude: 'w88∫11′43.3″',
                       verbatim_elevation: '735')
  }
  let(:valid_session) { {} }

  describe 'GET index' do
    it 'assigns one specific collecting event to @collecting_event' do
      ce_dont_find
      this_ce = ce_find # specific order to hide the one we want
      get(:index, params: {}, session: valid_session)
      expect(assigns(:collecting_event)).to eq(this_ce)
    end
  end
end
