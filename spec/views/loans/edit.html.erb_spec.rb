require 'spec_helper'

describe "loans/edit" do
  before(:each) do
    @loan = assign(:loan, stub_model(Loan,
      :request_method => "MyString",
      :recipient_person_id => 1,
      :recipient_address => "MyString",
      :recipient_email => "MyString",
      :recipient_phone => "MyString",
      :recipient_country => 1,
      :supervisor_person_id => "MyString",
      :supervisor_email => "MyString",
      :supervisor_phone => "MyString",
      :created_by_id => 1,
      :updated_by_id => 1,
      :project_id => 1,
      :recipient_honorarium => "MyString"
    ))
  end

  it "renders the edit loan form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", loan_path(@loan), "post" do
      assert_select "input#loan_request_method[name=?]", "loan[request_method]"
      assert_select "input#loan_recipient_person_id[name=?]", "loan[recipient_person_id]"
      assert_select "input#loan_recipient_address[name=?]", "loan[recipient_address]"
      assert_select "input#loan_recipient_email[name=?]", "loan[recipient_email]"
      assert_select "input#loan_recipient_phone[name=?]", "loan[recipient_phone]"
      assert_select "input#loan_recipient_country[name=?]", "loan[recipient_country]"
      assert_select "input#loan_supervisor_person_id[name=?]", "loan[supervisor_person_id]"
      assert_select "input#loan_supervisor_email[name=?]", "loan[supervisor_email]"
      assert_select "input#loan_supervisor_phone[name=?]", "loan[supervisor_phone]"
      # assert_select "input#loan_created_by_id[name=?]", "loan[created_by_id]"
      # assert_select "input#loan_updated_by_id[name=?]", "loan[updated_by_id]"
      # assert_select "input#loan_project_id[name=?]", "loan[project_id]"
      assert_select "input#loan_recipient_honorarium[name=?]", "loan[recipient_honorarium]"
    end
  end
end
