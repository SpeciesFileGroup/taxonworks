require 'rails_helper'

describe "data_attributes/new" do
  before(:each) do
    assign(:data_attribute, stub_model(DataAttribute,
      :type => "",
      :attribute_subject_id => 1,
      :attribute_subject_type => "MyString",
      :controlled_vocabulary_term_id => 1,
      :import_predicate => "MyString",
      :value => "MyText",
      :created_by_id => 1,
      :updated_by_id => 1,
      :project_id => 1
    ).as_new_record)
  end

  it "renders new data_attribute form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", data_attributes_path, "post" do
      assert_select "input#data_attribute_type[name=?]", "data_attribute[type]"
      assert_select "input#data_attribute_attribute_subject_id[name=?]", "data_attribute[attribute_subject_id]"
      assert_select "input#data_attribute_attribute_subject_type[name=?]", "data_attribute[attribute_subject_type]"
      assert_select "input#data_attribute_controlled_vocabulary_term_id[name=?]", "data_attribute[controlled_vocabulary_term_id]"
      assert_select "input#data_attribute_import_predicate[name=?]", "data_attribute[import_predicate]"
      assert_select "textarea#data_attribute_value[name=?]", "data_attribute[value]"
      # assert_select "input#data_attribute_created_by_id[name=?]", "data_attribute[created_by_id]"
      # assert_select "input#data_attribute_updated_by_id[name=?]", "data_attribute[updated_by_id]"
      # assert_select "input#data_attribute_project_id[name=?]", "data_attribute[project_id]"
    end
  end
end
