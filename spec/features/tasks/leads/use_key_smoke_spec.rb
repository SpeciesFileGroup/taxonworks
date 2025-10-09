# frozen_string_literal: true

# Originally written by chatgpt.

require 'rails_helper'

# Smoke test for the "Use key" task (Tasks::Leads::Show).
# Builds a tiny key:
#   Root -> [Option 1, Option 2]
#   Option 1 -> [Option 1a, Option 1b]
# Then loads the Use key UI with ?lead_id=<root.id> and clicks once to
# advance from the root couplet into the next one.
#
# This helps catch regressions where edits in the New/Edit key task
# inadvertently break navigation in the Use key task.
describe 'Use key task', type: :feature, js: true do
  let(:show_task_path) { show_lead_task_path }

  before do
    sign_in_user_and_select_project

    otu_a = FactoryBot.create(:valid_otu, project: @project, creator: @user, updater: @user)
    otu_b = FactoryBot.create(:valid_otu, project: @project, creator: @user, updater: @user)

    # Root
    @root = FactoryBot.create(
      :valid_lead,
      text: 'Spec smoke key',
      project: @project, creator: @user, updater: @user
    )

    # First couplet under root
    @opt1 = FactoryBot.create(
      :valid_lead,
      text: 'Option 1',
      parent: @root,
      project: @project, creator: @user, updater: @user
    )
    @opt2 = FactoryBot.create(
      :valid_lead,
      text: 'Option 2',
      parent: @root,
      project: @project, creator: @user, updater: @user
    )

    # Second couplet under Option 1 (ensures a visible "Go" button for Option 1)
    FactoryBot.create(
      :valid_lead,
      text: 'Option 1a',
      parent: @opt1,
      project: @project, creator: @user, updater: @user,
      otu: otu_a
    )
    FactoryBot.create(
      :valid_lead,
      text: 'Option 1b',
      parent: @opt1,
      project: @project, creator: @user, updater: @user,
      otu: otu_b
    )
  end

  it 'loads the key and advances one couplet' do
    # Directly load the key in the Use key task (bypasses the KeyList screen)
    visit "#{show_task_path}?lead_id=#{@root.id}"

    # Header shows the key title (Header.vue)
    expect(page).to have_content('Spec smoke key')

    # The first couplet shows two option cards (Lead.vue cards inside Couplet.vue)
    within('.couplet') do
      expect(page).to have_css('.lead', text: 'Option 1')
      expect(page).to have_css('.lead', text: 'Option 2')

      # Click the "Go" button on the Option 1 card to advance one couplet
      within(find('.lead', text: 'Option 1')) do
        click_button('Go')
      end
    end

    # We should now be on the next couplet (children of Option 1)
    expect(page).to have_css('.couplet .lead', text: 'Option 1a')
    expect(page).to have_css('.couplet .lead', text: 'Option 1b')

    # "Up" button appears now that we're not at the root
    expect(page).to have_button('Up')
  end
end
