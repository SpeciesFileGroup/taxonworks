require 'spec_helper'

describe "alternate_values/edit" do
  before(:each) do
    @alternate_value = assign(:alternate_value, stub_model(AlternateValue))
  end

  it "renders the edit alternate_value form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", alternate_value_path(@alternate_value), "post" do
    end
  end
end
