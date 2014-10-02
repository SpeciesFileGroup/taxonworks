require 'rails_helper'

describe "users/show", :type => :view do
  before(:each) do
    @user = assign(:user, stub_model(User,
      email:  "Email@place.come",
      created_by_id: 1,
      updated_by_id: 1,
      name: 'smith'
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/smith/)
  end
end
