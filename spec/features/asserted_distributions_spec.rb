require 'rails_helper'
describe "AssertedDistributions", :type => :feature do

  it_behaves_like 'a_login_required_and_project_selected_controller' do
    let(:index_path) { asserted_distributions_path }
    let(:page_index_name) { 'Asserted Distributions' }
  end

  context 'signed in as user, with some records created' do
    before {
      sign_in_user_and_select_project
    }

    describe 'GET /asserted_distributions' do
      before {
        visit asserted_distributions_path }
      specify 'a index name is present' do
        expect(page).to have_content('Asserted Distributions')
      end
    end

    context 'signed in as user, with some people created' do
      let(:g) { factory_girl_create_for_user(:valid_geographic_area, @user)  }
      let(:s) { factory_girl_create_for_user(:valid_source_bibtex, @user) }
      before { 
        5.times { factory_girl_create_for_user_and_project(:valid_otu, @user, @project)  }
        5.times.each_with_index { |i| 
          FactoryGirl.create(:valid_asserted_distribution,
                             otu: Otu.all[i],
                             geographic_area: g,
                             source: s,
                             creator: @user,
                             updater: @user,
                             project: @project    )
        }
      }

      describe 'GET /asserted_distributions/list' do
        before  {
          visit list_asserted_distributions_path 
        }

        specify 'that it renders without error' do
          expect(page).to have_content 'Listing asserted distributions'
        end
      end

      describe 'GET /asserted_distributions/n' do
        before {
          visit asserted_distribution_path(AssertedDistribution.second)
        }

        specify 'there is a \'previous\' link' do
          expect(page).to have_link('Previous')
        end

        specify 'there is a \'next\' link' do
          expect(page).to have_link('Next')
        end

      end
    end
  end
end
