require 'rails_helper'

describe 'New source task', type: :feature, group: :sources do

  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project}

    # all vue.js, so js: true
    context 'when I visit the task page', js: true do
      before { visit new_source_task_path}

      specify 'defaults to BibTeX', js: true do
        expect(page.find('label', exact_text:  'Title')).to be_truthy
      end

      # specify 'new bibtex source from citation' do
      #   click_button 'CrossRef'
      #   # expect(page).to match 'verbatim citation'
      #   # expect(page).to have_button('Create verbatim source')

      #   #  VCR.use_cassette('CrossRefFromCitation') do
      #   #    fill_in 'citation', with: 'Brauer, A. (1909) Die Süsswasserfauna Deutschlands. Eine Exkursionsfauna bearb. ... und hrsg. von Dr. Brauer. Smithsonian Institution.'
      #   #    click_button 'Preview'
      #   #  end
      #   #  expect(page).to have_button('Create verbatim source')
      #   #  expect(page).to have_button('Create BibTeX source')
      #   #  click_button 'Create BibTeX source'
      #   #  expect(page).to have_text('Sources')
      #   #  expect(page).to have_text('Attributes')
      # end

      # specify 'new verbatim source from citation' do
      #   VCR.use_cassette('CrossRefFromCitation') do
      #     fill_in 'citation', with: 'Brauer, A. (1909) Die Süsswasserfauna Deutschlands. Eine Exkursionsfauna bearb. ... und hrsg. von Dr. Brauer. Smithsonian Institution.'
      #     click_button 'Preview'
      #   end
      #   expect(page).to have_button('Create verbatim source')
      #   expect(page).to have_button('Create BibTeX source')
      #   click_button 'Create verbatim source'
      #   expect(page).to have_text('Sources')
      #   expect(page).to have_text('Attributes')
      # end

      # specify 'new source from unresolvable citation' do

      #   VCR.use_cassette('CrossRefFromCitation2') do
      #     fill_in 'citation', with: '111111' # they learn, and match! 'Eades & Deem. 2008. Case 3429. CHARILAIDAE Dirsh, 1953 (Insecta, Orthoptera)'
      #     click_button 'Preview'
      #   end

      #   expect(page).to have_button('Create verbatim source')
      #   expect(page.has_button?('Create BibTeX source')).to be_falsey

      #   expect(page).to have_content('CrossRef did not find a match.')

      #   click_button 'Create verbatim source'

      #   expect(page).to have_text('Sources')
      #   expect(page).to have_text('Attributes')
      # end
    end
  end
end
