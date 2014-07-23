require 'rails_helper'

describe "loan_items/show", :type => :view do
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
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Collection Object Status/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/5/)
    expect(rendered).to match(/6/)
    expect(rendered).to match(/7/)
  end
end
