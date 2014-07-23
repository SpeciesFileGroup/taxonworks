require 'rails_helper'

describe "alternate_values/index", :type => :view do
  before(:each) do
    assign(:alternate_values, [
      stub_model(AlternateValue,
        :value => "MyText",
        :type => "Type",
        :language_id => 1,
        :alternate_object_type => "Alternate Object Type",
        :alternate_object_id => 2,
        :alternate_object_attribute => "Alternate Object Attribute",
        :created_by_id => 3,
        :updated_by_id => 4
      ),
      stub_model(AlternateValue,
        :value => "MyText",
        :type => "Type",
        :language_id => 1,
        :alternate_object_type => "Alternate Object Type",
        :alternate_object_id => 2,
        :alternate_object_attribute => "Alternate Object Attribute",
        :created_by_id => 3,
        :updated_by_id => 4
      )
    ])
  end

  it "renders a list of alternate_values" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Type".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Alternate Object Type".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Alternate Object Attribute".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
  end
end
