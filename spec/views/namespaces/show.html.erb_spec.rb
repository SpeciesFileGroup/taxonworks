require 'rails_helper'

describe "namespaces/show", :type => :view do
  before(:each) do
    @namespace = assign(:namespace, stub_model(Namespace,
      :institution => "Institution",
      :name => "Name",
      :short_name => "Short Name",
      :created_by_id => 1,
      :updated_by_id => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/Institution/)
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Short Name/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
  end
end
