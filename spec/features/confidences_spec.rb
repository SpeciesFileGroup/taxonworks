require 'rails_helper'

describe 'Confidences', type: :feature, group: :annotations do
  let(:index_path) { confidences_path }
  let(:page_title) { 'Confidences' }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user, with some records created' do
    before do
      sign_in_user_and_select_project
    end

    let(:o) { Otu.create!(name: 'Cow', by: @user, project: @project) }

    let!(:confidence_levels) do
      confidence_levels = []
      ['Sure', 'Maybe', 'No!'].each do |n|
        confidence_levels.push ConfidenceLevel.create!(name: n, definition: "Really, #{n}.", by: @user, project: @project) 
      end
      confidence_levels
    end 

    let!(:confidences) do
      confidences = []
      (0..1).each do |i| # only create 2
        confidences.push Confidence.create!(confidence_object: o, confidence_level: confidence_levels[i], by: @user, project: @project)
      end
      confidences
    end

    describe 'GET /confidences' do
      before { visit confidences_path }
      it_behaves_like 'a_data_model_with_annotations_index'
    end

    describe 'GET /confidences/list' do
      before { visit list_confidences_path }
      it_behaves_like 'a_data_model_with_standard_list_and_records_created'
    end

    context 'creating a confidence through confidence/new' do
      before { visit otu_path(o) }

      context 'using the annotation menu' do
        before do
          find('#show_annotate_dropdown').click
          click_link 'Add confidence'

          fill_autocomplete_and_select('confidence_level_picker_autocomplete',
                                       object_type: 'confidence-level',
                                       with: confidence_levels[2].name,
                                       select_id: confidence_levels[2].id)
          click_button('Update')
        end

        specify 'confidence is added', js: true do
          expect(o.confidence_levels).to contain_exactly(*confidence_levels)
        end
      end
    end

  end
end



