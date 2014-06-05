require 'spec_helper'

describe "public_contents/new" do
  before(:each) do
    assign(:public_content, stub_model(PublicContent).as_new_record)
  end

  it "renders new public_content form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", public_contents_path, "post" do
    end
  end
end
