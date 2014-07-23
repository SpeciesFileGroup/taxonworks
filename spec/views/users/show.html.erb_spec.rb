require 'rails_helper'

describe "users/show", :type => :view do
  before(:each) do
    @user = assign(:user, stub_model(User,
      :email => "Email",
      :created_by_id => 1,
      :updated_by_id => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/Edit account/)
  end
end
