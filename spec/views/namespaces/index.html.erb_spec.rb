require 'spec_helper'

describe "namespaces/index" do
  before(:each) do
    assign(:namespaces, [
      stub_model(Namespace,
        :institution => "Institution",
        :name => "Name",
        :short_name => "Short Name",
        :created_by_id => 1,
        :updated_by_id => 2
      ),
      stub_model(Namespace,
        :institution => "Institution",
        :name => "Name",
        :short_name => "Short Name",
        :created_by_id => 1,
        :updated_by_id => 2
      )
    ])
  end

  it "renders a list of namespaces" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Institution".to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Short Name".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
