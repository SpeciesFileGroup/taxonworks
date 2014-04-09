require 'spec_helper'

describe "controlled_vocabulary_terms/edit" do
  before(:each) do
    @controlled_vocabulary_term = assign(:controlled_vocabulary_term, stub_model(ControlledVocabularyTerm,
      :type => "Keyword",
      :name => "MyString",
      :definition => "MyText",
      :created_by_id => 1,
      :updated_by_id => 1,
      :project_id => 1
    ))
  end

  it "renders the edit controlled_vocabulary_term form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", controlled_vocabulary_term_path(@controlled_vocabulary_term), "post" do
      assert_select "select#controlled_vocabulary_term_type[name=?]", "controlled_vocabulary_term[type]"
      assert_select "input#controlled_vocabulary_term_name[name=?]", "controlled_vocabulary_term[name]"
      assert_select "textarea#controlled_vocabulary_term_definition[name=?]", "controlled_vocabulary_term[definition]"
    end
  end
end
