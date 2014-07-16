require 'rails_helper'

describe "notes/new" do
  before(:each) do
    assign(:note, stub_model(Note,
      :text => "MyString",
      :note_object_id => 1,
      :note_object_type => "MyString",
      :note_object_attribute => "MyString",
      :created_by_id => 1,
      :updated_by_id => 1,
      :project_id => 1
    ).as_new_record)
  end

  it "renders new note form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", notes_path, "post" do
      assert_select "input#note_text[name=?]", "note[text]"
      assert_select "input#note_note_object_id[name=?]", "note[note_object_id]"
      assert_select "input#note_note_object_type[name=?]", "note[note_object_type]"
      assert_select "input#note_note_object_attribute[name=?]", "note[note_object_attribute]"
    end
  end
end
