require 'rails_helper'

describe "repositories/show", :type => :view do
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
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Url/)
    expect(rendered).to match(/Acronym/)
    expect(rendered).to match(/Status/)
    expect(rendered).to match(/Institutional Lsid/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
  end
end
