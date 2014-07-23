require 'rails_helper'

describe "controlled_vocabulary_terms/new", :type => :view do
  before(:each) do
    assign(:controlled_vocabulary_term, stub_model(ControlledVocabularyTerm,
      :type => "",
      :name => "MyString",
      :definition => "MyText",
      :created_by_id => 1,
      :updated_by_id => 1,
      :project_id => 1
    ).as_new_record)
  end

  it "renders new controlled_vocabulary_term form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", controlled_vocabulary_terms_path, "post" do
      assert_select "select#controlled_vocabulary_term_type[name=?]", "controlled_vocabulary_term[type]"
      assert_select "option[value=?]", "Keyword"
      assert_select "input#controlled_vocabulary_term_name[name=?]", "controlled_vocabulary_term[name]"
      assert_select "textarea#controlled_vocabulary_term_definition[name=?]", "controlled_vocabulary_term[definition]"
    end
  end
end
