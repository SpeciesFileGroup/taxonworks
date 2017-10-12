require 'rails_helper'

describe 'tasks/collection_objects/filter', type: :feature, group: [:geo, :collection_objects] do
  context 'with properly built collection of objects' do
    let(:page_title) { 'Collection objects by area and date' }
    let(:index_path) { collection_objects_filter_task_path }

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

      context 'triggering the by_otu facet' do
        describe '#set_otu', js: true, resolution: true do
          let(:otu_test) { Otu.create!(name: 'zzzzz', by: @user, project: @project) }
          let(:specimen) { Specimen.create!(by: @user, project: @project) }

          before do
            TaxonDetermination.create!(otu: otu_test, biological_collection_object: specimen, by: @user, project: @project)
            visit(collection_objects_filter_task_path)
          end

          it 'renders count of collection objects based on a selected otu' do
            fill_autocomplete('otu_id_for_by_otu', with: otu_test.name, select: otu_test.to_param)
            wait_for_ajax
            find('#set_otu').click
            wait_for_ajax
            expect(find('#otu_count')).to have_text('1', wait: 10)
          end
        end
      end

      context 'triggering the by_identifier facet' do
        describe '#set_identifier', js: true, resolution: true do

          before do
            2.times { FactoryGirl.create(:valid_namespace, creator: @user, updater: @user) }
            ns1 = Namespace.first
            ns2 = Namespace.second
            2.times { FactoryGirl.create(:valid_specimen, creator: @user, updater: @user, project: @project) }
            (1..10).each { |identifier|
              sp = FactoryGirl.create(:valid_specimen, creator: @user, updater: @user, project: @project)
              id = FactoryGirl.create(:identifier_local_catalog_number,
                                      updater:           @user,
                                      project:           @project,
                                      creator:           @user,
                                      identifier_object: sp,
                                      namespace:         ((identifier % 2) == 0 ? ns1 : ns2),
                                      identifier:        identifier)
            }
            visit(collection_objects_filter_task_path)
          end
          it 'renders the count of collection objects based on a selected range of identifiers' do
            expect(Specimen.count).to eq(12)
            expect(Identifier.count).to eq(10)
            expect(Namespace.count).to eq(2)
            expect(true).to be_truthy
          end
        end
      end

      context 'with some records created' do
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

      context 'with records specific to identifiers' do
        describe 'select a namespace' do
          it 'should find the correct namespace' do
            @ns1 = FactoryGirl.create(:valid_namespace, creator: @user, updater: @user)
            @ns2 = FactoryGirl.create(:valid_namespace, creator: @user, updater: @user, short_name: 'PSUC_FEM')
            visit(collection_objects_filter_task_path)

            expect(page).to have_button('Set Identifier Range')
            select('PSUC', from: 'id_namespace')
            # s = find(:select, 'id_namespace')
            # s.send_keys("P\t")
            expect(page).to have_text('PSUC_FEM')
          end
        end

        describe 'select start and stop identifiers', js: true do
          it 'should find the start and stop inputs' do
            @ns1 = FactoryGirl.create(:valid_namespace, creator: @user, updater: @user)
            @ns2 = FactoryGirl.create(:valid_namespace, creator: @user, updater: @user, short_name: 'PSUC_FEM')
            3.times { FactoryGirl.create(:valid_namespace, creator: @user, updater: @user) }
            @ns3 = Namespace.third
            2.times { FactoryGirl.create(:valid_specimen, creator: @user, updater: @user, project: @project) }
            FactoryGirl.create(:identifier_local_import,
                               identifier_object: Specimen.first,
                               namespace:         @ns3,
                               identifier:        'First specimen', creator: @user, updater: @user, project: @project)
            FactoryGirl.create(:identifier_local_import,
                               identifier_object: Specimen.second,
                               namespace:         @ns3,
                               identifier:        'Second specimen', creator: @user, updater: @user, project: @project)
            (1..10).each { |identifier|
              sp = FactoryGirl.create(:valid_specimen, creator: @user, updater: @user, project: @project)
              id = FactoryGirl.create(:identifier_local_catalog_number,
                                      identifier_object: sp,
                                      namespace:         ((identifier % 2) == 0 ? @ns1 : @ns2),
                                      identifier:        identifier, creator: @user, updater: @user, project: @project)
            }

            expect(Specimen.with_identifier('PSUC_FEM 1').count).to eq(1)
            expect(Specimen.with_namespaced_identifier('PSUC_FEM', 2).count).to eq(0)
            expect(Specimen.with_namespaced_identifier('PSUC_FEM', 3).count).to eq(1)
            visit(collection_objects_filter_task_path)

            page.execute_script "$('#set_id_range')[0].scrollIntoView()"

            fill_in('id_range_start', with: '1')
            fill_in('id_range_stop', with: '10')

            click_button('Set Identifier Range', {id: 'set_id_range'})
            wait_for_ajax
            expect(find('#id_range_count')).to have_content('10')

            fill_in('id_range_start', with: '3')
            fill_in('id_range_stop', with: '8')

            click_button('Set Identifier Range', {id: 'set_id_range'})
            wait_for_ajax
            expect(find('#id_range_count')).to have_content('6')

            fill_in('id_range_start', with: '8')
            fill_in('id_range_stop', with: '3')

            click_button('Set Identifier Range', {id: 'set_id_range'})
            wait_for_ajax
            expect(find('#id_range_count')).to have_content('0')

            select('PS', from: 'id_namespace')
            fill_in('id_range_start', with: '3')
            fill_in('id_range_stop', with: '9')

            click_button('Set Identifier Range', {id: 'set_id_range'})
            wait_for_ajax
            expect(find('#id_range_count')).to have_content('4')

            find('#find_area_and_date_commit').click
            wait_for_ajax
            expect(find('#paging_data')).to have_content('all 4')

          end
        end
      end

      context 'with records specific to users and dates' do
        let!(:pat) { User.find(1) }
        let!(:pat_admin) { User.where(name: 'Pat Project Administrator').first }
        let!(:joe) { FactoryGirl.create(:valid_user) }
        let!(:prepare) {
          if $user.blank?
            $user_id = pat.id
            @project.users << joe
          end
        }
        describe 'default user', js: true do
          it 'should present the current user' do
            prepare
            visit(collection_objects_filter_task_path)
            page.execute_script "$('#set_user_date_range')[0].scrollIntoView()"

            expect(page).to have_button('Set User/Date Range')
            expect(page).to have_text(@user.name)
          end
        end

        describe 'selected user', js: true do
          it 'should find specific user' do
            prepare
            visit(collection_objects_filter_task_path)
            page.execute_script "$('#set_user_date_range')[0].scrollIntoView()"

            select('Joe', from: 'user')
            expect(find_field('user').value).to eq(joe.name)
          end
        end

        describe 'selected objects', js: true do
          it 'should find specific objects' do
            2.times { FactoryGirl.create(:valid_specimen, creator: pat_admin, updater: pat_admin, project: @project) }
            (1..10).each { |specimen|
              sp = FactoryGirl.create(:valid_specimen,
                                      creator:    ((specimen % 2) == 0 ? joe : pat),
                                      created_at: "200#{specimen - 1}/01/#{specimen}",
                                      updated_at: "200#{specimen - 1}/07/#{specimen}",
                                      updater:    ((specimen % 2) == 0 ? pat : joe),
                                      project:    @project)
            }

            expect(Specimen.created_by_user(pat_admin).count).to eq(2)
            expect(Specimen.created_by_user(pat).count).to eq(5)
            expect(Specimen.created_by_user(joe).count).to eq(5)

            visit(collection_objects_filter_task_path)

            page.execute_script "$('#set_user_date_range')[0].scrollIntoView()"

            # default select is current user / all dates
            click_button('Set User/Date Range', {id: 'set_user_date_range'})
            wait_for_ajax
            expect(find('#user_date_range_count')).to have_content('5')

            select('Pat Pro', from: 'user')
            fill_in('user_date_range_start', with: Date.today)
            fill_in('user_date_range_end', with: Date.today)

            click_button('Set User/Date Range', {id: 'set_user_date_range'})
            wait_for_ajax
            expect(find('#user_date_range_count')).to have_content('2')

            fill_in('user_date_range_start', with: Date.yesterday)
            fill_in('user_date_range_end', with: Date.yesterday)

            click_button('Set User/Date Range', {id: 'set_user_date_range'})
            wait_for_ajax
            expect(find('#user_date_range_count')).to have_content('0')

          end
        end
      end
    end
  end
end

