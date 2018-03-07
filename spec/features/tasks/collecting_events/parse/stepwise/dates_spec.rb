require 'rails_helper'

describe '/tasks/collecting_events/parse/stepwise/dates', type: :feature, group: [:collecting_events] do
  context 'with one collecting event presented' do
    let(:page_title) {'Stepwise collecting event parser - Dates'}
    let(:index_path) {dates_index_task_path}

    it_behaves_like 'a_login_required_and_project_selected_controller'

    context 'signed in as a user' do
      before {
        sign_in_user_and_select_project
      }

      context 'with some records created' do
        let(:ce_find) {# found because date is contained
          FactoryBot.create(:valid_collecting_event,
                             verbatim_label: 'Strange verbatim_label #1. Matched by DD7 [40.092067, -88.249519] 21 August, 1997',
                             verbatim_latitude: nil,
                             verbatim_longitude: nil,
                             verbatim_elevation: nil,
                             creator: @user,
                             updater: @user,
                             project: @project)
        }
        let(:ce_dont_find) {# not found because no date is contained
          FactoryBot.create(:valid_collecting_event,
                             verbatim_label: "Don't find me! n40º5'31.4412\" w88∫11′43.3″",
                             verbatim_latitude: "n40º5'31.4412\"",
                             verbatim_longitude: 'w88∫11′43.3″',
                             verbatim_elevation: '735',
                             creator: @user,
                             updater: @user,
                             project: @project)
        }
        let(:valid_session) {{}}

        specify 'that we can find a verbatim_label wth a date' do
          expect(CollectingEvent.count).to eq(0)
          ce_dont_find; ce_find
          expect(CollectingEvent.count).to eq(2)
          visit(index_path)
          expect(page).to have_content('21 August, 1997')
        end
      end
    end
  end
end
