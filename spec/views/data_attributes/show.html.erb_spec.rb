require 'spec_helper'

describe "data_attributes/show" do
  before(:each) do
    @data_attribute = assign(:data_attribute, stub_model(DataAttribute,
      :type => "Type",
      :attribute_subject_id => 1,
      :attribute_subject_type => "Attribute Subject Type",
      :controlled_vocabulary_term_id => 2,
      :import_predicate => "Import Predicate",
      :value => "MyText",
      :created_by_id => 3,
      :updated_by_id => 4,
      :project_id => 5
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Type/)
    rendered.should match(/1/)
    rendered.should match(/Attribute Subject Type/)
    rendered.should match(/2/)
    rendered.should match(/Import Predicate/)
    rendered.should match(/MyText/)
    rendered.should match(/3/)
    rendered.should match(/4/)
    rendered.should match(/5/)
  end
end
