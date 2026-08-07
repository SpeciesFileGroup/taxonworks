require 'rails_helper'

describe 'Year in review task', type: :feature, group: :projects do
  let(:page_title) { 'Year in review' }
  let(:index_path) { year_in_review_task_path }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project }

    context 'visiting the task page' do
      before { visit index_path }

      specify 'page renders without error' do
        expect(page).to have_content('Year in review')
      end

      specify 'year selector is present' do
        expect(page).to have_select('year')
      end

      specify 'current year is selected by default' do
        expect(page).to have_select('year', selected: Time.current.year.to_s)
      end
    end

    context 'with some data in the project', js: true do
      before do
        FactoryBot.create(:valid_otu, project: @project, creator: @user, updater: @user)
        visit index_path
      end

      specify 'loading message appears initially' do
        expect(page).to have_content('Loading data for')
      end

      specify 'graphs container becomes visible after data loads' do
        # Wait for the fetch to complete and graphs to render
        expect(page).to have_css('#year-in-review-graphs', visible: true, wait: 30)
      end

      specify 'summary table is rendered with tablesorter class' do
        # Wait for the table to be rendered
        expect(page).to have_css('#summary-table-container table.tablesorter', wait: 30)
      end

      specify 'graph canvases are present' do
        # Wait for graphs container first
        expect(page).to have_css('#year-in-review-graphs', visible: true, wait: 30)
        expect(page).to have_css('canvas#graph1')
        expect(page).to have_css('canvas#graph2')
        expect(page).to have_css('canvas#graph3')
        expect(page).to have_css('canvas#graph4')
      end
    end
  end
end
