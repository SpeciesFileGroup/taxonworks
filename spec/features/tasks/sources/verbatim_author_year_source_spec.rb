require 'rails_helper'

describe 'Verbatim author year to source', type: :feature, group: :sources do

  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project }

    context 'when I visit the task page' do
      before { visit verbatim_author_year_source_task_path }

      specify 'page loads without error' do
        expect(page).to have_text('TaxonName verbatim author/year without citations')
      end

      context 'with taxon names having verbatim author and year', js: true do
        let!(:root) { FactoryBot.create(:root_taxon_name, user_project_attributes(@user, @project)) }

        let!(:taxon_name1) {
          FactoryBot.create(:protonym,
            parent: root,
            name: 'Smithidae',
            rank_class: Ranks.lookup(:iczn, 'family'),
            verbatim_author: 'Smith',
            year_of_publication: 2020,
            **user_project_attributes(@user, @project)
          )
        }
        let!(:taxon_name2) {
          FactoryBot.create(:protonym,
            parent: root,
            name: 'Smithini',
            rank_class: Ranks.lookup(:iczn, 'tribe'),
            verbatim_author: 'Smith',
            year_of_publication: 2020,
            **user_project_attributes(@user, @project)
          )
        }
        let!(:taxon_name3) {
          FactoryBot.create(:protonym,
            parent: root,
            name: 'Jonidae',
            rank_class: Ranks.lookup(:iczn, 'family'),
            verbatim_author: 'Jones',
            year_of_publication: 2019,
            **user_project_attributes(@user, @project)
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
          smith_row = find("tr[data-author='Smith'][data-year='2020']")
          jones_row = find("tr[data-author='Jones'][data-year='2019']")

          expect(smith_row).to have_css('td.count-cell', text: '2')
          expect(jones_row).to have_css('td.count-cell', text: '1')
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
