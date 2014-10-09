require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the TaxonNamesHelper. For example:
#
# describe TaxonNamesHelper do
#   describe "string concat" do
#     it "concatenates two strings with spaces" do
#       expect(helper.concat_strings("this", "that")).to eq("this that")
#     end
#   end
# end
describe CollectingEventsHelper, :type => :helper do
  context 'a collecting event needs some helpers' do
    let(:collecting_event) {FactoryGirl.create(:valid_collecting_event) }

    specify '::collecting_event_tag' do
      expect(CollectingEventsHelper.collecting_event_tag(collecting_event)).to eq("Locality #{collecting_event.id} for testing...")
    end

    specify '#collecting_event_tag' do
      expect(collecting_event_tag(collecting_event)).to eq("Locality #{collecting_event.id} for testing...")
    end

    specify '#collecting_event_link' do
      expect(collecting_event_link(collecting_event)).to have_link("Locality #{collecting_event.id} for testing...")
    end

    specify "#collecting_event_search_form" do
      expect(collecting_events_search_form).to have_button('Show')
      expect(collecting_events_search_form).to have_field('collecting_event_id_for_quick_search_form')
    end

  end

end
