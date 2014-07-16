require 'rails_helper'

describe "collection_objects/show" do
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
    rendered.should match(/1/)
    rendered.should match(/Type/)
    rendered.should match(/2/)
    rendered.should match(/3/)
    rendered.should match(/4/)
    rendered.should match(/5/)
    rendered.should match(/6/)
  end
end
