require 'rails_helper'

describe 'Otus', type: :feature do
  let(:index_path) { otus_path }
  let(:page_title) { 'Otus' }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user' do
    before do 
     
      sign_in_user_and_select_project
      @user.generate_api_access_token
      @user.save!

    end 

    context 'with some records created' do
      before {
        10.times { factory_girl_create_for_user_and_project(:valid_otu, @user, @project) }
        FactoryGirl.create(:valid_otu, name: 'Find me', creator: @user, updater: @user, project: @project)
      }

      context 'GET /otus' do
        before {
          visit index_path
        }

        it_behaves_like 'a_data_model_with_standard_index'

        specify 'that it has an AJAX autocomplete box', js: true do
          select_text = 'Select a otu'
          expect(page).to have_button('Show')
          expect(page).to have_field(select_text) # TODO: inflect
          fill_in(select_text, :with => 'a')
        end
      end

      describe 'GET /otus/list' do
        before do
          visit list_otus_path
        end

        it_behaves_like 'a_data_model_with_standard_list_and_records_created'
      end

      describe 'GET /otus/n' do
        before {
          visit otu_path(Otu.second)
        }

        it_behaves_like 'a_data_model_with_standard_show'
      end

      describe 'GET /api/v1/otus/by_name/{variants of name}' do

        let(:taxon_name_root) {
          Protonym.find_or_create_by(name:          'Root',
                                     rank_class:    'NomenclaturalRank',
                                     created_by_id: @user.id,
                                     updated_by_id: @user.id,
                                     parent_id:     nil,
                                     project_id:    @project.id)
        }

        let(:taxon_name) {
          Protonym.create!(
            name: 'Adidae',
            type: 'Protonym',
            rank_class: Ranks.lookup(:iczn, 'Family'),
            verbatim_author: 'SueMe',
            year_of_publication: 1884,
            by: @user,
            project: @project,
            parent: taxon_name_root,
            also_create_otu: true
          )
        }

        let(:otu) { Otu.fifth }
        let(:otu2) { taxon_name.otus.first }

        it 'Returns a response including an array of ids for an otu name' do
          route = URI.escape("/api/v1/otus/by_name/#{otu.name}?project_id=#{otu.project.id}&token=#{@user.api_access_token}")
          visit route 
          expect(JSON.parse(page.body)['result']['otu_ids']).to eq([otu.id])
        end

        it 'Returns a response including an arrry of ids for a related taxon_name' do
          route = URI.escape("/api/v1/otus/by_name/#{otu2.taxon_name.cached}?project_id=#{otu2.project.id}&token=#{@user.api_access_token}")
          visit route
          expect(JSON.parse(page.body)['result']['otu_ids']).to eq([otu2.id])
        end

        it 'Returns a response including an arrry of ids for a related taxon_name plus author/year' do
          query = otu2.taxon_name.cached + ' ' + otu2.taxon_name.cached_author_year
          route = URI.escape(
            "/api/v1/otus/by_name/#{query}?project_id=#{otu2.project.id}&token=#{@user.api_access_token}"
          )
          visit route
          expect(JSON.parse(page.body)['result']['otu_ids']).to eq([otu2.id])
        end
      end

      context 'creating a new OTU' do
        specify 'I can exercise the new link feature' do
          visit otus_path
          click_link('New')
          fill_in 'Name', with: 'test'
          click_button 'Create Otu'
          expect(page).to have_content("Otu 'test' was successfully created.")
        end
      end

      context 'downloading OTU table', js: true do
        let!(:csv) { Download.generate_csv(Otu.where(project_id: @project.id)) }
        specify 'otus table can be donwloaded as-is' do
          sleep 5 
          visit otus_path
          click_link('Download')
          expect( Features::Downloads::download_content).to eq(csv)
        end
      end

    end
  end
end
