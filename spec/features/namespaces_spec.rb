require 'spec_helper'

describe 'Namespaces' do

  it_behaves_like 'an_administrator_login_required_controller' do 
    let(:index_path) { namespaces_path }
    let(:page_index_name) { 'Namespaces' }
  end 

  describe 'GET /Namespaces' do
    before {
      sign_in_administrator
      visit namespaces_path }
    specify 'an index name is present' do
      expect(page).to have_content('Namespaces')
    end
  end
end








