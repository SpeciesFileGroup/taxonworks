require 'spec_helper'

describe "georeferences/show" do
  before(:each) do
    @georeference = assign(:georeference, stub_model(Georeference,
                                                     :geographic_item_id       => 1,
                                                     :collecting_event_id      => 2,
                                                     :error_radius             => "9.99",
                                                     :error_depth              => "9.99",
                                                     :error_geographic_item_id => 3,
                                                     :type                     => "Type",
                                                     :source_id                => 4,
                                                     :position                 => 5,
                                                     :is_public                => false,
                                                     :api_request              => "Api Request",
                                                     :created_by_id            => 6,
                                                     :updated_by_id            => 7,
                                                     :project_id               => 8,
                                                     :is_undefined_z           => false,
                                                     :is_median_z              => false
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/9.99/)
    rendered.should match(/9.99/)
    rendered.should match(/3/)
    rendered.should match(/Type/)
    rendered.should match(/4/)
    rendered.should match(/5/)
    rendered.should match(/false/)
    rendered.should match(/Api Request/)
    rendered.should match(/6/)
    rendered.should match(/7/)
    rendered.should match(/8/)
    rendered.should match(/false/)
    rendered.should match(/false/)
  end
end
