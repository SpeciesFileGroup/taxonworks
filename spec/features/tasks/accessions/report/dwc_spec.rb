require 'rails_helper'

describe 'tasks/accessions/report/dwc', type: :feature, group: [:collection_objects, :darwin_core] do
  context 'with properly built collection of objects' do
    let(:page_title) { 'DWC Occurrence Report' }
    let(:index_path) { report_dwc_task_path }

    it_behaves_like 'a_login_required_and_project_selected_controller'

    context 'signed in as a user' do
      before { sign_in_user_and_select_project }

      context 'signed in as user, with some records created' do
        before do 
          3.times do
            a = factory_girl_create_for_user_and_project(:valid_specimen, @user, @project)
            a.get_dwc_occurrence
          end
        end 

        context 'downloading data' do
          before { visit index_path }

          specify 'is possible by clicking on button', js: true do
            click_link('download_dwca')
            expect( Features::Downloads::download_content ).to be_truthy # eq(zip)
          end
        end

      end
    end
  end
end
