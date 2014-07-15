require 'spec_helper'

describe "collection_profiles/index" do
  before(:each) do
    assign(:collection_profiles, [
      stub_model(CollectionProfile,
        :container_id => 1,
        :otu_id => 2,
        :conservation_status => 3,
        :processing_state => 4,
        :container_condition => 5,
        :condition_of_labels => 6,
        :identification_level => 7,
        :arrangement_level => 8,
        :data_quality => 9,
        :computerization_level => 10,
        :number_of_collection_objects => 11,
        :number_of_containers => 12,
        :created_by_id => 13,
        :updated_by_id => 14,
        :project_id => 15,
        :collection_type => "Collection Type"
      ),
      stub_model(CollectionProfile,
        :container_id => 1,
        :otu_id => 2,
        :conservation_status => 3,
        :processing_state => 4,
        :container_condition => 5,
        :condition_of_labels => 6,
        :identification_level => 7,
        :arrangement_level => 8,
        :data_quality => 9,
        :computerization_level => 10,
        :number_of_collection_objects => 11,
        :number_of_containers => 12,
        :created_by_id => 13,
        :updated_by_id => 14,
        :project_id => 15,
        :collection_type => "Collection Type"
      )
    ])
  end

  it "renders a list of collection_profiles" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
    assert_select "tr>td", :text => 6.to_s, :count => 2
    assert_select "tr>td", :text => 7.to_s, :count => 2
    assert_select "tr>td", :text => 8.to_s, :count => 2
    assert_select "tr>td", :text => 9.to_s, :count => 2
    assert_select "tr>td", :text => 10.to_s, :count => 2
    assert_select "tr>td", :text => 11.to_s, :count => 2
    assert_select "tr>td", :text => 12.to_s, :count => 2
    assert_select "tr>td", :text => 13.to_s, :count => 2
    assert_select "tr>td", :text => 14.to_s, :count => 2
    assert_select "tr>td", :text => 15.to_s, :count => 2
    assert_select "tr>td", :text => "Collection Type".to_s, :count => 2
  end
end
