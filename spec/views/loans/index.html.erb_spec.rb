require 'rails_helper'

describe "loans/index" do
  before(:each) do
    assign(:loans, [
      stub_model(Loan,
        :request_method => "Request Method",
        :recipient_person_id => 1,
        :recipient_address => "Recipient Address",
        :recipient_email => "Recipient Email",
        :recipient_phone => "Recipient Phone",
        :recipient_country => 2,
        :supervisor_person_id => "Supervisor Person",
        :supervisor_email => "Supervisor Email",
        :supervisor_phone => "Supervisor Phone",
        :created_by_id => 3,
        :updated_by_id => 4,
        :project_id => 5,
        :recipient_honorarium => "Recipient Honorarium"
      ),
      stub_model(Loan,
        :request_method => "Request Method",
        :recipient_person_id => 1,
        :recipient_address => "Recipient Address",
        :recipient_email => "Recipient Email",
        :recipient_phone => "Recipient Phone",
        :recipient_country => 2,
        :supervisor_person_id => "Supervisor Person",
        :supervisor_email => "Supervisor Email",
        :supervisor_phone => "Supervisor Phone",
        :created_by_id => 3,
        :updated_by_id => 4,
        :project_id => 5,
        :recipient_honorarium => "Recipient Honorarium"
      )
    ])
  end

  it "renders a list of loans" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Request Method".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Recipient Address".to_s, :count => 2
    assert_select "tr>td", :text => "Recipient Email".to_s, :count => 2
    assert_select "tr>td", :text => "Recipient Phone".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Supervisor Person".to_s, :count => 2
    assert_select "tr>td", :text => "Supervisor Email".to_s, :count => 2
    assert_select "tr>td", :text => "Supervisor Phone".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
    assert_select "tr>td", :text => "Recipient Honorarium".to_s, :count => 2
  end
end
