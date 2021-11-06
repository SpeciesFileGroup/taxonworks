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

      context 'inside the taxon name hierarchy list' do
        let!(:genus_synonym) { Protonym.create!(by: @user, project: @project, parent: root, name: 'Bus', rank_class: Ranks.lookup(:iczn, :genus)) }
        let!(:tnr1) { TaxonNameRelationship.create!({by: @user, project: @project, subject_taxon_name: genus_synonym, object_taxon_name: genus, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym'}) }

        before(:each) do
          @hierarchy = page.find_by_id('show_taxon_name_hierarchy')
        end

        specify 'should have a link to the root name' do
          expect(@hierarchy).to have_link('Root', href: browse_nomenclature_task_path(taxon_name_id: TaxonName.first.id))
        end

        specify 'displaying invalid should only show invalid names' do
          visit browse_nomenclature_task_path(taxon_name_id: root.id)
          @hierarchy.find('label[for=display_herarchy_invalid]').click
          expect(@hierarchy).to have_link('Bus', href: browse_nomenclature_task_path(taxon_name_id: genus_synonym.id))
          expect(@hierarchy).to_not have_link('Aus', href: browse_nomenclature_task_path(taxon_name_id: genus.id))
        end

        specify 'selecting the valid filter should not show invalid names' do
          visit browse_nomenclature_task_path(taxon_name_id: root.id)
          @hierarchy.find('label[for=display_herarchy_valid]').click
          expect(@hierarchy).to have_link('Aus')
          expect(@hierarchy).to_not have_link('Bus')
        end
      end
    end
  end
end
