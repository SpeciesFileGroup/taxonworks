require 'rails_helper'

describe "users/edit", :type => :view do
  before(:each) do
    @user = assign(:user, stub_model(User,
      :email => "MyString",
      :password_digest => "MyString",
      :created_by_id => 1,
      :updated_by_id => 1
                                    ))
  end

  it "renders the edit user form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", user_path(@user), "post" do
      assert_select "input#user_email[name=?]", "user[email]"
      assert_select "input#user_password[name=?]", "user[password]"
      assert_select "input#user_password_confirmation[name=?]", "user[password_confirmation]"
    end
  end
end
