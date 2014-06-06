require 'spec_helper'

describe "citations/new" do
  before(:each) do
    assign(:citation, stub_model(Citation).as_new_record)
  end

  it "renders new citation form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", citations_path, "post" do
    end
  end
end
