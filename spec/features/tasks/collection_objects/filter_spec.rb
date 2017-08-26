require 'rails_helper'

describe 'tasks/collection_objects/filter', type: :feature, group: [:geo, :collection_objects] do
  context 'with properly built collection of objects' do
    let(:page_title) { 'Collection objects by area and date' }
    let(:index_path) { collection_objects_filter_task_path }

    it_behaves_like 'a_login_required_and_project_selected_controller'

    after(:all) { clean_slate_geo }

    context 'signed in as a user' do
      before(:each) {
        sign_in_user_and_select_project
      }

      context 'signed in as user, with some records created' do
        before {
          generate_political_areas_with_collecting_events(@user.id, @project.id)
        }

        let!(:gnlm) { GeographicArea.where(name: 'Great Northern Land Mass').first }
        let!(:otum1) { Otu.where(name: 'Find me').first }
        let(:json_string) { '{"type":"Feature", "geometry":{"type":"Polygon", "coordinates":[[[33, 28, 0], [37, 28, 0], [37, 26, 0], [33, 26, 0], [33, 28, 0]]]}}' }

        describe '#set_area', js: true do #
          it 'renders count of collection objects in a specific names area' do
            visit(collection_objects_filter_task_path)
            fill_area_picker_autocomplete('area_picker_autocomplete', with: 'Great Northern', select: gnlm.id)
            click_button('Set area')
            expect(find('#area_count')).to have_text('16')
          end

          it 'renders count of collection objects in a drawn area' do
            visit(collection_objects_filter_task_path)
            find('#label_toggle_slide_area').click
            execute_script("document.getElementById('drawn_area_shape').type = 'text'")
            this_xpath = find(:xpath, "//input[@id='drawn_area_shape']")
            this_xpath.set json_string
            click_button('Set area')
            expect(find('#area_count')).to have_text('10')
          end
        end

        describe '#set_date', js: true do
          before { visit(collection_objects_filter_task_path) }
          it 'renders count of collection objects based on the start and end dates' do
            execute_script("document.getElementById('search_end_date').value = '1980/12/31'")
            find('#search_start_date').set('1971/01/01')
            find('#search_end_date').click
            expect(find('#date_count')).to have_content('10')
          end
        end

        describe '#set_otu', js: true do
          let(:otu_test) {  factory_girl_create_for_user_and_project(:valid_otu, @user, @project) }
          let(:specimen) {   factory_girl_create_for_user_and_project(:valid_specimen, @user, @project) }

          before {
            specimen.otus << otu_test
            force = otu_test.collection_objects.reload # force the reload?!
            visit(collection_objects_filter_task_path)
          }

          it 'renders count of collection objects based on a selected otu' do
            fill_autocomplete('otu_id_for_by_otu', with: otu_test.name, select: otu_test.id)
            find('#set_otu').click
            wait_for_ajax
            expect(find('#otu_count')).to have_text('1')
          end
        end

        describe '#find', js: true do
          before {
            visit(collection_objects_filter_task_path)
            execute_script("document.getElementById('search_start_date').value = '1971/01/01'")
            execute_script("document.getElementById('search_end_date').value = '1980/12/31'")
            #  find('#search_start_date').set '1971/01/01'
            #  find('#search_end_date').set '1980/12/31'
            find('#label_toggle_slide_area').click
            wait_for_ajax
            execute_script("document.getElementById('drawn_area_shape').type = 'text'")
            this_xpath = find(:xpath, "//input[@id='drawn_area_shape']")
            this_xpath.set json_string
            click_button('Set area')
            wait_for_ajax
            find('#find_area_and_date_commit').click
            # find('#result_span', visible: false, text: '10')
            find('#area_count', visible: true, text: '10')
          }

          it 'renders count of objects and table found using a drawn area and date range' do
            expect(find(:xpath, "//div['show_list']/table[@class='tablesorter']/thead")).to have_text('Catalog Number')
          end

        end
      end
    end
  end
end

