require 'spec_helper'

describe "otus/index" do
  before(:each) do
    assign(:otus, [
      stub_model(Otu,
        :name => "Name",
        :created_by_id => 1,
        :updated_by_id => 2,
        :project_id => 3
      ),
      stub_model(Otu,
        :name => "Name",
        :created_by_id => 1,
        :updated_by_id => 2,
        :project_id => 3
      )
    ])
  end

  it "renders a list of otus" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
  end
end
