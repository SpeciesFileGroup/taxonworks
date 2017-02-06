require 'rails_helper'

describe 'DataAttributes', :type => :feature do
  # Capybara.default_wait_time = 15  # slows down Capybara enough to see what's happening on the form

  let(:index_path) { data_attributes_path }
  let(:page_title) { 'Data attributes' }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user, with some records created' do
    before {
      sign_in_user_and_select_project

      o = Otu.create!(name: 'Cow', by: @user, project: @project)

      predicates = []
      ['slow', 'medium', 'fast'].each do |n|
        predicates.push Predicate.create!(name: n, definition: "#{n}'s definition'", by: @user, project: @project)
      end

      (0..2).each do |i|
        InternalAttribute.create!(attribute_subject: o, predicate: predicates[i], value: i.to_s, by: @user, project: @project)
      end
    }

    describe 'GET /data_attributes' do
      before {
        visit data_attributes_path }

      it_behaves_like 'a_data_model_with_annotations_index'
    end

      describe 'GET /data_attributes/list' do
        before { visit list_data_attributes_path }

        it_behaves_like 'a_data_model_with_standard_list_and_records_created'
      end

    specify 'add a data attribute', js: true do

=begin
with an OTU created
with a Predicate created
     when I click on show for that otu
          then there is a "Add data attribute" link
          when I click on that link
             and I select the Predicate from the ajax selector
             and I enter the value "42"
             when I click "Create Data attribute"
                 then I get the message "Data attribute was successfully created."
                 and I can see the predicate rendered under annotations/data attributes

=end
      # signed in above
      otu = Otu.new(name: 'a', by: @user, project: @project)
      otu.save!  # create otu

      # create a predicate (controlled vocabulary term)
      pred = Predicate.new(by: @user, project: @project)
      pred.name = 'testPredicate'
      pred.definition = 'A predicate created for testing data attributes'
      pred.save!

      visit (otu_path(otu))
      find('#show_annotate_dropdown').hover

      expect(page).to have_link('Add data attribute')
      click_link('Add data attribute')
      fill_autocomplete('controlled_vocabulary_term_id_for_data_attribute',
                        with: 'testPredicate', select: pred.id)
      fill_in('Value', with: '42')
      click_button('Create Data attribute')
      expect(page).to have_content('Data attribute was successfully created.')
      expect(page).to have_selector('h2', text: 'Annotations')
      expect(page).to have_selector('h3', text: 'Data attributes')
      expect(page).to have_content('testPredicate: 42')
    end
  end
end
