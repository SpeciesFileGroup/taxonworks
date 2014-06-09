require 'spec_helper'

describe 'DataAttributes', base_class: DataAttribute do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /data_attributes' do
    before { visit data_attributes_path }
    specify 'an index name is present' do
      expect(page).to have_content('Data Attributes')
    end
  end
end
