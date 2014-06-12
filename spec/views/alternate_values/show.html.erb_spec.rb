require 'spec_helper'

describe "alternate_values/show" do
  before(:each) do
    @alternate_value = assign(:alternate_value, stub_model(AlternateValue,
      :value => "MyText",
      :type => "Type",
      :language_id => 1,
      :alternate_object_type => "Alternate Object Type",
      :alternate_object_id => 2,
      :alternate_object_attribute => "Alternate Object Attribute",
      :created_by_id => 3,
      :updated_by_id => 4
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/MyText/)
    rendered.should match(/Type/)
    rendered.should match(/1/)
    rendered.should match(/Alternate Object Type/)
    rendered.should match(/2/)
    rendered.should match(/Alternate Object Attribute/)
    rendered.should match(/3/)
    rendered.should match(/4/)
  end
end
