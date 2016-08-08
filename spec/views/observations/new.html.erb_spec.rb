require 'rails_helper'

RSpec.describe "observations/new", type: :view do
  before(:each) do
    assign(:observation, Observation.new(
      :descriptor => nil,
      :otu => nil,
      :collection_object => nil,
      :character_state => nil,
      :frequency => "MyString",
      :continuous_value => "9.99",
      :continuous_unit => "MyString",
      :sample_n => 1,
      :sample_min => "9.99",
      :sample_max => "9.99",
      :sample_median => "9.99",
      :sample_mean => "9.99",
      :sample_units => "MyString",
      :sample => "",
      :sample_standard_error => "9.99",
      :presence => false,
      :description => "MyText",
      :cached => "MyString",
      :cached_column_label => "MyString",
      :cached_row_label => "MyString",
      :created_by_id => 1,
      :updated_by_id => 1,
      :project => nil
    ))
  end

  it "renders new observation form" do
    render

    assert_select "form[action=?][method=?]", observations_path, "post" do

      assert_select "input#observation_descriptor_id[name=?]", "observation[descriptor_id]"

      assert_select "input#observation_otu_id[name=?]", "observation[otu_id]"

      assert_select "input#observation_collection_object_id[name=?]", "observation[collection_object_id]"

      assert_select "input#observation_character_state_id[name=?]", "observation[character_state_id]"

      assert_select "input#observation_frequency[name=?]", "observation[frequency]"

      assert_select "input#observation_continuous_value[name=?]", "observation[continuous_value]"

      assert_select "input#observation_continuous_unit[name=?]", "observation[continuous_unit]"

      assert_select "input#observation_sample_n[name=?]", "observation[sample_n]"

      assert_select "input#observation_sample_min[name=?]", "observation[sample_min]"

      assert_select "input#observation_sample_max[name=?]", "observation[sample_max]"

      assert_select "input#observation_sample_median[name=?]", "observation[sample_median]"

      assert_select "input#observation_sample_mean[name=?]", "observation[sample_mean]"

      assert_select "input#observation_sample_units[name=?]", "observation[sample_units]"

      assert_select "input#observation_sample[name=?]", "observation[sample]"

      assert_select "input#observation_sample_standard_error[name=?]", "observation[sample_standard_error]"

      assert_select "input#observation_presence[name=?]", "observation[presence]"

      assert_select "textarea#observation_description[name=?]", "observation[description]"

      assert_select "input#observation_cached[name=?]", "observation[cached]"

      assert_select "input#observation_cached_column_label[name=?]", "observation[cached_column_label]"

      assert_select "input#observation_cached_row_label[name=?]", "observation[cached_row_label]"

      assert_select "input#observation_created_by_id[name=?]", "observation[created_by_id]"

      assert_select "input#observation_updated_by_id[name=?]", "observation[updated_by_id]"

      assert_select "input#observation_project_id[name=?]", "observation[project_id]"
    end
  end
end
