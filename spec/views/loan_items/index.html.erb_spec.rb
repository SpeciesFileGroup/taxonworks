require 'rails_helper'

describe "loan_items/index" do
  before(:each) do
    assign(:loan_items, [
      stub_model(LoanItem,
        :loan_id => 1,
        :collection_object_id => 2,
        :collection_object_status => "Collection Object Status",
        :position => 3,
        :created_by_id => 4,
        :updated_by_id => 5,
        :project_id => 6,
        :container_id => 7
      ),
      stub_model(LoanItem,
        :loan_id => 1,
        :collection_object_id => 2,
        :collection_object_status => "Collection Object Status",
        :position => 3,
        :created_by_id => 4,
        :updated_by_id => 5,
        :project_id => 6,
        :container_id => 7
      )
    ])
  end

  it "renders a list of loan_items" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Collection Object Status".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
    assert_select "tr>td", :text => 6.to_s, :count => 2
    assert_select "tr>td", :text => 7.to_s, :count => 2
  end
end
