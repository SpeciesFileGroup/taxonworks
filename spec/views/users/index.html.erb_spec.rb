require 'rails_helper'

describe "users/index" do
  before(:each) do
    assign(:users, [
      stub_model(User,
        :email => "Email",
        :password_digest => "Password Digest",
        :created_by_id => 1,
        :updated_by_id => 2
      ),
      stub_model(User,
        :email => "Email1",
        :password_digest => "Password Digest",
        :created_by_id => 1,
        :updated_by_id => 2
      )
    ])
  end

  it "renders a list of users" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "ul>li", :text => 'Email', :count => 1
    assert_select "ul>li", :text => 'Email1', :count => 1
    #     assert_select "tr>td", :text => "Email".to_s, :count => 1
  #  assert_select "tr>td", :text => "Password Digest".to_s, :count => 2
#   assert_select "tr>td", :text => 1.to_s, :count => 2
#   assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
