require 'rails_helper'

describe "serial_chronologies/show", :type => :view do
  before(:each) do
    @serial_chronology = assign(:serial_chronology, stub_model(SerialChronology,
      :preceding_serial_id => 1,
      :succeeding_serial_id => 2,
      :created_by_id => 3,
      :modified_by_id => 4
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
  end
end
