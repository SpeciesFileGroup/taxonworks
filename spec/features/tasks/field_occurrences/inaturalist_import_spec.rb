require 'rails_helper'

describe 'Task - iNaturalist import', type: :feature, group: :field_occurrences do

  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project }

    context 'when I visit the task page' do
      before { visit inaturalist_import_task_path }

      specify 'page loads without error' do
        expect(page).to have_text('iNaturalist import')
      end

      specify 'shows the observation input form' do
        expect(page).to have_field('observation_ids')
      end

      specify 'shows the community taxon checkbox checked by default' do
        expect(page).to have_checked_field('use_community_taxon')
      end

      specify 'shows the OTU matching checkbox' do
        expect(page).to have_field('match_otu_by_name')
      end

      specify 'shows the import images checkbox' do
        expect(page).to have_field('import_images')
      end

      specify 'shows the import sounds checkbox' do
        expect(page).to have_field('import_sounds')
      end
    end
  end

end
