require 'spec_helper'

describe "loans/show" do
  before(:each) do
    @loan = assign(:loan, stub_model(Loan,
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
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Request Method/)
    rendered.should match(/1/)
    rendered.should match(/Recipient Address/)
    rendered.should match(/Recipient Email/)
    rendered.should match(/Recipient Phone/)
    rendered.should match(/2/)
    rendered.should match(/Supervisor Person/)
    rendered.should match(/Supervisor Email/)
    rendered.should match(/Supervisor Phone/)
    rendered.should match(/3/)
    rendered.should match(/4/)
    rendered.should match(/5/)
    rendered.should match(/Recipient Honorarium/)
  end
end
