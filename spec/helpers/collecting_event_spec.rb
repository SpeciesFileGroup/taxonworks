require 'rails_helper'

describe CollectingEventsHelper, :type => :helper do
  context 'a collecting event needs some helpers' do
    let(:verbatim_label) { "USA: IL: Champaign Co.\nUrbana ii.2.14 YPT\nYoder" }
    let(:collecting_event) {FactoryGirl.create(:valid_collecting_event, verbatim_label: verbatim_label ) }
  

    specify '.collecting_event_tag' do
      expect(helper.collecting_event_tag(collecting_event)).to eq(verbatim_label)
    end

    specify '#collecting_event_tag' do
      expect(helper.collecting_event_tag(collecting_event)).to eq(verbatim_label)
    end

    specify '#collecting_event_link' do
      expect(helper.collecting_event_link(collecting_event)).to have_link("Urbana ii") # matches anywhere in link
    end

    specify '#collecting_event_search_form' do
      expect(helper.collecting_events_search_form).to have_button('Show')
      expect(helper.collecting_events_search_form).to have_field('collecting_event_id_for_quick_search_form')
    end
  end
end
