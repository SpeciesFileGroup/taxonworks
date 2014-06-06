require 'spec_helper'

describe "data_attributes/new" do
  before(:each) do
    assign(:data_attribute, stub_model(DataAttribute).as_new_record)
  end

  it "renders new data_attribute form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", data_attributes_path, "post" do
    end
  end
end
