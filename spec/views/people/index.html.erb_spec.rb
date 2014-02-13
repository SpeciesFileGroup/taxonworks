require 'spec_helper'

describe "people/index" do
  before(:each) do
    assign(:people, [
      stub_model(Person,
        :type => "Type",
        :last_name => "Last Name",
        :first_name => "First Name",
        :suffix => "Suffix",
        :prefix => "Prefix",
        :created_by_id => 1,
        :updated_by_id => 2
      ),
      stub_model(Person,
        :type => "Type",
        :last_name => "Last Name",
        :first_name => "First Name",
        :suffix => "Suffix",
        :prefix => "Prefix",
        :created_by_id => 1,
        :updated_by_id => 2
      )
    ])
  end

  it "renders a list of people" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Type".to_s, :count => 2
    assert_select "tr>td", :text => "Last Name".to_s, :count => 2
    assert_select "tr>td", :text => "First Name".to_s, :count => 2
    assert_select "tr>td", :text => "Suffix".to_s, :count => 2
    assert_select "tr>td", :text => "Prefix".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
