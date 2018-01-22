require 'rails_helper'

describe 'AlternateValues', type: :feature, group: [:annotators] do
  let(:index_path) {alternate_values_path}
  let(:page_title) {'Alternate values'}

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user' do
    before {
      sign_in_user_and_select_project
    }

    context 'with some record created' do
      before {
        k = Keyword.create!(name: 'Dictionary', definition: 'Book with words, lots of words, more than 20.', by: @user, project: @project)

        ['D.', 'Dict.', 'Di.'].each do |n|
          AlternateValue::Abbreviation.create!(alternate_value_object:           k,
                                               value:                            n,
                                               alternate_value_object_attribute: :name,
                                               by:                               @user,
                                               project_id:                       @project.id)
        end
      }

      describe 'GET /alternate_values' do
        before {visit alternate_values_path}
        it_behaves_like 'a_data_model_with_annotations_index'
      end

      describe 'GET /alternate_values/list' do
        before {visit list_alternate_values_path}
        it_behaves_like 'a_data_model_with_standard_list_and_records_created'
      end

=begin
      context 'create an alternate value for a community object (Source::Bibtex)' do
        let(:src_bibtex) {factory_bot_create_for_user(:soft_valid_bibtex_source_article, @user)}
        #  with a Source::BibTeX created (containing at least title)

        specify 'created source has no alternate values' do
          expect(src_bibtex.alternate_valued?).to be_falsey
        end

        context 'when I show the record' do
          before {visit source_path(src_bibtex)}

          specify 'it is community annotatable' do
            expect(page).to have_link('Add alternate value')
          end

          context 'when I choose to annotate' do
            before {click_link('Add alternate value')}

            specify 'i should see a checkbox allowing the user to create it within the project' do
              expect(find_field('alternate_value_is_community_annotation').checked?).to be_falsey
            end

            context 'when I fill in and click submit' do
              before {
                select('title', from: 'alternate_value_alternate_value_object_attribute')
                fill_in('Value', with: 'Alternate Title')
                select('abbreviation', from: 'Type')
                find(:css, '#alternate_value_is_community_annotation').set(true)
                click_button('Create Alternate value')
              }

              specify 'the record was indeed annotated' do
                expect(src_bibtex.alternate_valued?).to be_truthy
              end

              specify 'and the project_id was not set' do
                alt_v = src_bibtex.alternate_values[0]
                expect(alt_v.project_id).to be_nil
              end

              specify 'then I see the success message' do
                expect(page).to have_content('Alternate value was successfully created.')
              end

              specify 'and I see the data presented' do
                expect(page).to have_content(/Annotations/)
                expect(page).to have_content(/Alternate values/)
                expect(page).to have_content('"Alternate Title" abbreviation of title "I am a soft valid article"')
              end
            end

            #TODO check visible by different user
          end
        end
      end
=end

      # pending 'create an alternate value for a project object (controlled vocabulary)' do
      #   k2 = Keyword.create!(name: 'testkey', definition: 'testing keyword', by: @user, project: @project)
      #   #  when I show that record
      #   visit controlled_vocabulary_term_path(:id => k2.id)
      #
      #   # then there is a link "Add alternate value"
      #   expect(page).to have_link('Add alternate value')
      #   expect(page.has_content?('Annotations')).to be_falsey
      #   expect(page.has_content?('Alternate values')).to be_falsey
      #
      #   # when I click that link
      #   click_link('Add alternate value')
      #
      #   # I should NOT see a checkbox allowing the user to create it within the project
      #   # expect(find_field('project_members_only').visible?).to be_falsey
      #
      #   # and I select "name" from Alternate value object attribute
      #   select('name', from: 'alternate_value_alternate_value_object_attribute')
      #
      #   # spec/features/alternate_values_spec.rb
      #   fill_in('Value', with: 'KeyTest')
      #
      #   # and Type has 'alternate spelling' selected
      #   select('alternate spelling', from: 'Type')
      #
      #   # then when I click "Create Alternate value"
      #   click_button('Create Alternate value')
      #
      #   #        I see the message "Alternate value was successfully created."
      #   #          I see the alternate value rendered under Annotations/Alternate value in the show
      #   expect(page).to have_content('Alternate value was successfully created.')
      #   expect(page.has_content?('Annotations')).to be_truthy
      #   expect(page.has_content?('Alternate values')).to be_truthy
      #   expect(page).to have_content('KeyTest, alternate spelling of "testkey" (on \'name\')')
      #
      # end
    end
  end
end
