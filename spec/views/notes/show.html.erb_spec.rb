require 'rails_helper'

describe "notes/show", :type => :view do
  before(:each) do
    @note = assign(:note, stub_model(Note,
      :text => "Text",
      :note_object_id => 1,
      :note_object_type => "Note Object Type",
      :note_object_attribute => "Note Object Attribute",
      :created_by_id => 2,
      :updated_by_id => 3,
      :project_id => 4
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/Text/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/Note Object Type/)
    expect(rendered).to match(/Note Object Attribute/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
  end
end
