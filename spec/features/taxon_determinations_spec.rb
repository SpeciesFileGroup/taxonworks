require 'rails_helper'

describe 'TaxonDeterminations', :type => :feature do
  let(:page_title) { 'Taxon determinations' }
  let(:index_path) { taxon_determinations_path }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in as a user, with some records created' do
    before {
      sign_in_user_and_select_project

      # Create taxon determination via specimen.
      otu = factory_girl_create_for_user_and_project(:valid_otu, @user, @project)
      3.times {
        Specimen.create!(
            taxon_determinations_attributes: [{otu_id: otu.id, by: @user, project: @project}],
            by: @user,
            project: @project
        )
      }
    }

    describe 'GET /taxon_determinations' do
      before {
        visit taxon_determinations_path }
      it_behaves_like 'a_data_model_with_standard_index'
    end

    describe 'GET /taxon_determinations/list' do
      before { visit list_taxon_determinations_path }
      it_behaves_like 'a_data_model_with_standard_list_and_records_created'
    end

    describe 'GET /taxon_determinations/n' do
      before {
        visit taxon_determination_path(TaxonDetermination.second)
      }
      it_behaves_like 'a_data_model_with_standard_show'
    end

    context 'testing new taxon determination' do
      before {
        visit taxon_determinations_path
      }
      
      let(:p) {Person.create(last_name: 'Barrymore', first_name: 'Barry')}
      let(:o) {Otu.create!(user_project_attributes(@user, @project).merge(name: 'motu')) }
      let(:s) {factory_girl_create_for_user_and_project(:valid_specimen, @user, @project) }

      specify 'can create a new taxon determination', js: true do
        # need person (role determiner), OTU, and specimen (CollectionObject::BiologicalCollectionObject)

        click_link('New')
        expect(page).to have_content("New taxon determination")

        expect(page.has_field?('determiner_autocomplete', :type => 'text')).to be_truthy
        expect(page.has_field?('biological_collection_object_id_for_taxon_determination', :type => 'text')).to be_truthy
        expect(page.has_field?('taxon_determination[otu_id]', :type => 'text')).to be_truthy
        expect(page.has_field?('taxon_determination_year_made', :type => 'text')).to be_truthy

        # fill_role_picker_autocomplete('determiner_autocomplete', with: 'Barry Barrymore', select: s.id)
        # @todo @mjy Could not get the name selected; error message below:
        # expected to find css "li.ui-menu-item a[data-model-id=\"4\"]" but there were no matches

        fill_autocomplete('biological_collection_object_id_for_taxon_determination', with: "#{s.id}", select: s.id)
        fill_otu_widget_autocomplete('taxon_determination[otu_id]', with: 'motu', select: o.id) # equivalent to o.name
        fill_in('taxon_determination_year_made', with: '2016')
        fill_in('taxon_determination_month_made', with: '1')
        fill_in('taxon_determination_day_made', with: '20')

        click_button('Create Taxon determination')

        expect(page).to have_content("Taxon determination was successfully created.")
        #  expect(page).to have_content("determined as motu by Barrymore on 2016-1-20)")  # uncomment when line 62 is fixed
      end
    end
  end
end
