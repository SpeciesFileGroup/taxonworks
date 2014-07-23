require 'rails_helper'

describe 'georeferences/edit', :type => :view do
  before(:each) do
    @georeference = assign(:georeference,
                           stub_model(Georeference,
                                      :geographic_item_id       => 1,
                                      :collecting_event_id      => 1,
                                      :error_radius             => '9.99',
                                      :error_depth              => '9.99',
                                      :error_geographic_item_id => 1,
                                      :type                     => '',
                                      :source_id                => 1,
                                      :position                 => 1,
                                      :is_public                => false,
                                      :api_request              => 'MyString',
                                      :project_id               => 1,
                                      :is_undefined_z           => false,
                                      :is_median_z              => false
                           ))
  end

  it "renders the edit georeference form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", georeference_path(@georeference), "post" do
      # assert_select "input#georeference_geographic_item_id[name=?]", "georeference[geographic_item_id]"
      assert_select "input#georeference_collecting_event_id[name=?]", "georeference[collecting_event_id]"
      # assert_select "input#georeference_error_radius[name=?]", "georeference[error_radius]"
      # assert_select "input#georeference_error_depth[name=?]", "georeference[error_depth]"
      # assert_select "input#georeference_error_geographic_item_id[name=?]", "georeference[error_geographic_item_id]"
      assert_select "input#georeference_type[name=?]", "georeference[type]"
      # assert_select "input#georeference_source_id[name=?]", "georeference[source_id]"
      # assert_select "input#georeference_position[name=?]", "georeference[position]"
      # assert_select "input#georeference_is_public[name=?]", "georeference[is_public]"
      # assert_select "input#georeference_api_request[name=?]", "georeference[api_request]"
      # assert_select "input#georeference_is_undefined_z[name=?]", "georeference[is_undefined_z]"
      # assert_select "input#georeference_is_median_z[name=?]", "georeference[is_median_z]"
    end
  end
end
