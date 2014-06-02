require 'spec_helper'

describe "controlled_vocabulary_terms/index" do
  before(:each) do
    assign(:controlled_vocabulary_terms, [
      stub_model(ControlledVocabularyTerm,
        :type => "Type",
        :name => "Name",
        :definition => "MyText",
        :created_by_id => 1,
        :updated_by_id => 2,
        :project_id => 3
      ),
      stub_model(ControlledVocabularyTerm,
        :type => "Type",
        :name => "Name",
        :definition => "MyText",
        :created_by_id => 1,
        :updated_by_id => 2,
        :project_id => 3
      )
    ])
  end

  it "renders a list of controlled_vocabulary_terms" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Type".to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
  end
end
