require 'rails_helper'

# Structural smoke test. It guards the layout rework of this task: the blocks
# asserted here are the ones being moved between columns and re-chromed, so they
# must survive the move.
describe 'Browse collecting events task', type: :feature, group: :collecting_events do
  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project }

    context 'when I visit the task page', js: true do
      let!(:collecting_event) {
        FactoryBot.create(:valid_collecting_event, by: @user, project: @project, verbatim_locality: 'Sisters of Mercy')
      }

      let!(:otu) { FactoryBot.create(:valid_otu, by: @user, project: @project, name: 'Testotu') }

      let!(:collection_object) {
        FactoryBot.create(:valid_specimen, by: @user, project: @project, collecting_event:)
      }

      before {
        FactoryBot.create(:taxon_determination, by: @user, project: @project, otu:, taxon_determination_object: collection_object)
        visit browse_collecting_events_task_path(collecting_event_id: collecting_event.id)
      }

      specify 'the page renders' do
        expect(page).to have_text('Browse collecting events')
      end

      specify 'the record being browsed is named' do
        expect(page).to have_text('Sisters of Mercy')
      end

      specify 'there are links to the previous and next collecting event' do
        expect(page).to have_link('Previous')
        expect(page).to have_link('Next')
      end

      # The label is uppercased with CSS, so match case-insensitively: Selenium
      # reports text as rendered.
      specify 'the summary reports the collection object count' do
        within('#summary-panel') do
          expect(page).to have_text(/collection objects/i)
          expect(page).to have_text('1')
        end
      end

      specify 'the OTUs of the collection objects are listed and linked' do
        expect(page).to have_link('Testotu', href: browse_otus_task_path(otu_id: otu.id))
      end
    end
  end
end
