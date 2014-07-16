require 'rails_helper'

describe "alternate_values/new" do
  before(:each) do
    assign(:alternate_value, stub_model(AlternateValue,
      :value => "MyText",
      :type => "",
      :language_id => 1,
      :alternate_object_type => "MyString",
      :alternate_object_id => 1,
      :alternate_object_attribute => "MyString",
      :created_by_id => 1,
      :updated_by_id => 1
    ).as_new_record)
  end

  it "renders new alternate_value form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", alternate_values_path, "post" do
      assert_select "textarea#alternate_value_value[name=?]", "alternate_value[value]"
      assert_select "input#alternate_value_type[name=?]", "alternate_value[type]"
      assert_select "input#alternate_value_language_id[name=?]", "alternate_value[language_id]"
      assert_select "input#alternate_value_alternate_object_type[name=?]", "alternate_value[alternate_object_type]"
      assert_select "input#alternate_value_alternate_object_id[name=?]", "alternate_value[alternate_object_id]"
      assert_select "input#alternate_value_alternate_object_attribute[name=?]", "alternate_value[alternate_object_attribute]"
      # assert_select "input#alternate_value_created_by_id[name=?]", "alternate_value[created_by_id]"
      # assert_select "input#alternate_value_updated_by_id[name=?]", "alternate_value[updated_by_id]"
    end
  end
end
