require 'spec_helper'

describe "citations/edit" do
  before(:each) do
    @citation = assign(:citation, stub_model(Citation))
  end

  it "renders the edit citation form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", citation_path(@citation), "post" do
    end
  end
end
