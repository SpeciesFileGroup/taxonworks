require 'rails_helper'

describe Tasks::CollectingEvents::Parse::Stepwise::LatLongHelper, type: :helper, group: [:collecting_events] do
  context 'what gets displayed for the current collecting event' do
    let(:no_next_text) { 'No collecting event available.' }
    let(:ce_find_label) { 'Strange verbatim_label #1. Matched by DD7 [40.092067, -88.249519]' }
    let(:ce_find) {
      FactoryBot.create(:valid_collecting_event,
                         verbatim_label: ce_find_label,
                         verbatim_latitude:  nil,
                         verbatim_longitude: nil,
                         verbatim_elevation: nil)
    }

    specify 'without any records to fix' do
      expect(helper.show_ce_vl(nil)).to eq('<pre class="large_type word_break">' + no_next_text + '</pre>')
    end

    specify 'with a record to show' do
      expect(helper.show_ce_vl(ce_find)).to eq('<pre class="large_type word_break">' + ce_find_label + '</pre>')
    end
  end
end
