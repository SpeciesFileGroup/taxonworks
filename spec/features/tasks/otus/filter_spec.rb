require 'rails_helper'
require 'make_simple_world'

describe 'tasks/otus/filter', type: :feature, group: [:geo, :otus] do
  xcontext 'with properly built collection of objects' do
    let(:page_title) {'Otus by area'}
    let(:index_path) {otus_filter_task_path}

    it_behaves_like 'a_login_required_and_project_selected_controller'

    after(:all) {
      clean_slate_geo
      CollectionObject.destroy_all
      Namespace.destroy_all
    }

    context 'signed in as a user' do
      before(:each) {
        sign_in_user_and_select_project
      }

      context 'with some records created' do
        before {
          generate_political_areas_with_collecting_events(@user.id, @project.id)
        }

        # need some people
        let(:ted) {FactoryBot.create(:valid_person, last_name: 'Pomaroy', first_name: 'Ted', prefix: 'HEWIC')}
        let(:bill) {Person.find_or_create_by(first_name: 'Bill', last_name: 'Ardson')}

        #need an apex
        let(:top_dog) {o = FactoryBot.create(:valid_otu, name: 'Top Dog')
        o.taxon_name = FactoryBot.create(:valid_taxon_name,
                                         rank_class: Ranks.lookup(:iczn, 'Family'),
                                         name: 'Topdogidae')
        o
        }

        let(:abra) {Otu.where(name: 'Abra').first}
        let(:cadabra) {Otu.where(name: 'Abra cadabra').first}
        let(:alakazam) {Otu.where(name: 'Abra cadabra alakazam').first}
        # need some otus
        let!(:co_m1a_o) {
          o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'M1A')
          @co_m1a.otus << o
        }
        let!(:co_m1_o) {
          o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'M1')
          @co_m1.otus << o
        }
        let!(:co_n1_o) {
          o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'N1, No georeference')
          @co_n1.otus << o
        }
        let!(:co_o1_o) {
          o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'O1')
          @co_o1.otus << o
        }
        let!(:co_p1_o) {
          o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'P1')
          @co_p1.otus << o
        }
        let!(:co_m2_o) {
          o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'M2')
          o.taxon_name.update_column(:name, 'M2 antivitis')
          @co_m2.otus << o
          o = top_dog
          o.taxon_name.taxon_name_authors << ted
          @co_m2.otus << o
          o = FactoryBot.create(:valid_otu, name: 'Abra')
          o.taxon_name = Protonym.find_or_create_by(name: 'Abra',
                                                    rank_class: Ranks.lookup(:iczn, 'Genus'),
                                                    parent: top_dog.taxon_name)
          parent = o.taxon_name
          o.taxon_name.taxon_name_authors << ted
          @co_m2.otus << o
          o = FactoryBot.create(:valid_otu, name: 'Abra cadabra')
          o.taxon_name = Protonym.find_or_create_by(name: 'cadabra',
                                                    rank_class: Ranks.lookup(:iczn, 'Species'),
                                                    parent: parent)
          parent = o.taxon_name
          o.taxon_name.taxon_name_authors << ted
          @co_m2.otus << o
          o = FactoryBot.create(:valid_otu, name: 'Abra cadabra alakazam')
          @co_m2.collecting_event.collectors << bill
          o.taxon_name = Protonym.find_or_create_by(name: 'alakazam',
                                                    rank_class: Ranks.lookup(:iczn, 'Subspecies'),
                                                    parent: parent)
          o.taxon_name.taxon_name_authors << ted
          @co_m2.otus << o
          o.taxon_name}
        let!(:co_n2_a_o) {
          o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'N2A')
          @co_n2_a.otus << o
        }
        let!(:co_n2_b_o) {
          o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'N2B')
          @co_n2_b.otus << o
        }
        let!(:co_o2_o) {
          o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'O2')
          @co_o2.otus << o
        }
        let!(:co_p2_o) {
          o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'P2, No georeference')
          @co_p2.otus << o
        }
        let!(:co_m3_o) {
          o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'M3')
          @co_m3.otus << o
        }
        let!(:co_n3_o) {
          o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'N3')
          @co_n3.otus << o
        }
        let!(:co_o3_o) {
          o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'O3, No georeference')
          @co_o3.otus << o
        }
        let!(:co_p3_o) {
          o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'P3, No georeference')
          @co_p3.otus << o
        }
        let!(:co_m4_o) {
          o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'M4')
          @co_m4.otus << o
        }
        let!(:co_n4_o) {
          o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'N4')
          @co_n4.otus << o
        }
        let!(:co_o4_o) {
          o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'O4')
          @co_o4.otus << o
        }
        let!(:co_p4_o) {
          o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'P4')
          o.taxon_name.update_column(:name, 'P4 antivitis')
          @co_p4.otus << o
        }
        let!(:co_v_o) {
          o = FactoryBot.create(:valid_otu_with_taxon_name, name: 'I can\'t be found!')
          @co_v.otus << o
        }

        let!(:gnlm) {GeographicArea.where(name: 'Great Northern Land Mass').first}
        let!(:bbxa) {GeographicArea.where(name: 'Big Boxia').first}

        let!(:otum1) {Otu.where(name: 'Find me, I\'m in M1!').first}

        let(:json_string) {'{"type":"Feature", "geometry":{"type":"Polygon", "coordinates":[[[33, 28, 0], [37, 28, 0], [37, 26, 0], [33, 26, 0], [33, 28, 0]]]}}'}

        describe '#set_area', js: true do #
          it 'renders count of otus in a specific names area' do
            visit(index_path)
            page.execute_script "$('#set_area')[0].scrollIntoView()"
            fill_area_picker_autocomplete('area_picker_autocomplete', with: 'big', select: bbxa.id)
            click_button('Set area')
            expect(find('#area_count')).to have_text('13')
            # fill_otu_widget_autocomplete('#nomen_id_for_by_nomen', with: "P4", select: @co_p4.Taxon_names.first.id)
          end

          it 'renders count of otus in a drawn area' do
            visit(index_path)
            find('#label_toggle_slide_area').click
            execute_script("document.getElementById('drawn_area_shape').type = 'text'")
            this_xpath = find(:xpath, "//input[@id='drawn_area_shape']")
            this_xpath.set json_string
            click_button('Set area')
            expect(find('#area_count')).to have_text('13')
          end
        end

        describe '#set_nomen', js: true do
          it 'renders count of otus from a specific name without descendants' do
            visit(index_path)
            page.execute_script "$('#set_nomen')[0].scrollIntoView()"
            # finder = find('#nomen_id_for_by_nomen')
            # finder.send_keys('p4')
            # wait_for_ajax
            # finder.send_keys(:down)
            # finder.send_keys(:tab)
            fill_autocomplete('nomen_id_for_by_nomen', with: 'p4', select: @co_p4.taxon_names.last.id)
            click_button('Set Nomenclature')
            expect(find('#nomen_count')).to have_text('1')
          end

          it 'renders count of otus from a specific name with descendants' do
            visit(index_path)
            page.execute_script "$('#set_nomen')[0].scrollIntoView()"
            find('#descendant_toggle').click
            # finder = find('#nomen_id_for_by_nomen')
            # finder.send_keys('Topdog')
            # wait_for_ajax
            # finder.send_keys(:down)
            # finder.send_keys(:tab)
            fill_autocomplete('nomen_id_for_by_nomen', with: 'Topdog', select: top_dog.taxon_name.id)
            click_button('Set Nomenclature')
            expect(find('#nomen_count')).to have_text('4')
          end
        end

        describe '#find', js: true do
          before {
            visit(index_path)
            execute_script("document.getElementById('drawn_area_shape').type = 'text'")
            # find('#area_picker_autocomplete').set('Great')
            fill_area_picker_autocomplete('area_picker_autocomplete', with: 'Great Northern', select: gnlm.id)
            click_button('Set area')
            wait_for_ajax

            page.execute_script "$('#set_nomen')[0].scrollIntoView()"
            # finder = find('#nomen_id_for_by_nomen')
            # finder.send_keys('p4')
            # wait_for_ajax
            # finder.send_keys(:down)
            # finder.send_keys(:tab)
            fill_autocomplete('nomen_id_for_by_nomen', with: 'p4', select: @co_p4.taxon_names.first.id)
            click_button('Set Nomenclature')

            find('#find_area_and_nomen_commit').click
            wait_for_ajax
          }

          it 'renders count of objects and table found using a drawn area and date range' do
            find('#paging_data', visible: true, text: 'Displaying 1 otu')
            expect(find(:xpath, "//div['show_list']/table[@class='tablesorter']/thead")).to have_text('Taxon name')
          end
        end

        describe '#find none', js: true do
          before {
            visit(index_path)
            execute_script("document.getElementById('drawn_area_shape').type = 'text'")
            # find('#area_picker_autocomplete').set('Great')
            fill_area_picker_autocomplete('area_picker_autocomplete', with: 'big', select: bbxa.id)
            click_button('Set area')
            wait_for_ajax

            page.execute_script "$('#set_nomen')[0].scrollIntoView()"
            # finder = find('#nomen_id_for_by_nomen')
            # finder.send_keys('p4')
            # wait_for_ajax
            # finder.send_keys(:down)
            # finder.send_keys(:tab)
            fill_autocomplete('nomen_id_for_by_nomen', with: 'p4', select: @co_p4.taxon_names.first.id)
            click_button('Set Nomenclature')

            find('#find_area_and_nomen_commit').click
            wait_for_ajax
          }

          it 'renders count of objects and table found using a drawn area and date range' do
            find('#paging_data', visible: true, text: 'Displaying no otus')
            expect(find(:xpath, "//div['show_list']/table[@class='tablesorter']/thead")).to have_text('Taxon name')
          end
        end
      end
    end
  end

  context 'using simple_world' do
    let(:page_title) {'Otus by area'}
    let(:index_path) {otus_filter_task_path}

    it_behaves_like 'a_login_required_and_project_selected_controller'

    context 'signed in as a user' do
      before {
        sign_in_user_and_select_project
        simple_world(@user.id, @project.id)
      }

      # need some people
      let(:sargon) {Person.find_or_create_by(first_name: 'of Akkad', last_name: 'Sargon')}
      let(:andy) {Person.find_or_create_by(first_name: 'Andy', last_name: 'Worehall', prefix: 'Non-author')}
      let(:daryl) {Person.find_or_create_by(first_name: 'Daryl', last_name: 'Penfold', prefix: 'with Sargon')}
      let(:ted) {Person.find_or_create_by(last_name: 'Pomaroy', first_name: 'Ted', prefix: 'HEWIC')}
      let(:bill) {Person.find_or_create_by(first_name: 'Bill', last_name: 'Ardson')}

      # need some otus
      let(:top_dog) {Otu.where(name: 'Top Dog').first}
      let(:nuther_dog) {Otu.where(name: 'Another Dog').first}
      let(:spooler) {Otu.where('name like ?', '%spooler%').first}
      let(:p4) {Otu.where(name: 'P4').first}
      let(:by_bill) {Otu.where('name like ?', '%by Bill%').first}
      let(:otu_a) {Otu.where(name: 'Otu_A').first}
      let(:abra) {Otu.where(name: 'Abra').first}
      let(:cadabra) {Otu.where('name like ?', '%cadabra%').first}
      let(:alakazam) {Otu.where('name like ?', '%alakazam%').first}

      # need some areas
      let(:area_a) {GeographicArea.where(name: 'A').first}
      let(:area_b) {GeographicArea.where(name: 'B').first}
      let(:area_e) {GeographicArea.where(name: 'E').first}

      # need some collection objects
      let(:co_a) {
        object = CollectingEvent.where(verbatim_label: 'Eh?').first
        object.collection_objects.first
      }

      describe '#set_area', js: true do #
        it 'renders count of otus in a specific names area' do
          visit(index_path)
          page.execute_script "$('#set_area')[0].scrollIntoView()"
          fill_area_picker_autocomplete('area_picker_autocomplete', with: 'A', select: area_a.id)
          click_button('Set area')
          expect(find('#area_count')).to have_text('6')
        end

        it 'renders count of otus in a specific names area' do
          visit(index_path)
          page.execute_script "$('#set_area')[0].scrollIntoView()"
          fill_area_picker_autocomplete('area_picker_autocomplete', with: 'B', select: area_b.id)
          click_button('Set area')
          expect(find('#area_count')).to have_text('3')
        end

        it 'renders count of otus in a specific names area' do
          visit(index_path)
          page.execute_script "$('#set_area')[0].scrollIntoView()"
          fill_area_picker_autocomplete('area_picker_autocomplete', with: 'E', select: area_e.id)
          click_button('Set area')
          expect(find('#area_count')).to have_text('9')
        end

        it 'renders count of otus in a drawn area' do
          visit(index_path)
          find('#label_toggle_slide_area').click
          execute_script("document.getElementById('drawn_area_shape').type = 'text'")
          this_xpath = find(:xpath, "//input[@id='drawn_area_shape']")
          this_xpath.set area_e.to_simple_json_feature
          click_button('Set area')
          expect(find('#area_count')).to have_text('13')
        end
      end
    end
  end
end

