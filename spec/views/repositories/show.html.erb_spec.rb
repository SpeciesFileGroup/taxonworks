require 'rails_helper'

describe "repositories/show" do
  before(:each) do
    @repository = assign(:repository, stub_model(Repository,
      :name => "Name",
      :url => "Url",
      :acronym => "Acronym",
      :status => "Status",
      :institutional_LSID => "Institutional Lsid",
      :is_index_herbarioum_record => false,
      :created_by_id => 1,
      :updated_by_id => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/Url/)
    rendered.should match(/Acronym/)
    rendered.should match(/Status/)
    rendered.should match(/Institutional Lsid/)
    rendered.should match(/false/)
    rendered.should match(/1/)
    rendered.should match(/2/)
  end
end
