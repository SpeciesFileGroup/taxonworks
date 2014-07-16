require 'rails_helper'

describe "loan_items/show" do
  before(:each) do
    @loan_item = assign(:loan_item, stub_model(LoanItem,
      :loan_id => 1,
      :collection_object_id => 2,
      :collection_object_status => "Collection Object Status",
      :position => 3,
      :created_by_id => 4,
      :updated_by_id => 5,
      :project_id => 6,
      :container_id => 7
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/Collection Object Status/)
    rendered.should match(/3/)
    rendered.should match(/4/)
    rendered.should match(/5/)
    rendered.should match(/6/)
    rendered.should match(/7/)
  end
end
