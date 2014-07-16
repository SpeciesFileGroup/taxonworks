require 'rails_helper'

describe "loan_items/edit" do
  before(:each) do
    @loan_item = assign(:loan_item, stub_model(LoanItem,
      :loan_id => 1,
      :collection_object_id => 1,
      :collection_object_status => "MyString",
      :position => 1,
      :created_by_id => 1,
      :updated_by_id => 1,
      :project_id => 1,
      :container_id => 1
    ))
  end

  it "renders the edit loan_item form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", loan_item_path(@loan_item), "post" do
      assert_select "input#loan_item_loan_id[name=?]", "loan_item[loan_id]"
      assert_select "input#loan_item_collection_object_id[name=?]", "loan_item[collection_object_id]"
      assert_select "input#loan_item_collection_object_status[name=?]", "loan_item[collection_object_status]"
      assert_select "input#loan_item_position[name=?]", "loan_item[position]"
      # assert_select "input#loan_item_created_by_id[name=?]", "loan_item[created_by_id]"
      # assert_select "input#loan_item_updated_by_id[name=?]", "loan_item[updated_by_id]"
      # assert_select "input#loan_item_project_id[name=?]", "loan_item[project_id]"
      assert_select "input#loan_item_container_id[name=?]", "loan_item[container_id]"
    end
  end
end
