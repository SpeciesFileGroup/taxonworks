require 'rails_helper'

describe 'Verbatim author year to source', type: :feature, group: :sources do

  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project }

    context 'when I visit the task page' do
      before { visit verbatim_author_year_source_task_path }

      specify 'page loads without error' do
        expect(page).to have_text('Verbatim author/year to Source')
      end

      context 'with taxon names having verbatim author and year' do
        let!(:taxon_name1) {
          FactoryBot.create(:valid_protonym,
            verbatim_author: 'Smith',
            year_of_publication: 2020,
            by: @user
          )
        }
        let!(:taxon_name2) {
          FactoryBot.create(:valid_protonym,
            verbatim_author: 'Smith',
            year_of_publication: 2020,
            by: @user
          )
        }
        let!(:taxon_name3) {
          FactoryBot.create(:valid_protonym,
            verbatim_author: 'Jones',
            year_of_publication: 2019,
            by: @user
          )
        }

        before { visit verbatim_author_year_source_task_path }

        specify 'displays unique author/year combinations' do
          expect(page).to have_text('Smith')
          expect(page).to have_text('2020')
          expect(page).to have_text('Jones')
          expect(page).to have_text('2019')
        end

        specify 'displays record counts' do
          expect(page).to have_text('2') # Smith 2020 has 2 records
          expect(page).to have_text('1') # Jones 2019 has 1 record
        end

        specify 'provides link to new source' do
          expect(page).to have_link('New Source')
        end

        specify 'provides link to filter taxon names' do
          expect(page).to have_link('Filter TaxonNames')
        end
      end
    end
  end
end
