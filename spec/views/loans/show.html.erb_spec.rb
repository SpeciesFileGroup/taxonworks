require 'rails_helper'

describe "loans/show", :type => :view do
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
    expect(rendered).to match(/Request Method/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/Recipient Address/)
    expect(rendered).to match(/Recipient Email/)
    expect(rendered).to match(/Recipient Phone/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Supervisor Person/)
    expect(rendered).to match(/Supervisor Email/)
    expect(rendered).to match(/Supervisor Phone/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/5/)
    expect(rendered).to match(/Recipient Honorarium/)
  end
end
