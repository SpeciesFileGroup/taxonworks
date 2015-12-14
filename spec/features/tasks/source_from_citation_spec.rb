require 'rails_helper'
include FormHelper

describe 'Source from Citation', type: :feature, group: :sources do

  context 'when signed in and a project is selected' do
    before {
      sign_in_user_and_select_project # logged in and project selected
    }

    specify 'should have a favorite this page link' do
      visit new_verbatim_reference_task_path # when I visit the new_verbatim_reference_task_path
      expect(page).to have_link('Favorite page')
      click_link('Favorite page')
      expect(page).to have_content('Added page to favorites.')
    end

    specify 'new bibtex source from citation' do
      visit new_verbatim_reference_task_path # when I visit the new_verbatim_reference_task_path
      expect(page.has_field?('citation', :type => 'textarea')).to be_truthy
      fill_in 'citation', with: 'Brauer, A. (1909) Die Süsswasserfauna Deutschlands. Eine Exkursionsfauna bearb. ... und hrsg. von Dr. Brauer. Smithsonian Institution.'
      click_button 'preview' # click the 'preview'
      expect(page).to have_button('Create verbatim source')
      expect(page).to have_button('Create BibTeX source')
      click_button 'Create BibTeX source'
      expect(page).to have_content('This Source::Bibtex record was created.')
      expect(page).to have_content('Editing source')
      expect(find_field("source_type_sourcebibtex")).to be_checked
    end

    specify 'new verbatim source from citation' do
      visit new_verbatim_reference_task_path # when I visit the new_verbatim_reference_task_path
      expect(page.has_field?('citation', :type => 'textarea')).to be_truthy
      fill_in 'citation', with: 'Brauer, A. (1909) Die Süsswasserfauna Deutschlands. Eine Exkursionsfauna bearb. ... und hrsg. von Dr. Brauer. Smithsonian Institution.'
      click_button 'preview' # click the 'preview'
      expect(page).to have_button('Create verbatim source')
      expect(page).to have_button('Create BibTeX source')
      click_button 'Create verbatim source'
      expect(page).to have_content('This Source::Verbatim record was created.')
      expect(page).to have_content('Editing source')
      expect(find_field("source_type_sourceverbatim")).to be_checked
    end

    specify 'new source from unresolvable citation' do
      visit new_verbatim_reference_task_path # when I visit the new_verbatim_reference_task_path
      expect(page.has_field?('citation', :type => 'textarea')).to be_truthy
      fill_in 'citation', with: 'Eades & Deem. 2008. Case 3429. CHARILAIDAE Dirsh, 1953 (Insecta, Orthoptera)'
      click_button 'preview' # click the 'preview'
      expect(page).to have_button('Create verbatim source')
      expect(page.has_button?('Create BibTeX source')).to be_falsey
      #expect(page).to have_button('Create BibTeX source', visible: false)
      expect(page).to have_content('CrossRef did not find a matching ref')
      click_button 'Create verbatim source'
      expect(page).to have_content('This Source::Verbatim record was created.')
      expect(page).to have_content('Editing source')
      expect(find_field("source_type_sourceverbatim")).to be_checked
    end
    #TODO forgot to check that create people is working
  end
end
