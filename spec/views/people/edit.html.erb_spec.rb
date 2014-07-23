require 'rails_helper'

describe "people/edit", :type => :view do
  before(:each) do
    @person = assign(:person, stub_model(Person,
      :type => "",
      :last_name => "MyString",
      :first_name => "MyString",
      :suffix => "MyString",
      :prefix => "MyString",
      :created_by_id => 1,
      :updated_by_id => 1
    ))
  end

  it "renders the edit person form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", person_path(@person), "post" do
      assert_select "input#person_type_personunvetted[name=?]", "person[type]"
      assert_select "input#person_type_personvetted[name=?]", "person[type]"
      assert_select "input#person_last_name[name=?]", "person[last_name]"
      assert_select "input#person_first_name[name=?]", "person[first_name]"
      assert_select "input#person_suffix[name=?]", "person[suffix]"
      assert_select "input#person_prefix[name=?]", "person[prefix]"
    end
  end
end
