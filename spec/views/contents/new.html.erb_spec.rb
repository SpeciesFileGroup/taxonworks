require 'spec_helper'

describe "contents/new" do
  before(:each) do
    assign(:content, stub_model(Content).as_new_record)
  end

  it "renders new content form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", contents_path, "post" do
    end
  end
end
