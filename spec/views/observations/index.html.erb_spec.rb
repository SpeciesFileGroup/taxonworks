require 'rails_helper'

RSpec.describe "observations/index", type: :view do
  before(:each) do
    assign(:observations, [
      Observation.create!(
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
      ),
      Observation.create!(
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
      )
    ])
  end

  it "renders a list of observations" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Frequency".to_s, :count => 2
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    assert_select "tr>td", :text => "Continuous Unit".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    assert_select "tr>td", :text => "Sample Units".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Cached".to_s, :count => 2
    assert_select "tr>td", :text => "Cached Column Label".to_s, :count => 2
    assert_select "tr>td", :text => "Cached Row Label".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
