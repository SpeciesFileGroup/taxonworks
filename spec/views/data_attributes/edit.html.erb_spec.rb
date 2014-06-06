require 'spec_helper'

describe "data_attributes/edit" do
  before(:each) do
    @data_attribute = assign(:data_attribute, stub_model(DataAttribute))
  end

  it "renders the edit data_attribute form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", data_attribute_path(@data_attribute), "post" do
    end
  end
end
