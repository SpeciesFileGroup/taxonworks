require 'rails_helper'

describe 'TaxonNames', type: :feature do
  let(:page_title) { 'Taxon names' }
  let(:index_path) { taxon_names_path }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user' do
    before(:each) {
      sign_in_user_and_select_project
    }

    let(:root) { FactoryGirl.create(:root_taxon_name, user_project_attributes(@user, @project).merge(source: nil)) }

    context 'with some records created' do
      before(:each) {
        5.times {
          FactoryGirl.create(:iczn_family, user_project_attributes(@user, @project).merge(parent: root, source: nil))
        } 
      }

      context 'visiting taxon_names_path' do
        before(:each) { 
          visit taxon_names_path 
        }

        describe 'GET /taxon_names' do
          it_behaves_like 'a_data_model_with_standard_index'
        end

        specify 'creating a new TaxonName', js: true do
          click_link('New') 
          fill_in('Name', with: 'Fooidae') 
          select('family (ICZN)', from: 'taxon_name_rank_class')
          fill_autocomplete('parent_id_for_name', with: 'root', select: root.id)

          click_button('Create Taxon name')
          expect(page).to have_content("Taxon name 'Fooidae' was successfully created.")
        end

      end

      describe 'GET /taxon_names/list' do
        before { visit list_taxon_names_path } 
        it_behaves_like 'a_data_model_with_standard_list_and_records_created'
      end

      describe 'GET /taxon_names/n' do
        before { visit taxon_name_path(TaxonName.second) }
        it_behaves_like 'a_data_model_with_standard_show'
      end
    end


    context 'editing an original combination' do
      before {
        up_attrs = user_project_attributes(@user, @project)
        # create the parent genera :
        # With a species created (you'll need a genus 'Aus', family, root)
        # With a different genus ('Bus') created under the same family
        @root = FactoryGirl.create(:root_taxon_name, up_attrs) # user_project_attributes(@user, @project).merge(source: nil))

        @family  = Protonym.create!(up_attrs.merge(parent: @root, name:  'Rootidae', rank_class: Ranks.lookup(:iczn, 'family')))
        @genus_a = Protonym.create!(up_attrs.merge(parent: @family, name: 'Aus', rank_class: Ranks.lookup(:iczn, 'genus')))
        @genus_b = Protonym.create!(up_attrs.merge(parent: @family, name: 'Bus', rank_class: Ranks.lookup(:iczn, 'genus')))
        @species = Protonym.create!(up_attrs.merge(parent: @genus_a, name: 'specius', rank_class: Ranks.lookup(:iczn, 'species')))

        visit taxon_name_path(@species) # when I visit the taxon_names_path
      }

      specify 'the original combination is set based on parent relationships' do
        expect(page).to have_content('Cached html: Aus specius')
      end

      specify 'there is an edit combination link', js: true do
        find('#show_tasks_dropdown').hover
        expect(page).to have_link('Edit original combination')  # There is an 'Edit original combination link'
      end

      context 'when I click the edit combination link', js: true  do

        # click_link('Edit original combination') 
        # page.find_link('Edit original combination').click
        # above not working for an unknown reason (see
        # http://stackoverflow.com/questions/6693993/capybara-with-selenium-webdriver-click-link-does-not-work-when-link-text-has-lin )
        
        before do
          find('#show_tasks_dropdown').hover
          page.find_link('Edit original combination').click 
        end 

        specify 'there is header text' do
          expect(page).to have_content('Editing original combination for Aus specius')
        end

        context 'when I add an original genus' do
          before {  
            fill_autocomplete('subject_taxon_name_id_for_tn_rel_0', with: "Aus", select: @genus_a.id)       
            click_button('Save changes') 
          }

          specify 'I see a successful update message' do
            expect(page).to have_content('Successfully updated the original combination.') # success msg
          end  

          specify 'I see the updated cached original combination' do
            page.find_link('Development view').click 
            expect(page).to have_content('Cached original combination: Aus specius')
          end

          context 'when I change the original genus' do
            before {
              find('#show_tasks_dropdown').hover
              page.find_link('Edit original combination').click
              fill_autocomplete('subject_taxon_name_id_for_tn_rel_0', with: 'Bus', select: @genus_b.id)
              click_button('Save changes') 
            }

            specify 'I see a success message' do
              expect(page).to have_content('Successfully updated the original combination.') # success msg
            end

            specify 'I see the updated original combination' do
              page.find_link('Development view').click 
              expect(page).to have_content('Cached original combination: Bus specius')  # show page original genus is changed
            end
          end
        end
      end
    end
  end
end




