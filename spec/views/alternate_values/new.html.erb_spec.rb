require 'spec_helper'

describe "alternate_values/new" do
  before(:each) do
    assign(:alternate_value, stub_model(AlternateValue).as_new_record)
  end

  it "renders new alternate_value form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", alternate_values_path, "post" do
    end
  end
end
