require 'rails_helper'

describe "collection_objects/show", :type => :view do
  before(:each) do
    @collection_object = assign(:collection_object, stub_model(CollectionObject,
      :total => 1,
      :type => "Type",
      :preparation_type_id => 2,
      :repository_id => 3,
      :created_by_id => 4,
      :updated_by_id => 5,
      :project_id => 6
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/1/)
    expect(rendered).to match(/Type/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/5/)
    expect(rendered).to match(/6/)
  end
end
