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

        let!(:co_m1a_o) { FactoryGirl.create(:valid_otu_with_taxon_name, name: 'M1A') }
        let!(:co_n1_o) { FactoryGirl.create(:valid_otu_with_taxon_name, name: 'N1, No georeference') }
        let!(:co_o1_o) { FactoryGirl.create(:valid_otu_with_taxon_name, name: 'O1') }
        let!(:co_p1_o) { FactoryGirl.create(:valid_otu_with_taxon_name, name: 'P1') }
        let!(:co_m2_o) { FactoryGirl.create(:valid_otu_with_taxon_name, name: 'M2') }
        let!(:co_n2_a_o) { FactoryGirl.create(:valid_otu_with_taxon_name, name: 'N2A') }
        let!(:co_n2_b_o) { FactoryGirl.create(:valid_otu_with_taxon_name, name: 'N2B') }
        let!(:co_o2_o) { FactoryGirl.create(:valid_otu_with_taxon_name, name: 'O2') }
        let!(:co_p2_o) { FactoryGirl.create(:valid_otu_with_taxon_name, name: 'P2, No georeference') }
        let!(:co_m3_o) { FactoryGirl.create(:valid_otu_with_taxon_name, name: 'M3') }
        let!(:co_n3_o) { FactoryGirl.create(:valid_otu_with_taxon_name, name: 'N3') }
        let!(:co_o3_o) { FactoryGirl.create(:valid_otu_with_taxon_name, name: 'O3, No georeference') }
        let!(:co_p3_o) { FactoryGirl.create(:valid_otu_with_taxon_name, name: 'P3, No georeference') }
        let!(:co_m4_o) { FactoryGirl.create(:valid_otu_with_taxon_name, name: 'M4') }
        let!(:co_n4_o) { FactoryGirl.create(:valid_otu_with_taxon_name, name: 'N4') }
        let!(:co_o4_o) { FactoryGirl.create(:valid_otu_with_taxon_name, name: 'O4') }
        let!(:co_p4_o) { FactoryGirl.create(:valid_otu_with_taxon_name, name: 'P4') }
        let!(:co_v_o) { FactoryGirl.create(:valid_otu_with_taxon_name, name: 'I can\'t be found!') }

        let!(:gnlm) { GeographicArea.where(name: 'Great Northern Land Mass').first }

        let!(:otum1) { Otu.where(name: 'Find me').first }

        let(:json_string) { '{"type":"Feature", "geometry":{"type":"Polygon", "coordinates":[[[33, 28, 0], [37, 28, 0], [37, 26, 0], [33, 26, 0], [33, 28, 0]]]}}' }

        describe '#set_area', js: true do #
          it 'renders count of otus in a specific names area' do
            visit(index_path)
            page.execute_script "$('#set_area')[0].scrollIntoView()"
            fill_area_picker_autocomplete('area_picker_autocomplete', with: 'Great Northern', select: gnlm.id)
            click_button('Set area')
            expect(find('#area_count')).to have_text('14')
          end

          it 'renders count of otus in a drawn area' do
            visit(index_path)
            find('#label_toggle_slide_area').click
            execute_script("document.getElementById('drawn_area_shape').type = 'text'")
            this_xpath = find(:xpath, "//input[@id='drawn_area_shape']")
            this_xpath.set json_string
            click_button('Set area')
            expect(find('#area_count')).to have_text('10')
          end
        end

        describe '#find', js: true do
          before {
            visit(index_path)
            # find('#area_picker_autocomplete').set('Great')
            fill_area_picker_autocomplete('area_picker_autocomplete', with: 'Great Northern', select: gnlm.id)
            click_button('Set area')
            wait_for_ajax
            find('#find_area_and_nomen_commit').click
            wait_for_ajax
          }

          it 'renders count of objects and table found using a drawn area and date range' do
            find('#area_count', visible: true, text: '14')
            expect(find(:xpath, "//div['show_list']/table[@class='tablesorter']/thead")).to have_text('Catalog Number')
          end
        end
      end
    end
  end
end

