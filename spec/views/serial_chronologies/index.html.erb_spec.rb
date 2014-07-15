require 'spec_helper'

describe "serial_chronologies/index" do
  before(:each) do
    assign(:serial_chronologies, [
      stub_model(SerialChronology,
        :preceding_serial_id => 1,
        :succeeding_serial_id => 2,
        :created_by_id => 3,
        :modified_by_id => 4
      ),
      stub_model(SerialChronology,
        :preceding_serial_id => 1,
        :succeeding_serial_id => 2,
        :created_by_id => 3,
        :modified_by_id => 4
      )
    ])
  end

  it "renders a list of serial_chronologies" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
  end
end
