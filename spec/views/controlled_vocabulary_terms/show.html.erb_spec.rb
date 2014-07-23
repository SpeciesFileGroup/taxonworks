require 'rails_helper'

describe "controlled_vocabulary_terms/show", :type => :view do
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
    expect(rendered).to match(/Type/)
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
  end
end
