require 'spec_helper'

describe "identifiers/new" do
  before(:each) do
    assign(:identifier, stub_model(Identifier,
      :identified_object_id => 1,
      :identified_object_type => "MyString",
      :identifier => "MyString",
      :type => "",
      :cached_identifier => "MyString",
      :namespace_id => 1,
      :created_by_id => 1,
      :updated_by_id => 1
    ).as_new_record)
  end

  it "renders new identifier form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", identifiers_path, "post" do
      assert_select "input#identifier_identified_object_id[name=?]", "identifier[identified_object_id]"
      assert_select "input#identifier_identified_object_type[name=?]", "identifier[identified_object_type]"
      assert_select "input#identifier_identifier[name=?]", "identifier[identifier]"
      assert_select "input#identifier_type[name=?]", "identifier[type]"
      assert_select "input#identifier_cached_identifier[name=?]", "identifier[cached_identifier]"
      assert_select "input#identifier_namespace_id[name=?]", "identifier[namespace_id]"
    end
  end
end
