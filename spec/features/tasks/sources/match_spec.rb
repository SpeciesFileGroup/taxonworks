require 'rails_helper'

describe 'Match sources task', type: :feature, group: :sources do

  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project }

    context 'when I visit the task page' do
      before { visit match_sources_task_path }

      specify 'page loads without 404' do
        expect(page).to have_content('Match sources')
      end
    end

    context 'the match endpoint' do
      let!(:source) do
        Source::Bibtex.create!(
          bibtex_type: 'article', author: 'Smit, F.G.A.M.', year: 1953,
          title: 'New fleas from New Guinea', by: @user
        )
      end

      let(:result) { JSON.parse(page.body) }

      # The browser client sends this via ajaxCall; page.driver.post does not.
      before do
        visit match_sources_task_path
        token = page.find('meta[name="csrf-token"]', visible: false)[:content]

        page.driver.post(
          match_sources_path(format: :json),
          { rows: [{ authors: 'Smit, F.G.A.M.', year: '1953' }] },
          { 'HTTP_X_CSRF_TOKEN' => token }
        )
      end

      specify 'returns candidates per row' do
        expect(result.first['candidates'].map { |c| c['source']['id'] })
          .to include(source.id)
      end
    end
  end
end
