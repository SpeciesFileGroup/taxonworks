require 'rails_helper'

describe "controlled_vocabulary_terms/show" do
  before(:each) do
    @controlled_vocabulary_term = assign(:controlled_vocabulary_term, stub_model(ControlledVocabularyTerm,
      :type => "Type",
      :name => "Name",
      :definition => "MyText",
      :created_by_id => 1,
      :updated_by_id => 2,
      :project_id => 3
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Type/)
    rendered.should match(/Name/)
    rendered.should match(/MyText/)
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/3/)
  end
end
