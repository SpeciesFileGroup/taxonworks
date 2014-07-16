require 'rails_helper'

describe "namespaces/show" do
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
    rendered.should match(/Institution/)
    rendered.should match(/Name/)
    rendered.should match(/Short Name/)
    rendered.should match(/1/)
    rendered.should match(/2/)
  end
end
