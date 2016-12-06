require 'rails_helper'

describe 'Otus', type: :feature do
  let(:index_path) { otus_path }
  let(:page_index_name) { 'otus' }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user' do
    before { sign_in_user_and_select_project }

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

        it_behaves_like 'a_data_model_with_standard_list'
      end

      describe 'GET /otus/n' do
        before {
          visit otu_path(Otu.second)
        }

        it_behaves_like 'a_data_model_with_standard_show'
      end

      describe 'GET /api/v1/otus/by_name/{variants of name}' do
        before do
          @user.generate_api_access_token
          @user.save!
          @taxon_name_root = Protonym.find_or_create_by(name:          'Root',
                                                        rank_class:    'NomenclaturalRank',
                                                        created_by_id: @user.id,
                                                        updated_by_id: @user.id,
                                                        parent_id:     nil,
                                                        project_id:    @project.id)
          @taxon_name_root.save
          @taxon_name = Protonym.create(name:                'Adidae',
                                        type:                'Protonym',
                                        rank_class:          Ranks.lookup(:iczn, 'Family'),
                                        verbatim_author:     'SueMe',
                                        year_of_publication: 1884,
                                        # cached:              'Adidae',
                                        # cached_author_year:  '(SueMe, 1884)',
                                        created_by_id:       @user.id,
                                        updated_by_id:       @user.id,
                                        project_id:          @project.id,
                                        parent_id:           @taxon_name_root.id,
                                        also_create_otu:     true)

        end
        let(:otu) { Otu.fifth }
        let(:otu2) { @taxon_name.otus.first }

        it 'Returns a response including an array of ids for an otu name' do
          visit "/api/v1/otus/by_name/#{otu.name}?project_id=#{otu.project.id}&token=#{@user.api_access_token}"
          expect(JSON.parse(page.body)['result']['otu_ids']).to eq([otu.id])
        end

        it 'Returns a response including an arrry of ids for a related taxon_name' do
          visit "/api/v1/otus/by_name/#{otu2.taxon_name.cached}?project_id=#{otu2.project.id}&token=#{@user.api_access_token}"
          expect(JSON.parse(page.body)['result']['otu_ids']).to eq([otu2.id])
        end

        it 'Returns a response including an arrry of ids for a related taxon_name plus author/year' do
          text = otu2.taxon_name.cached + ' ' + otu2.taxon_name.cached_author_year
          text = URI.escape(text)
          visit "/api/v1/otus/by_name/#{text}?project_id=#{otu2.project.id}&token=#{@user.api_access_token}"
          expect(JSON.parse(page.body)['result']['otu_ids']).to eq([otu2.id])
        end
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
  end
end
