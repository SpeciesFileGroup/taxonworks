require 'rails_helper'

describe "repositories/index", :type => :view do
  before(:each) do
    assign(:repositories, [
      stub_model(Repository,
        :name => "Name",
        :url => "Url",
        :acronym => "Acronym",
        :status => "Status",
        :institutional_LSID => "Institutional Lsid",
        :is_index_herbariorum => false,
        :created_by_id => 1,
        :updated_by_id => 2
      ),
      stub_model(Repository,
        :name => "Name",
        :url => "Url",
        :acronym => "Acronym",
        :status => "Status",
        :institutional_LSID => "Institutional Lsid",
        :is_index_herbariorum => false,
        :created_by_id => 1,
        :updated_by_id => 2
      )
    ])
  end

  it "renders a list of repositories" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Url".to_s, :count => 2
    assert_select "tr>td", :text => "Acronym".to_s, :count => 2
    assert_select "tr>td", :text => "Status".to_s, :count => 2
    assert_select "tr>td", :text => "Institutional Lsid".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
