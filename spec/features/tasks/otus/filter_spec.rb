require 'rails_helper'
require 'support/shared_contexts/shared_geo'

describe 'tasks/otus/filter', type: :feature, group: [:geo, :otus, :tn_authors, :shared_geo] do
  context 'using simple_world' do
    let(:page_title) { 'Otus by area' }
    let(:index_path) { filter_otus_task_path }

    it_behaves_like 'a_login_required_and_project_selected_controller'

    context 'signed in as a user' do
      before { sign_in_user_and_select_project }

      include_context 'stuff for complex geo tests'

      before { [co_a, co_b, gr_a, gr_b, ad2].each }

      describe '#set_area', js: true do #
        it 'renders count of otus in a specific names area A' do
          visit(index_path)
          fill_in('area_picker_autocomplete', with: 'A')
          find('.vue-autocomplete-list li', text: /A\W/).hover.click
          click_button('Set area')
          expect(page).to have_css('#area_count', text: '6')
        end

        it 'renders count of otus in a specific names area B' do
          visit(index_path)
          fill_in('area_picker_autocomplete', with: 'B')
          find('.vue-autocomplete-list li', text: /B\W/).hover.click
          click_button('Set area')
          expect(page).to have_css('#area_count', text: '4') # three by collection object,
          # and one by asserted distribution
        end

        it 'renders count of otus in a specific names area E' do
          visit(index_path)
          fill_in('area_picker_autocomplete', with: 'E')
          find('.vue-autocomplete-list li', text: /E\W/).hover.click
          click_button('Set area')
          expect(page).to have_css('#area_count', text: '9')
        end

        it 'renders count of otus in a drawn area corresponding to b' do
          visit(index_path)
          find('label', text: "map").click
          # TODO: Helper method to calculate x-y and perform interaction
          [[256, 128], [270, 128], [270, 143], [256, 143], [256, 128]]
            .inject(find('#drawable_map_canvas')) { |e, (x, y)| sleep 1; e.hover.click(x: x-256, y: y-128) }
          click_button('Set area')
          expect(page).to have_css('#area_count', text: '4')
        end

        it 'renders count of otus in a drawn area' do
          visit(index_path)
          find('label', text: "map").click
          # TODO: Helper method to calculate x-y and perform interaction
          [[256, 113], [270, 113], [270, 143], [256, 143], [256, 113]]
            .inject(find('#drawable_map_canvas')) { |e, (x, y)| sleep 1; e.hover.click(x: x-256, y: y-128) }
          click_button('Set area')
          expect(page).to have_css('#area_count', text: '9')
        end
      end

      describe '#set_nomen', js: true do
        it 'renders count of otus from a specific name without descendants' do
          visit(index_path)
          fill_autocomplete('taxon_name_id_for_by_nomen', with: 'bee',
                            select:                        co_b.taxon_names.where(name: 'beevitis').first.id)
          click_button('Set Nomenclature')
          expect(page).to have_css('#nomen_count', text: '1') # 'beevitis'
        end

        it 'renders count of otus from a taxon name of its own rank with descendants' do
          visit(index_path)
          find('#descendants').click
          fill_autocomplete('taxon_name_id_for_by_nomen', with: 'topdog', select: top_dog.taxon_name.id)
          find('#rank_class').select('family (ICZN)')
          click_button('Set Nomenclature')
          expect(page).to have_css('#nomen_count', text: '2') # Top Dog, Top dog by Bill
        end

        it 'renders count of otus from a specific name with descendants without rank specified' do
          visit(index_path)
          find('#descendants').click
          fill_autocomplete('taxon_name_id_for_by_nomen', with: 'Topdog', select: top_dog.taxon_name.id)
          click_button('Set Nomenclature')
          expect(page).to have_css('#nomen_count', text: '6')
          # Top Dog, Top dog by Bill, Abra, Abra cadabra, Abra cadabra alakazam, Sargon's spooler
        end

        it 'renders count of otus from a specific name with descendants with specific rank' do
          visit(index_path)
          find('#descendants').click
          fill_autocomplete('taxon_name_id_for_by_nomen', with: 'Topdog', select: top_dog.taxon_name.id)
          find('#rank_class').select('species (ICZN)')
          click_button('Set Nomenclature')
          expect(page).to have_css('#nomen_count', text: '2') # Abra cadabra, Sargon's spooler
        end
      end

      describe '#set_author', js: true do

        it 'selects a taxon name author list (and)' do
          visit(index_path)
          find('#and_or_select__and_').click
          fill_autocomplete_and_select('author_picker_autocomplete', with: 'Sa',
                                       select_id: sargon.id, object_type: 'author')
          fill_autocomplete_and_select('author_picker_autocomplete', with: 'Pe',
                                       select_id: daryl.id, object_type: 'author')
          click_button('Set Author')
          expect(page).to have_css('#author_count', text: '1') # Sargon's spooler
        end

        it 'selects a taxon name author list (or)' do
          visit(index_path)
          find('#and_or_select__or_').click
          fill_autocomplete_and_select('author_picker_autocomplete', with: 'Sa',
                                       select_id: sargon.id, object_type: 'author')
          fill_autocomplete_and_select('author_picker_autocomplete', with: 'Bi',
                                       select_id: bill.id, object_type: 'author')
          fill_autocomplete_and_select('author_picker_autocomplete', with: 'Te',
                                       select_id: ted.id, object_type: 'author')
          click_button('Set Author')
          expect(page).to have_css('#author_count', text: '7') # Sargon's spooler
        end
      end

      describe '#find', js: true do
        before {
          t_n_id = Protonym.where(name: 'beevitis').first.id
          visit(index_path)
          fill_in('area_picker_autocomplete', with: 'E')
          find('.vue-autocomplete-list li', text: /E\W/).hover.click
          click_button('Set area')

          fill_autocomplete('taxon_name_id_for_by_nomen', with: 'bee', select: t_n_id)
          click_button('Set Nomenclature')

          find('#find_area_and_nomen_commit').click
        }

        it 'renders count of objects and table found using a drawn area and date range' do
          find('#paging_data', visible: true, text: 'Displaying 1 otu')
          expect(page).to have_css('#show_list table.tablesorter thead', text: 'Taxon name')
          find('.filter-button').click()
          find('#find_area_and_nomen_commit').click
          find('#paging_data', visible: true, text: 'Displaying 1 otu')
          expect(page).to have_css('#show_list table.tablesorter thead', text: 'Taxon name')
        end
      end

      describe '#find none', js: true do
        before {
          t_n_id = Protonym.where(name: 'beevitis').first.id
          visit(index_path)
          fill_in('area_picker_autocomplete', with: 'A')
          find('.vue-autocomplete-list li', text: /A\W/).hover.click
          click_button('Set area')

          fill_autocomplete('taxon_name_id_for_by_nomen', with: 'bee', select: t_n_id)
          click_button('Set Nomenclature')

          find('#find_area_and_nomen_commit').click
        }

        it 'renders count of objects and table found using name' do
          find('#paging_data', visible: true, text: 'Displaying no otus')
          expect(page).to have_css('#show_list table.tablesorter thead', text: 'Taxon name')
        end
      end

    end
  end
end
