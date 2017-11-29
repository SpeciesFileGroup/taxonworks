require 'rails_helper'

describe '/tasks/collecting_events/parse/stepwise/lat_long', type: :feature, group: [:collecting_events] do
  context 'with one collecting event presented' do
    let(:page_title) { 'Stepwise collecting event parser - Latitude/Longitude' }
    let(:index_path) { collecting_event_lat_long_task_path }

    it_behaves_like 'a_login_required_and_project_selected_controller'

    context 'signed in as a user' do
      before {
        sign_in_user_and_select_project
      }

      context 'with some records created' do
        let(:ce_find) {
          FactoryBot.create(:valid_collecting_event,
                             verbatim_label: 'Strange verbatim_label #1. Matched by DD7 [40.092067, -88.249519]',
                             verbatim_latitude:  nil,
                             verbatim_longitude: nil,
                             verbatim_elevation: nil,
                             creator:            @user,
                             updater:            @user,
                             project:            @project)
        }
        let(:ce_dont_find) {
          FactoryBot.create(:valid_collecting_event,
                             verbatim_label:     "Don't find me! n40º5'31.4412\" w88∫11′43.3″",
                             verbatim_latitude:  "n40º5'31.4412\"",
                             verbatim_longitude: 'w88∫11′43.3″',
                             verbatim_elevation: '735',
                             creator:            @user,
                             updater:            @user,
                             project:            @project)
        }
        let(:valid_session) { {} }

        specify 'that we can find a verbatim_label' do
          expect(CollectingEvent.count).to eq(0)
          ce_dont_find; ce_find
          expect(CollectingEvent.count).to eq(2)
          visit(index_path)
          expect(page).to have_content('Strange verbatim_label')
        end
      end
    end
  end
end
