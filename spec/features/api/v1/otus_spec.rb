require 'rails_helper'

describe 'API::v1::Otus', type: :feature do

  context 'signed in as a user' do
    before do 
      sign_in_user_and_select_project
      @user.generate_api_access_token
      @user.save!
    end 

    context 'with some records created' do
      before {
        3.times { factory_girl_create_for_user_and_project(:valid_otu, @user, @project) }
        FactoryGirl.create(:valid_otu, name: 'Find me', creator: @user, updater: @user, project: @project)
      }

   
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
            also_create_otu: false 
          )
        }

        let(:otu) { Otu.where(name: 'Find me').first }
        let(:otu2) { Otu.create!(name: 'Not me', taxon_name: taxon_name, by: @user, project: @project) }

        it 'Returns a response including an array of ids for an otu name' do
          route = URI.escape("/api/v1/otus/by_name/#{otu.name}?project_id=#{otu.project.id}&token=#{@user.api_access_token}")
          visit route 
          expect(JSON.parse(page.body)['result']['otu_ids']).to eq([otu.id])
        end

        it 'Returns a response including an array of ids for a related taxon_name' do
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

    end
  end
end
