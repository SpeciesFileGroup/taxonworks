require 'rails_helper'

describe "collection_objects/index", :type => :view do
  before(:each) do
    @data_model = CollectionObject
    assign(:recent_objects, [
      stub_model(CollectionObject,
        :total => 1,
        :type => "Type",
        :preparation_type_id => 2,
        :repository_id => 3,
        :created_by_id => 4,
        :updated_by_id => 5,
        :created_at => Time.now(),
        :updated_at => Time.now(),
        :project_id => 6
      ),
      stub_model(CollectionObject,
        :total => 1,
        :type => "Type",
        :preparation_type_id => 2,
        :repository_id => 3,
        :created_by_id => 4,
        :updated_by_id => 5,
        :created_at => Time.now(),
        :updated_at => Time.now(),
        :project_id => 6
      )
    ])
  end

  it "renders a list of recent collection_objects" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "ul>li>a", :text => 'Edit', :count => 2
  end
end
