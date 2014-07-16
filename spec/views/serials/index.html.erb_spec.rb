require 'rails_helper'

describe "serials/index" do
  before(:each) do
    assign(:serials, [
      stub_model(Serial,
        :name => "Name",
        :created_by_id => 1,
        :updated_by_id => 2,
        :project_id => 3,
        :publisher => "Publisher",
        :place_published => "Place Published",
        :primary_language_id => 4,
        :first_year_of_issue => 5,
        :last_year_of_issue => 6
      ),
      stub_model(Serial,
        :name => "Name",
        :created_by_id => 1,
        :updated_by_id => 2,
        :project_id => 3,
        :publisher => "Publisher",
        :place_published => "Place Published",
        :primary_language_id => 4,
        :first_year_of_issue => 5,
        :last_year_of_issue => 6
      )
    ])
  end

  it "renders a list of serials" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => "Publisher".to_s, :count => 2
    assert_select "tr>td", :text => "Place Published".to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
    assert_select "tr>td", :text => 6.to_s, :count => 2
  end
end
