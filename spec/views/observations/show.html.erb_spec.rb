require 'rails_helper'

RSpec.describe "observations/show", type: :view do
  before(:each) do
    @observation = assign(:observation, Observation.create!(
      :descriptor => nil,
      :otu => nil,
      :collection_object => nil,
      :character_state => nil,
      :frequency => "Frequency",
      :continuous_value => "9.99",
      :continuous_unit => "Continuous Unit",
      :sample_n => 2,
      :sample_min => "9.99",
      :sample_max => "9.99",
      :sample_median => "9.99",
      :sample_mean => "9.99",
      :sample_units => "Sample Units",
      :sample => "",
      :sample_standard_error => "9.99",
      :presence => false,
      :description => "MyText",
      :cached => "Cached",
      :cached_column_label => "Cached Column Label",
      :cached_row_label => "Cached Row Label",
      :created_by_id => 3,
      :updated_by_id => 4,
      :project => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/Frequency/)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/Continuous Unit/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/Sample Units/)
    expect(rendered).to match(//)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Cached/)
    expect(rendered).to match(/Cached Column Label/)
    expect(rendered).to match(/Cached Row Label/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(//)
  end
end
