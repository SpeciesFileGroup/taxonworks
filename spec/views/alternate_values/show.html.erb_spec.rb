require 'rails_helper'

describe "alternate_values/show", :type => :view do
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
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Type/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/Alternate Object Type/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Alternate Object Attribute/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
  end
end
