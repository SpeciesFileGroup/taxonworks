require 'spec_helper'

describe "collection_profiles/new" do
  before(:each) do
    assign(:collection_profile, stub_model(CollectionProfile,
                                           :container_id                 => 1,
                                           :otu_id                       => 1,
                                           :conservation_status          => 1,
                                           :processing_state             => 1,
                                           :container_condition          => 1,
                                           :condition_of_labels          => 1,
                                           :identification_level         => 1,
                                           :arrangement_level            => 1,
                                           :data_quality                 => 1,
                                           :computerization_level        => 1,
                                           :number_of_collection_objects => 1,
                                           :number_of_containers         => 1,
                                           :created_by_id                => 1,
                                           :updated_by_id                => 1,
                                           :project_id                   => 1,
                                           :collection_type              => "MyString"
    ).as_new_record)
  end

  it "renders new collection_profile form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", collection_profiles_path, "post" do
      assert_select "input#collection_profile_container_id[name=?]", "collection_profile[container_id]"
      assert_select "input#collection_profile_otu_id[name=?]", "collection_profile[otu_id]"
      assert_select "input#collection_profile_conservation_status[name=?]", "collection_profile[conservation_status]"
      assert_select "input#collection_profile_processing_state[name=?]", "collection_profile[processing_state]"
      assert_select "input#collection_profile_container_condition[name=?]", "collection_profile[container_condition]"
      assert_select "input#collection_profile_condition_of_labels[name=?]", "collection_profile[condition_of_labels]"
      assert_select "input#collection_profile_identification_level[name=?]", "collection_profile[identification_level]"
      assert_select "input#collection_profile_arrangement_level[name=?]", "collection_profile[arrangement_level]"
      assert_select "input#collection_profile_data_quality[name=?]", "collection_profile[data_quality]"
      assert_select "input#collection_profile_computerization_level[name=?]", "collection_profile[computerization_level]"
      assert_select "input#collection_profile_number_of_collection_objects[name=?]", "collection_profile[number_of_collection_objects]"
      assert_select "input#collection_profile_number_of_containers[name=?]", "collection_profile[number_of_containers]"
      # assert_select "input#collection_profile_created_by_id[name=?]", "collection_profile[created_by_id]"
      # assert_select "input#collection_profile_updated_by_id[name=?]", "collection_profile[updated_by_id]"
      # assert_select "input#collection_profile_project_id[name=?]", "collection_profile[project_id]"
      assert_select "input#collection_profile_collection_type[name=?]", "collection_profile[collection_type]"
    end
  end
end
