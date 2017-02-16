require 'rails_helper'

describe Tasks::CollectingEvents::Parse::Stepwise::LatLongHelper, type: :helper, group: [:collecting_events] do
  context 'what gets displayed for the current collecting event' do
    let(:no_next_text) { 'No collecting event available.' }
    let(:ce_find) {
      FactoryGirl.create(:valid_collecting_event,
                         verbatim_label:     'Strange verbatim_label #1 > 40.092067 -88.249519',
                         verbatim_latitude:  nil,
                         verbatim_longitude: nil,
                         verbatim_elevation: nil)
    }

    specify 'without any records to fix' do
      expect(helper.show_ce_vl(nil)).to eq(no_next_text)
    end

    specify 'with a record to show' do
      expect(helper.show_ce_vl(ce_find)).to eq('Strange verbatim_label #1 > 40.092067 -88.249519')
    end

  end
end
