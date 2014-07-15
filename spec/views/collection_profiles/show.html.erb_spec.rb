require 'spec_helper'

describe "collection_profiles/show" do
  before(:each) do
    @collection_profile = assign(:collection_profile, stub_model(CollectionProfile,
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
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/3/)
    rendered.should match(/4/)
    rendered.should match(/5/)
    rendered.should match(/6/)
    rendered.should match(/7/)
    rendered.should match(/8/)
    rendered.should match(/9/)
    rendered.should match(/10/)
    rendered.should match(/11/)
    rendered.should match(/12/)
    rendered.should match(/13/)
    rendered.should match(/14/)
    rendered.should match(/15/)
    rendered.should match(/Collection Type/)
  end
end
