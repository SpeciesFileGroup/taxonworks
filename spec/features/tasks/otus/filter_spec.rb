require 'rails_helper'

describe 'tasks/otus/filter', type: :feature, group: [:geo, :otus] do
  context 'with properly built collection of objects' do
    let(:page_title) { 'Otus by area' }
    let(:index_path) { otus_filter_task_path }

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

        let!(:co_m1a_o) {
          o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'M1A')
          @co_m1a.otus << o
        }
        let!(:co_m1_o) {
          o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'M1')
          @co_m1.otus << o
        }
        let!(:co_n1_o) {
          o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'N1, No georeference')
          @co_n1.otus << o
        }
        let!(:co_o1_o) {
          o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'O1')
          @co_o1.otus << o
        }
        let!(:co_p1_o) {
          o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'P1')
          @co_p1.otus << o
        }
        let!(:co_m2_o) {
          o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'M2')
          @co_m2.otus << o
        }
        let!(:co_n2_a_o) {
          o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'N2A')
          @co_n2_a.otus << o
        }
        let!(:co_n2_b_o) {
          o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'N2B')
          @co_n2_b.otus << o
        }
        let!(:co_o2_o) {
          o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'O2')
          @co_o2.otus << o
        }
        let!(:co_p2_o) {
          o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'P2, No georeference')
          @co_p2.otus << o
        }
        let!(:co_m3_o) {
          o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'M3')
          @co_m3.otus << o
        }
        let!(:co_n3_o) {
          o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'N3')
          @co_n3.otus << o
        }
        let!(:co_o3_o) {
          o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'O3, No georeference')
          @co_o3.otus << o
        }
        let!(:co_p3_o) {
          o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'P3, No georeference')
          @co_p3.otus << o
        }
        let!(:co_m4_o) {
          o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'M4')
          @co_m4.otus << o
        }
        let!(:co_n4_o) {
          o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'N4')
          @co_n4.otus << o
        }
        let!(:co_o4_o) {
          o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'O4')
          @co_o4.otus << o
        }
        let!(:co_p4_o) {
          o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'P4')
          @co_p4.otus << o
        }
        let!(:co_v_o) {
          o = FactoryGirl.create(:valid_otu_with_taxon_name, name: 'I can\'t be found!')
          @co_v.otus << o
        }

        let!(:gnlm) { GeographicArea.where(name: 'Great Northern Land Mass').first }
        let!(:bbxa) { GeographicArea.where(name: 'Big Boxia').first }

        let!(:otum1) { Otu.where(name: 'Find me, I\'m in M1!').first }

        let(:json_string) { '{"type":"Feature", "geometry":{"type":"Polygon", "coordinates":[[[33, 28, 0], [37, 28, 0], [37, 26, 0], [33, 26, 0], [33, 28, 0]]]}}' }

        describe '#set_area', js: true do #
          it 'renders count of otus in a specific names area' do
            visit(index_path)
            page.execute_script "$('#set_area')[0].scrollIntoView()"
            fill_area_picker_autocomplete('area_picker_autocomplete', with: 'big', select: bbxa.id)
            click_button('Set area')
            expect(find('#area_count')).to have_text('9')
            # fill_otu_widget_autocomplete('#otu_id_for_by_otu', with: "P4", select: @co_p4.otus.first.id)
          end

          it 'renders count of otus in a drawn area' do
            visit(index_path)
            find('#label_toggle_slide_area').click
            execute_script("document.getElementById('drawn_area_shape').type = 'text'")
            this_xpath = find(:xpath, "//input[@id='drawn_area_shape']")
            this_xpath.set json_string
            click_button('Set area')
            expect(find('#area_count')).to have_text('9')
          end
        end

        describe '#set_otu', js: true do
          it 'renders count of otus from a specific name without descendants' do
            visit(index_path)
            page.execute_script "$('#set_otu')[0].scrollIntoView()"
            finder = find('#otu_id_for_by_otu')
            finder.send_keys('p4')
            wait_for_ajax
            finder.send_keys(:down)
            finder.send_keys(:tab)
            click_button('Set OTU')
            expect(find('#otu_count')).to have_text('1')
          end

          it 'renders count of otus from a specific name with descendants' do
            visit(index_path)
            page.execute_script "$('#set_otu')[0].scrollIntoView()"
            find('#descendant_toggle').click
            finder = find('#otu_id_for_by_otu')
            finder.send_keys('m1')
            wait_for_ajax
            finder.send_keys(:down)
            finder.send_keys(:tab)
            click_button('Set OTU')
            expect(find('#otu_count')).to have_text('1')
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

            page.execute_script "$('#set_otu')[0].scrollIntoView()"
            finder = find('#otu_id_for_by_otu')
            finder.send_keys('p4')
            wait_for_ajax
            finder.send_keys(:down)
            wait_for_ajax
            finder.send_keys(:tab)
            wait_for_ajax
            click_button('Set OTU')

            wait_for_ajax
            find('#find_area_and_nomen_commit').click
            wait_for_ajax
          }

          it 'renders count of objects and table found using a drawn area and date range' do
            find('#paging_data', visible: true, text: 'Displaying all 15 otus')
            expect(find(:xpath, "//div['show_list']/table[@class='tablesorter']/thead")).to have_text('Taxon name')
          end
        end
      end
    end
  end
end

