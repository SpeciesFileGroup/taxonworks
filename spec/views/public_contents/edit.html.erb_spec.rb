require 'spec_helper'

describe "public_contents/edit" do
  before(:each) do
    @public_content = assign(:public_content, stub_model(PublicContent))
  end

  it "renders the edit public_content form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", public_content_path(@public_content), "post" do
    end
  end
end
