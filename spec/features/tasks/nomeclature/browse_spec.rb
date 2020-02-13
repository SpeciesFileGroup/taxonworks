require 'rails_helper'

describe 'Browse nomenclature task', type: :feature, group: :nomenclature do
  context 'when signed in and a project is selected' do

    before { sign_in_user_and_select_project}

    context 'when I visit the task page', js: true do
      let!(:root) { @project.send(:create_root_taxon_name) } 
      let!(:genus) { Protonym.create!(by: @user, project: @project, parent: root, name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus)) }

      before { visit browse_nomenclature_task_path(taxon_name_id: genus.id) }

      specify "#{OS.mac? ? 'ctrl': 'alt'}-t navigates to New taxon name task" do
        expect(page).to have_text('Browse nomenclature')
        find('body').send_keys([OS.mac? ? :control : :alt, 't'])
        expect(page).to have_text('Edit taxon name')
      end

      specify 'edit icon navigates to New taxon name task' do
        page.find('a.edit-taxon-name').click
        expect(page).to have_text('Edit taxon name')
      end
    end
  end
end
