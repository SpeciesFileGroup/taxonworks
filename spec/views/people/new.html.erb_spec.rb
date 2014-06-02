require 'spec_helper'

describe "people/new" do
  before(:each) do
    assign(:person, stub_model(Person,
      :type => "",
      :last_name => "MyString",
      :first_name => "MyString",
      :suffix => "MyString",
      :prefix => "MyString",
      :created_by_id => 1,
      :updated_by_id => 1
    ).as_new_record)
  end

  it "renders new person form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", people_path, "post" do
      assert_select "input#person_type_personunvetted[name=?]", "person[type]"
      assert_select "input#person_type_personvetted[name=?]", "person[type]"
      assert_select "input#person_last_name[name=?]", "person[last_name]"
      assert_select "input#person_first_name[name=?]", "person[first_name]"
      assert_select "input#person_suffix[name=?]", "person[suffix]"
      assert_select "input#person_prefix[name=?]", "person[prefix]"
    end
  end
end
