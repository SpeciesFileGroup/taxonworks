require 'spec_helper'

describe "collection_objects/edit" do
  before(:each) do
    @collection_object = assign(:collection_object, stub_model(CollectionObject,
      :total => 1,
      :type => "",
      :preparation_type_id => 1,
      :repository_id => 1,
      :created_by_id => 1,
      :updated_by_id => 1,
      :project_id => 1
    ))
  end

  it "renders the edit collection_object form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", collection_object_path(@collection_object), "post" do
      assert_select "input#collection_object_total[name=?]", "collection_object[total]"
      assert_select "input#collection_object_type[name=?]", "collection_object[type]"
      assert_select "input#collection_object_preparation_type_id[name=?]", "collection_object[preparation_type_id]"
      assert_select "input#collection_object_repository_id[name=?]", "collection_object[repository_id]"
      assert_select "input#collection_object_created_by_id[name=?]", "collection_object[created_by_id]"
      assert_select "input#collection_object_updated_by_id[name=?]", "collection_object[updated_by_id]"
      assert_select "input#collection_object_project_id[name=?]", "collection_object[project_id]"
    end
  end
end
