require 'rails_helper'

describe "serial_chronologies/new" do
  before(:each) do
    assign(:serial_chronology, stub_model(SerialChronology,
      :preceding_serial_id => 1,
      :succeeding_serial_id => 1,
      :created_by_id => 1,
      :modified_by_id => 1
    ).as_new_record)
  end

  it "renders new serial_chronology form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", serial_chronologies_path, "post" do
      assert_select "input#serial_chronology_preceding_serial_id[name=?]", "serial_chronology[preceding_serial_id]"
      assert_select "input#serial_chronology_succeeding_serial_id[name=?]", "serial_chronology[succeeding_serial_id]"
      assert_select "input#serial_chronology_created_by_id[name=?]", "serial_chronology[created_by_id]"
      assert_select "input#serial_chronology_modified_by_id[name=?]", "serial_chronology[modified_by_id]"
    end
  end
end
