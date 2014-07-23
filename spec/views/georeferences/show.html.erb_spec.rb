require 'rails_helper'

describe "georeferences/show", :type => :view do
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
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/Type/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/5/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/Api Request/)
    expect(rendered).to match(/6/)
    expect(rendered).to match(/7/)
    expect(rendered).to match(/8/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
  end
end
