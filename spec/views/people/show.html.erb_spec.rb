require 'rails_helper'

describe "people/show" do
  before(:each) do
    @person = assign(:person, stub_model(Person,
      :type => "Type",
      :last_name => "Last Name",
      :first_name => "First Name",
      :suffix => "Suffix",
      :prefix => "Prefix",
      :created_by_id => 1,
      :updated_by_id => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Type/)
    rendered.should match(/Last Name/)
    rendered.should match(/First Name/)
    rendered.should match(/Suffix/)
    rendered.should match(/Prefix/)
    rendered.should match(/1/)
    rendered.should match(/2/)
  end
end
